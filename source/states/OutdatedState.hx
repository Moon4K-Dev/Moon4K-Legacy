package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OutdatedState extends SwagState
{
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var ver = "v" + AutoUpdater.CURRENT_VERSION;
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"HEY! You're running an outdated version of Moon4K!\nCurrent version is "
			+ ver
			+ " while the most recent version is "
			+ AutoUpdater.latestVersion
			+ "! Press Enter/Space to update, or ESCAPE to ignore this!!",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			AutoUpdater.downloadUpdate();
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			leftState = true;
			transitionState(new MainMenuState());
		}
		super.update(elapsed);
	}
}