package mobile;

import Options.Option;

class MobileControlsOption extends Option
{
	public function new(desc:String)
	{
		super();
		acceptType = true;
		description = desc;
		if (OptionsMenu.isInPause)
		{
			blocked = true;
			description = pauseDesc;
		}
	}

	public override function press():Bool
	{
		if (OptionsMenu.isInPause)
			return false;
		FlxG.state.openSubState(new mobile.MobileControlsSubState());
		return true;
	}

	private override function updateDisplay():String
	{
		return "Mobile Controls";
	}
}