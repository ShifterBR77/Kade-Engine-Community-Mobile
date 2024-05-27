package mobile;

import mobile.flixel.FlxVirtualPad;

class KEMobileData
{
	public static function initSave()
	{
    var virtualPad:FlxVirtualPad = new FlxVirtualPad(RIGHT_FULL, NONE);
		if (FlxG.save.data.buttons == null)
			 return virtualPad;

    if (FlxG.save.data.controlsMode == null)
			FlxG.save.data.controlsMode = 'Hitbox';

		if (FlxG.save.data.mobileCAlpha == null)
      FlxG.save.data.mobileCAlpha = 0.6;

    if (FlxG.save.data.hitboxType == null)
      FlxG.save.data.hitboxType = 0;
	}
}
