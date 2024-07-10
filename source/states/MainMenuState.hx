package states;

import flixel.text.FlxText;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;
import flixel.FlxG;

class MainMenuState extends FlxState
{
	var coolbackdro:FlxBackdrop;
	var cover:FlxSprite;

	override public function create()
	{
		coolbackdro = new FlxBackdrop(Paths.image('menubglol'), 0.2, 0, true, true);
		coolbackdro.velocity.set(200, 110);
		coolbackdro.updateHitbox();
		coolbackdro.alpha = 0.5;
		coolbackdro.screenCenter(X);
		add(coolbackdro);

		cover = new FlxSprite(-80).loadGraphic(Paths.image('gayluigi'));
		cover.setGraphicSize(Std.int(cover.width * 1.1));
		cover.updateHitbox();
		cover.screenCenter();
		cover.antialiasing = true;
		add(cover);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.switchState(new PlayState());
		}
		super.update(elapsed);
	}
}