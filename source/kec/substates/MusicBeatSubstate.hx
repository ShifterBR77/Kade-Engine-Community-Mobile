package kec.substates;

import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
import kec.backend.Controls;
import kec.backend.PlayerSettings;
import kec.backend.chart.TimingStruct;
import mobile.flixel.FlxVirtualPad;

class MusicBeatSubstate extends FlxSubState
{
	public static var instance:MusicBeatSubstate;
	public function new()
	{
		instance = this;
		super();
	}

	override function destroy()
	{
		/*Application.current.window.onFocusIn.remove(onWindowFocusOut);
			Application.current.window.onFocusIn.remove(onWindowFocusIn); */

		// Mobile Controls Related
		if (trackedInputsMobileControls.length > 0)
			controls.removeVirtualControlsInput(trackedInputsMobileControls);

		if (trackedInputsVirtualPad.length > 0)
			controls.removeVirtualControlsInput(trackedInputsVirtualPad);

		if (virtualPad != null)
			virtualPad = FlxDestroyUtil.destroy(virtualPad);

		if (mobileControls != null)
			mobileControls = FlxDestroyUtil.destroy(mobileControls);

		if (camControls != null)
			camControls = FlxDestroyUtil.destroy(camControls);

		if (camVPad != null)
			camVPad = FlxDestroyUtil.destroy(camVPad);

		super.destroy();
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

	public var mobileControls:MobileControls;
	public var virtualPad:FlxVirtualPad;
	public var camControls:FlxCamera;
	public var camVPad:FlxCamera;

	var trackedInputsMobileControls:Array<FlxActionInput> = [];
	var trackedInputsVirtualPad:Array<FlxActionInput> = [];

	public function addVirtualPad(DPad:FlxDPadMode, Action:FlxActionMode):Void
	{
		if (virtualPad != null)
			removeVirtualPad();

		virtualPad = new FlxVirtualPad(DPad, Action);
		add(virtualPad);

		controls.setVirtualPadUI(virtualPad, DPad, Action);
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

	public function addMobileControls(DefaultDrawTarget:Bool = false):Void
	{
		if (mobileControls != null)
			removeMobileControls();

		mobileControls = new MobileControls();

		switch (MobileControls.mode)
		{
			case 'Pad-Right' | 'Pad-Left' | 'Pad-Custom':
				controls.setVirtualPadNOTES(mobileControls.virtualPad, RIGHT_FULL, NONE);
			case 'Hitbox':
				controls.setHitbox(mobileControls.hitbox);
			default: // do nothing
		}

		trackedInputsMobileControls = controls.trackedInputsNOTES;
		controls.trackedInputsNOTES = [];

		camControls = new FlxCamera();
		camControls.bgColor.alpha = 0;
		FlxG.cameras.add(camControls, DefaultDrawTarget);

		mobileControls.cameras = [camControls];
		mobileControls.visible = false;
		add(mobileControls);
	}

	public function removeMobileControls()
	{
		if (trackedInputsMobileControls.length > 0)
			controls.removeVirtualControlsInput(trackedInputsMobileControls);

		if (mobileControls != null)
			remove(mobileControls);
	}

	public function addVirtualPadCamera(DefaultDrawTarget:Bool = false):Void
	{
		if (virtualPad == null)
			return;

		camVPad = new FlxCamera();
		camVPad.bgColor.alpha = 0;
		FlxG.cameras.add(camVPad, DefaultDrawTarget);
		virtualPad.cameras = [camVPad];
	}

	var oldStep:Int = 0;

	var curDecimalBeat:Float = 0;

	override function update(elapsed:Float)
	{
		curDecimalBeat = (((Conductor.songPosition / 1000))) * (Conductor.bpm / 60);
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
