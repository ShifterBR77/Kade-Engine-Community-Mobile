package kec.substates;

import kec.backend.chart.Section.SwagSection;
import kec.backend.chart.Song.SongData;
import kec.backend.chart.TimingStruct;
import kec.backend.Controls;
import kec.backend.PlayerSettings;
import mobile.flixel.FlxVirtualPad;
import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	override function destroy()
	{
		/*Application.current.window.onFocusIn.remove(onWindowFocusOut);
			Application.current.window.onFocusIn.remove(onWindowFocusIn); */

		if (trackedInputsVirtualPad.length > 0)
			controls.removeVirtualControlsInput(trackedInputsVirtualPad);

		super.destroy();

		if (virtualPad != null)
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
	}

	override function create()
	{
		FlxG.mouse.enabled = true;
		super.create();
		/*Application.current.window.onFocusIn.add(onWindowFocusIn);
			Application.current.window.onFocusOut.add(onWindowFocusOut); */
	}

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public var vpadCam:FlxCamera;
	var virtualPad:FlxVirtualPad;
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

		if (vpadCam != null)
		{
			FlxG.cameras.remove(vpadCam, false);
			vpadCam = FlxDestroyUtil.destroy(vpadCam);
		}
	}

	public function addVirtualPadCamera(defaultDrawTarget:Bool = false):Void
	{
		if (virtualPad == null || vpadCam != null)
			return;

		vpadCam = new FlxCamera();
		FlxG.cameras.add(vpadCam, defaultDrawTarget);
		vpadCam.bgColor.alpha = 0;
		virtualPad.cameras = [vpadCam];
	}

	var oldStep:Int = 0;

	var curDecimalBeat:Float = 0;

	override function update(elapsed:Float)
	{
		curDecimalBeat = (((Conductor.songPosition * 0.001))) * (Conductor.bpm / 60);
		curBeat = Math.floor(curDecimalBeat);
		curStep = Math.floor(curDecimalBeat * 4);

		if (oldStep != curStep)
		{
			stepHit();
			oldStep = curStep;
		}
		
		super.update(elapsed);

		var fullscreenBind = FlxKey.fromString(FlxG.save.data.fullscreenBind);

		if (FlxG.keys.anyJustPressed([fullscreenBind]))
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}
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
}
