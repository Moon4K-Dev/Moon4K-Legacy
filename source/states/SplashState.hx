package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class SplashState extends SwagState {
	var arrowsexylogo:FlxSprite;
	var funnyText:FlxText;

	static public var titleStarted:Bool = false;

	var curWacky:String;
	private var ptc:FlxText;

	static public var optionsInitialized:Bool = false;
	static public var transitionsAllowed:Bool = false;

	var introTexts:Array<String> = [
		"Look Ma, I'm in a video game!",
		"Swag Swag Cool Shit",
		"I love ninjamuffin99",
		"FNF chart support coming never",
		"I love Ellen Joe Zenless Zone Zero",
		"Follow TyDotCS on twitter!",
		"Inspired by FNF and OSU!Mania",
		"https://example.com",
		"Slide the weed homie.."
	];

	private var timer:FlxTimer;

	override public function create() {
		FlxG.camera.bgColor = 0xFF000000;
		FlxG.stage.window.title = "YA4KRG - SplashState";
		Discord.changePresence("Just booted the game :D", null);

		HighScoreManager.init();
		Options.init();
		optionsInitialized = true;

		GameJoltAPI.connect();
		GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);

		super.create();

		curWacky = FlxG.random.getObject(introTexts);
		trace(curWacky);

		if (!titleStarted) {
			arrowsexylogo = new FlxSprite().loadGraphic(Paths.image('splash/notelogo'));
			arrowsexylogo.screenCenter();
			arrowsexylogo.setGraphicSize(Std.int(arrowsexylogo.width * 0.3));
			arrowsexylogo.antialiasing = true;
			arrowsexylogo.alpha = 0;
			add(arrowsexylogo);

			funnyText = new FlxText(0, 0, 0, "Welcome to YA4KRG (Yet Another 4K Rhythm Game)!!", 24);
			funnyText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
			funnyText.screenCenter();
			funnyText.alpha = 0;
			add(funnyText);

			FlxTween.tween(arrowsexylogo, {y: arrowsexylogo.y - 35, alpha: 1}, 1, {
				ease: FlxEase.cubeOut,
				startDelay: 0.5
			});

			FlxTween.tween(funnyText, {y: funnyText.y + 35, alpha: 1}, 1, {
				ease: FlxEase.cubeOut,
				startDelay: 0.5,
				onComplete: function(twn:FlxTween) {
					FlxTween.tween(funnyText, {alpha: 0}, 1, {
						ease: FlxEase.cubeOut,
						startDelay: 1,
						onComplete: function(twn:FlxTween) {
							funnyText.text = curWacky;
							funnyText.screenCenter(null);
							FlxTween.tween(funnyText, {alpha: 1}, 1, {
								ease: FlxEase.cubeOut
							});
						}
					});
				}
			});
		}
		timer = new FlxTimer();
		timer.start(5.5, onTimerComplete, 3);
	}

	private function onTimerComplete(timer:FlxTimer):Void {
		transitionState(new MainMenuState());
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}
}
