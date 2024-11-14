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

package mobile.kec.backend;

import flixel.util.FlxSave;

class KEMobileData
{
	public static function initSave()
	{
		if (FlxG.save.data.mobileCMode == null)
			FlxG.save.data.mobileCMode = 'Hitbox';

		if (FlxG.save.data.mobileCAlpha == null)
			FlxG.save.data.mobileCAlpha = #if mobile 0.6 #else 0 #end;

		if (FlxG.save.data.hitboxType == null)
			FlxG.save.data.hitboxType = 0;
	}
}
