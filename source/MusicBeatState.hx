package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;
import flixel.input.keyboard.FlxKey;
import Section.SwagSection;
import Song.SongData;
import mobile.MobileControls;
import mobile.flixel.FlxVirtualPad;
import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;

class MusicBeatState extends FlxTransitionableState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	var step = 0.0;
	var startInMS = 0.0;
	var activeSong:SongData = null;

	var oldStep:Int = -1;

	private var curSection:Int = 0;

	private var currentSection:SwagSection = null;

	private var curDecimalBeat:Float = 0;

	private var oldSection:Int = -1;
	private var curTiming:TimingStruct = null;

	public static var instance:MusicBeatState;

	public static var currentColor = 0;
	public static var switchingState:Bool = false;

	public static var initSave:Bool = false;

	private var controls(get, never):Controls;
	var fullscreenBind:FlxKey;

	public static var subStates:Array<MusicBeatSubstate> = [];

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	var mobileControls:MobileControls;
	var virtualPad:FlxVirtualPad;
	var trackedInputsMobileControls:Array<FlxActionInput> = [];
	var trackedInputsVirtualPad:Array<FlxActionInput> = [];

	public function addVirtualPad(DPad:FlxDPadMode, Action:FlxActionMode):Void
	{
		if (virtualPad != null)
			removeVirtualPad();

		virtualPad = new FlxVirtualPad(DPad, Action);
		add(virtualPad);

		controls.setVirtualPad(virtualPad, DPad, Action);
		trackedInputsVirtualPad = controls.trackedInputsUI;
		controls.trackedInputsUI = [];
	}

	public function removeVirtualPad():Void
	{
		if (trackedInputsVirtualPad.length > 0)
			controls.removeVirtualControlsInput(trackedInputsVirtualPad);

		if (virtualPad != null)
			remove(virtualPad);
	}

	public function addMobileControls(DefaultDrawTarget:Bool = true):Void
	{
		if (mobileControls != null)
			removeMobileControls();

		mobileControls = new MobileControls();

		switch (MobileControls.mode)
		{
			case 'Pad-Right' | 'Pad-Left' | 'Pad-Custom':
				controls.setVirtualPad(mobileControls.virtualPad, RIGHT_FULL, NONE);
			case 'Pad-Duo':
				controls.setVirtualPad(mobileControls.virtualPad, BOTH_FULL, NONE);
			case 'Hitbox':
				controls.setHitbox(mobileControls.hitbox);
			case 'Keyboard': // do nothing
		}

		trackedInputsMobileControls = controls.trackedInputsUI;
		controls.trackedInputsUI = [];

		var camControls:FlxCamera = new FlxCamera();
		camControls.bgColor.alpha = 0;
		FlxG.cameras.add(camControls, DefaultDrawTarget);

		mobileControls.cameras = [camControls];
		mobileControls.visible = false;
		add(mobileControls);
	}

	public function removeMobileControls():Void
	{
		if (trackedInputsMobileControls.length > 0)
			controls.removeVirtualControlsInput(trackedInputsMobileControls);

		if (mobileControls != null)
			remove(mobileControls);
	}

	public function addVirtualPadCamera(DefaultDrawTarget:Bool = true):Void
	{
		if (virtualPad != null)
		{
			var camControls:FlxCamera = new FlxCamera();
			camControls.bgColor.alpha = 0;
			FlxG.cameras.add(camControls, DefaultDrawTarget);
			virtualPad.cameras = [camControls];
		}
	}

	override function create()
	{
		instance = this;
		destroySubStates = false;
		var skip:Bool = FlxTransitionableState.skipNextTransOut;

		if (!skip)
		{
			openSubState(new CustomFadeTransition(0.6, true));
		}
		fullscreenBind = FlxKey.fromString(Std.string(FlxG.save.data.fullscreenBind));
		FlxTransitionableState.skipNextTransOut = false;

		super.create();
		TimingStruct.clearTimings();

		CustomNoteHelpers.Skin.updateNoteskins();
		CustomNoteHelpers.Splash.updateNotesplashes();

		FlxG.stage.window.borderless = FlxG.save.data.borderless;

		Main.gameContainer.setFPSCap(FlxG.save.data.fpsCap);
	}

	override function destroy()
	{
		if (trackedInputsMobileControls.length > 0)
			controls.removeVirtualControlsInput(trackedInputsMobileControls);

		if (trackedInputsVirtualPad.length > 0)
			controls.removeVirtualControlsInput(trackedInputsVirtualPad);

		super.destroy();

		if (virtualPad != null)
			virtualPad = FlxDestroyUtil.destroy(virtualPad);

		if (mobileControls != null)
			mobileControls = FlxDestroyUtil.destroy(mobileControls);

		if (!PlayState.inDaPlay)
		{
			for (rateData in FreeplayState.songRating.keys())
				rateData = null;

			for (opRateData in FreeplayState.songRatingOp.keys())
				opRateData = null;

			FreeplayState.songRating.clear();
			FreeplayState.songRatingOp.clear();

			FreeplayState.loadedSongData = false;
		}

		curTiming = null;

		if (subStates != null)
		{
			while (subStates.length > 5)
			{
				var subState:MusicBeatSubstate = subStates[0];
				if (subState != null)
				{
					Debug.logTrace('Destroying Substates!');
					subStates.remove(subState);
					subState.destroy();
				}
				subState = null;
			}

			subStates.resize(0);
		}
	}

	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Std.isOfType(Object, FlxSprite))
			var spr:FlxSprite = cast(Object, FlxSprite);

		// Debug.logTrace(Object);
		var result = super.add(Object);
		return result;
	}

	override function update(elapsed:Float)
	{
		if (curDecimalBeat < 0)
			curDecimalBeat = 0;

		if (Conductor.songPosition < 0)
			curDecimalBeat = 0;
		else
		{
			if (curTiming == null)
			{
				setFirstTiming();
			}
			if (curTiming != null)
			{
				/* Not necessary to get a timing every frame if it's the same one. Instead if the current timing endBeat is equal or greater
					than the current Beat meaning that the timing ended the game will check for a new timing (for bpm change events basically), 
					and also to get a lil more of performance */

				if (curDecimalBeat > curTiming.endBeat)
				{
					Debug.logTrace('Current Timing ended, checking for next Timing...');
					curTiming = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
					step = ((60 / curTiming.bpm) * 1000) / 4;
					startInMS = (curTiming.startTime * 1000);
				}

				#if debug
				FlxG.watch.addQuick("conductorTimingSeg", curTiming.bpm);
				#end

				curDecimalBeat = TimingStruct.getBeatFromTime(Conductor.songPosition);

				curBeat = Math.floor(curDecimalBeat);
				curStep = Math.floor(curDecimalBeat * 4);

				// Bromita uwu
				try
				{
					if (currentSection == null)
					{
						currentSection = getSectionByTime(Conductor.songPosition);
						if (activeSong != null)
							curSection = activeSong.notes.indexOf(currentSection);
					}

					if (currentSection != null)
					{
						if (Conductor.songPosition >= currentSection.endTime || Conductor.songPosition < currentSection.startTime)
						{
							currentSection = getSectionByTime(Conductor.songPosition);
							if (activeSong != null)
								curSection = activeSong.notes.indexOf(currentSection);
						}
					}
				}
				catch (e)
				{
					// Debug.logError('Section is null you fucking dumbass uninstall Flixel and kys');
				}

				if (oldSection != curSection)
				{
					sectionHit();
					oldSection = curSection;
				}

				if (oldStep != curStep)
				{
					stepHit();
					oldStep = curStep;
				}
			}
			else
			{
				curDecimalBeat = (((Conductor.songPosition / 1000))) * (Conductor.bpm / 60);

				curBeat = Math.floor(curDecimalBeat);
				curStep = Math.floor(curDecimalBeat * 4);

				// Bromita uwu
				try
				{
					if (currentSection == null)
					{
						currentSection = getSectionByTime(0);
						curSection = 0;
					}

					if (currentSection != null)
					{
						if (Conductor.songPosition >= currentSection.endTime || Conductor.songPosition < currentSection.startTime)
						{
							currentSection = getSectionByTime(Conductor.songPosition);
							curSection = activeSong.notes.indexOf(currentSection);
						}
					}
				}
				catch (e)
				{
					// Debug.logError('Section is null you fucking dumbass uninstall Flixel and kys');
				}

				if (oldSection != curSection)
				{
					sectionHit();
					oldSection = curSection;
				}

				if (oldStep != curStep)
				{
					stepHit();
					oldStep = curStep;
				}
			}
		}

		if (FlxG.keys.anyJustPressed([fullscreenBind]))
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		// Main.gameContainer.setFPSCap(FlxG.save.data.fpsCap);

		super.update(elapsed);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}

	function getSectionByTime(ms:Float):SwagSection
	{
		if (activeSong == null)
			return null;

		if (activeSong.notes == null)
			return null;

		for (i in activeSong.notes)
		{
			if (ms >= i.startTime && ms < i.endTime)
			{
				return i;
			}
		}
		return null;
	}

	function recalculateAllSectionTimes(startIndex:Int = 0)
	{
		if (activeSong == null)
			return;

		for (i in startIndex...activeSong.notes.length) // loops through sections
		{
			var section:SwagSection = activeSong.notes[i];

			var currentBeat:Float = 0.0;

			currentBeat = (section.lengthInSteps / 4) * (i + 1);

			for (k in 0...i)
				currentBeat -= ((section.lengthInSteps / 4) - (activeSong.notes[k].lengthInSteps / 4));

			section.endTime = TimingStruct.getTimeFromBeat(currentBeat);

			if (i != 0)
				section.startTime = activeSong.notes[i - 1].endTime;
			else
				section.startTime = 0;
		}
	}

	private function setFirstTiming()
	{
		curTiming = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
		if (curTiming != null)
		{
			step = ((60 / curTiming.bpm) * 1000) / 4;
			startInMS = (curTiming.startTime * 1000);
		}
	}

	public function sectionHit():Void
	{
	}

	public static function switchState(nextState:FlxState)
	{
		MusicBeatState.switchingState = true;
		// Custom made Trans in
		Main.mainClassState = Type.getClass(nextState);
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if (!FlxTransitionableState.skipNextTransIn)
		{
			leState.openSubState(new CustomFadeTransition(0.3, false));
			if (nextState == FlxG.state)
			{
				CustomFadeTransition.finishCallback = function()
				{
					resetState();
				};
			}
			else
			{
				CustomFadeTransition.finishCallback = function()
				{
					MusicBeatState.switchingState = false;
					FlxG.switchState(nextState);
				};
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState()
	{
		FlxG.resetState();
	}

	public inline static function getState():MusicBeatState
		return cast(FlxG.state, MusicBeatState);
}
