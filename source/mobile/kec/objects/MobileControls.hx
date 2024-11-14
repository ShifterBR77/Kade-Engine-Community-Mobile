/*
 * Copyright (C) 2024 Mobile Porting Team
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
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
