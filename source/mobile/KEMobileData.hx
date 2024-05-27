package mobile;

import mobile.flixel.FlxVirtualPad;

class KEMobileData
{
	public static function initSave()
	{
		if (FlxG.save.data.mobileCMode == null)
			FlxG.save.data.mobileCMode = 'Hitbox';

		if (FlxG.save.data.mobileCAlpha == null)
			FlxG.save.data.mobileCAlpha = 0.6;

		if (FlxG.save.data.hitboxType == null)
			FlxG.save.data.hitboxType = 0;
	}
}
