package api.newgrounds;

import states.SwagState;
import flixel.text.FlxText;
import flixel.FlxState;
import api.newgrounds.NGio;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class NGLogin extends SwagState {
	override public function create() {
		FlxG.stage.window.title = "YA4KRG - NGLogin";
		#if desktop
		Discord.changePresence("Logging into Newgrounds :D", null);
		#end

		var coolBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/menubglol'), XY, 0.2, 0);
		coolBackdrop.velocity.set(50, 30);
		coolBackdrop.alpha = 0.7;
		add(coolBackdrop);

		var text = new FlxText(0, 0, 0, "Logging into Newgrounds...", 64);
		text.screenCenter();
		add(text);

		super.create();

		NGio.init();
	}

	override public function update(elapsed:Float) {
		if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
			transitionState(new states.MainMenuState());
		super.update(elapsed);
	}
}
