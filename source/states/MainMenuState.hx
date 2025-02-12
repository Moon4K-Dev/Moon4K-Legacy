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
	private var buttons:Array<FlxText>;
	private var titlesprite:FlxSprite;
	private var randomhaxesprite:FlxSprite;
	private var stars:FlxTypedGroup<FlxSprite>;
	private var currentSelection:Int = 0;
	private var menuItems:Array<String> = [
		"Local",
		"Online",
		#if desktop "Download Charts", "Profile", #end
		"Options",
		"Exit"
	];

	override public function create() {
		FlxG.mouse.visible = true;
		FlxG.stage.window.title = "Moon4K - MainMenuState";
		#if desktop
		Discord.changePresence("In the Main Menu!", null);
		#end

		stars = new FlxTypedGroup<FlxSprite>();
		for (i in 0...100) {
			var star = new FlxSprite(FlxG.random.float(0, FlxG.width), FlxG.random.float(0, FlxG.height));
			star.makeGraphic(2, 2, FlxColor.WHITE);
			star.alpha = FlxG.random.float(0.3, 1);
			stars.add(star);
		}
		add(stars);

		randomhaxesprite = new FlxSprite(FlxG.width * 0.7, FlxG.height * 0.3).loadGraphic(Paths.image(''));
		randomhaxesprite.scale.set(0.5, 0.5);
		randomhaxesprite.updateHitbox();
		randomhaxesprite.antialiasing = true;
		add(randomhaxesprite);

		titlesprite = new FlxSprite(0, -50).loadGraphic(Paths.image(''));
		titlesprite.scale.set(0.25, 0.25);
		titlesprite.updateHitbox();
		titlesprite.screenCenter(X);
		// add(titlesprite);

		buttons = [];
		for (i in 0...menuItems.length) {
			var yPos = (FlxG.height * 0.5) + (i * 60);
			var txt = new FlxText(0, yPos, FlxG.width, menuItems[i]);
			txt.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER);
			txt.ID = i;
			txt.screenCenter(X);
			buttons.push(txt);
			add(txt);
		}

		FlxTween.tween(titlesprite, {y: 50}, 1, {ease: FlxEase.elasticOut});
		FlxTween.tween(randomhaxesprite, {y: FlxG.height * 0.25}, 2, {ease: FlxEase.sineInOut, type: PINGPONG});

		var devcred:FlxText = new FlxText(5, FlxG.height - 37, 0, "Moon4K by: YoPhlox, MaybeKoi, Lost, and Joalor64GH", 12);
		devcred.scrollFactor.set();
		devcred.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
		add(devcred);

		var versionShit:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width - 5, "Moon4K v" + Utils.VERSION, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
		add(versionShit);

		changeSelection();

		super.create();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		randomhaxesprite.angle += elapsed * 10;

		for (star in stars) {
			if (FlxG.random.bool(1)) {
				FlxTween.tween(star, {alpha: FlxG.random.float(0.3, 1)}, 0.5);
			}
		}

		if (FlxG.keys.justPressed.UP) {
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN) {
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) {
			transitionState(new TitleState());
		}

		if (FlxG.keys.justPressed.ENTER) {
			switch (menuItems[currentSelection].toLowerCase()) {
				case "local":
					transitionState(new states.Freeplay());
				case "online":
					trace("oogh online!");
				case "download charts":
					transitionState(new states.OnlineDLState());
				case "profile":
					transitionState(new profile.states.ProfileState());
				case "options":
					transitionState(new states.OptionSelectState());
				case "exit":
					System.exit(0);
			}
		}
	}

	function changeSelection(change:Int = 0) {
		currentSelection += change;

		if (currentSelection < 0)
			currentSelection = menuItems.length - 1;
		if (currentSelection >= menuItems.length)
			currentSelection = 0;

		for (i in 0...buttons.length) {
			if (i == currentSelection) {
				buttons[i].color = FlxColor.YELLOW;
				buttons[i].scale.set(1.2, 1.2);
			} else {
				buttons[i].color = FlxColor.WHITE;
				buttons[i].scale.set(1, 1);
			}
			buttons[i].updateHitbox();
			buttons[i].screenCenter(X);
		}
	}
}
