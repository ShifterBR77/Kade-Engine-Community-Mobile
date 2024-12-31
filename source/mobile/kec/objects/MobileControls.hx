/*
 * Copyright (C) 2025 Mobile Porting Team
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package mobile.kec.objects;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;	

/**
 * ...
 * @author Karim Akra and Lily Ross (mcagabe19)
 */
class MobileControls extends FlxSpriteGroup
{
	public static var customVirtualPad(get, set):VirtualPad;
	public static var mode(get, set):String;
	public static var enabled(get, never):Bool;

	public var virtualPad:VirtualPad;
	public var hitbox:Hitbox;

	public var onInputUp:FlxTypedSignal<MobileButton->Void> = new FlxTypedSignal<MobileButton->Void>();
	public var onInputDown:FlxTypedSignal<MobileButton->Void> = new FlxTypedSignal<MobileButton->Void>();

	public function new()
	{
		super();

		switch (MobileControls.mode)
		{
			case 'Pad-Right':
				virtualPad = new VirtualPad(RIGHT_FULL, NONE);
				bindVPadDirections(virtualPad);
				virtualPad.onButtonUp.add(onInputUp.dispatch);
				virtualPad.onButtonDown.add(onInputDown.dispatch);
				add(virtualPad);
			case 'Pad-Left':
				virtualPad = new VirtualPad(LEFT_FULL, NONE);
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
				hitbox = new Hitbox();
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

	private static function get_customVirtualPad():VirtualPad
	{
		var virtualPad:VirtualPad = new VirtualPad(RIGHT_FULL, NONE);
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

	private static function set_customVirtualPad(virtualPad:VirtualPad):VirtualPad
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

	private static function bindVPadDirections(vpad:VirtualPad)
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
		hitbox.buttonLeft.bindedDirection = LEFT;
		hitbox.buttonDown.bindedDirection = DOWN;
		hitbox.buttonUp.bindedDirection = UP;
		hitbox.buttonRight.bindedDirection = RIGHT;
	}
}
