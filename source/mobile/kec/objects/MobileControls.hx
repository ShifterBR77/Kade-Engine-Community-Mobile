package mobile.kec.objects;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import mobile.flixel.FlxButton;
import mobile.kec.objects.Hitbox;
import mobile.flixel.FlxVirtualPad;

/**
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class MobileControls extends FlxSpriteGroup
{
	public static var customVirtualPad(get, set):FlxVirtualPad;
	public static var mode(get, set):String;
	public static var enabled(get, never):Bool;

	public var virtualPad:FlxVirtualPad;
	public var hitbox:Hitbox;

	public var onInputUp:FlxTypedSignal<FlxButton->Void> = new FlxTypedSignal<FlxButton->Void>();
	public var onInputDown:FlxTypedSignal<FlxButton->Void> = new FlxTypedSignal<FlxButton->Void>();

	public function new()
	{
		super();

		switch (MobileControls.mode)
		{
			case 'Pad-Right':
				virtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
				bindVPadDirections(virtualPad);
				virtualPad.onButtonUp.add(onInputUp.dispatch);
				virtualPad.onButtonDown.add(onInputDown.dispatch);
				add(virtualPad);
			case 'Pad-Left':
				virtualPad = new FlxVirtualPad(LEFT_FULL, NONE);
				bindVPadDirections(virtualPad);
				virtualPad.onButtonUp.add(onInputUp.dispatch);
				virtualPad.onButtonDown.add(onInputDown.dispatch);
				add(virtualPad);
			case 'Pad-Custom':
				virtualPad = MobileControls.customVirtualPad;
				bindVPadDirections(virtualPad);
				virtualPad.onButtonUp.add(onInputUp.dispatch);
				virtualPad.onButtonDown.add(onInputDown.dispatch);
				add(virtualPad);
			case 'Hitbox':
				hitbox = new Hitbox(4, Std.int(FlxG.width / 4), FlxG.height, [0xFF00FF, 0x00FFFF, 0x00FF00, 0xFF0000]);
				bindHitboxDirections(hitbox);
				hitbox.onHintUp.add(onInputUp.dispatch);
				hitbox.onHintDown.add(onInputDown.dispatch);
				add(hitbox);
			default: // do nothing
		}
	}

	override public function destroy():Void
	{
		super.destroy();

		if (virtualPad != null)
			virtualPad = FlxDestroyUtil.destroy(virtualPad);

		if (hitbox != null)
			hitbox = FlxDestroyUtil.destroy(hitbox);
	}

	private static function get_mode():String
	{
		return FlxG.save.data.mobileCMode;
	}

	private static function set_mode(mode:String = 'Hitbox'):String
	{
		FlxG.save.data.mobileCMode = mode;
		FlxG.save.flush();

		return mode;
	}

	private static function get_customVirtualPad():FlxVirtualPad
	{
		var virtualPad:FlxVirtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
		if (FlxG.save.data.buttons == null)
			return virtualPad;

		var tempCount:Int = 0;
		for (buttons in virtualPad)
		{
			buttons.x = FlxG.save.data.buttons[tempCount].x;
			buttons.y = FlxG.save.data.buttons[tempCount].y;
			tempCount++;
		}

		return virtualPad;
	}

	private static function set_customVirtualPad(virtualPad:FlxVirtualPad):FlxVirtualPad
	{
		if (FlxG.save.data.buttons == null)
		{
			FlxG.save.data.buttons = new Array();
			for (buttons in virtualPad)
			{
				FlxG.save.data.buttons.push(FlxPoint.get(buttons.x, buttons.y));
				FlxG.save.flush();
			}
		}
		else
		{
			var tempCount:Int = 0;
			for (buttons in virtualPad)
			{
				FlxG.save.data.buttons[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				FlxG.save.flush();
				tempCount++;
			}
		}

		return virtualPad;
	}

	private static function get_enabled():Bool
		return FlxG.save.data.mobileCAlpha >= 0.1;

	private static function bindVPadDirections(vpad:FlxVirtualPad)
	{
		vpad.buttonLeft.bindedDirection = LEFT;
		vpad.buttonDown.bindedDirection = DOWN;
		vpad.buttonUp.bindedDirection = UP;
		vpad.buttonRight.bindedDirection = RIGHT;
		vpad.buttonLeft2.bindedDirection = LEFT;
		vpad.buttonDown2.bindedDirection = DOWN;
		vpad.buttonUp2.bindedDirection = UP;
		vpad.buttonRight2.bindedDirection = RIGHT;
	}

	private static function bindHitboxDirections(hitbox:Hitbox)
	{
		hitbox.hints[0].bindedDirection = LEFT;
		hitbox.hints[1].bindedDirection = DOWN;
		hitbox.hints[2].bindedDirection = UP;
		hitbox.hints[3].bindedDirection = RIGHT;
	}
}
