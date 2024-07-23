package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.system.System;
import options.Controls;
import options.Options;
import flixel.ui.FlxButton;

class MainMenuState extends SwagState {
	override public function create() {
		FlxG.mouse.visible = true;
		FlxG.stage.window.title = "YA4KRG Demo - MainMenuState";
		Discord.changePresence("In the Main Menu!", null);

		var swagbg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/bg'));
		swagbg.setGraphicSize(Std.int(swagbg.width * 1.1));
		swagbg.updateHitbox();
		swagbg.screenCenter();
		swagbg.visible = true;
		swagbg.antialiasing = true;
		add(swagbg);

		var buttonGraphic:FlxSprite = new FlxSprite().loadGraphic("assets/images/mainmenu/button.png");

		var singlePlayerButton:FlxButton = new FlxButton(0, 0, "", function() {
			transitionState(new states.Freeplay());
		});
		singlePlayerButton.loadGraphic(buttonGraphic.graphic, false, 80, 20);
		singlePlayerButton.label.setFormat(Paths.font('vcr.ttf'), 14, FlxColor.PURPLE, "center", FlxColor.PURPLE);
		singlePlayerButton.label.text = "Solo";
		singlePlayerButton.x = (FlxG.width / 2) - singlePlayerButton.width - 50;
		singlePlayerButton.y = FlxG.height / 1.3 - singlePlayerButton.height / 1.3;
		add(singlePlayerButton);

		var optionsButton:FlxButton = new FlxButton(0, 0, "", function() {
			transitionState(new states.OptionSelectState());
		});
		optionsButton.loadGraphic(buttonGraphic.graphic, false, 80, 20);
		optionsButton.label.setFormat(Paths.font('vcr.ttf'), 14, FlxColor.PURPLE, "center", FlxColor.PURPLE);
		optionsButton.label.text = "Settings";
		optionsButton.x = (FlxG.width / 2) + 50;
		optionsButton.y = FlxG.height / 1.3 - optionsButton.height / 1.3;
		add(optionsButton);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "YA4KRG" + Utils.VERSION, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		super.create();
	}

	override public function update(elapsed:Float) {

		if (FlxG.keys.justPressed.SEVEN)
		{
			//transitionState(new states.OnlineDLState());
		}
		super.update(elapsed);
	}
}
