package states;

import states.Freeplay;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flixel.sound.FlxSound;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;
import openfl.OFLSprite;

using StringTools;

class ResultsState extends SwagState {
	public var background:FlxSprite;
	public var text:FlxText;

	public var anotherBackground:FlxSprite;
	public var graphSprite:OFLSprite;

	public var comboText:FlxText;
	public var contText:FlxText;
	public var settingsText:FlxText;

	public var music:FlxSound;

	public var graphData:BitmapData;

	public var ranking:String;
	public var accuracy:String;

	override function create() {
		FlxG.sound.music.stop();
		#if desktop
		Discord.changePresence("Viewing their results!", null);
		#end

		background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.scrollFactor.set();
		add(background);

		background.alpha = 0;

		text = new FlxText(20, -55, 0, "Song Complete!");
		text.size = 34;
		text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		text.color = FlxColor.WHITE;
		text.scrollFactor.set();
		add(text);

		if (PlayState.instance.islocalMultiplayer) {
			var p1Text = new FlxText(20, -75, FlxG.width / 2 - 40, 'Player 1:\nScore: ${PlayState.instance.p1Score}'
				+ '\nMisses: ${PlayState.instance.p1Misses}'
				+ '\nAccuracy: ${FlxMath.roundDecimal(PlayState.instance.p1Accuracy, 2)}%');
			p1Text.size = 28;
			p1Text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
			p1Text.color = FlxColor.WHITE;
			p1Text.scrollFactor.set();
			add(p1Text);

			var p2Text = new FlxText(FlxG.width / 2
				+ 20, -75, FlxG.width / 2
				- 40,
				'Player 2:\nScore: ${PlayState.instance.p2Score}'
				+ '\nMisses: ${PlayState.instance.p2Misses}'
				+ '\nAccuracy: ${FlxMath.roundDecimal(PlayState.instance.p2Accuracy, 2)}%');
			p2Text.size = 28;
			p2Text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
			p2Text.color = FlxColor.BLUE;
			p2Text.scrollFactor.set();
			add(p2Text);

			var winnerText = new FlxText(20, -125, FlxG.width - 40);
			if (PlayState.instance.p1Score > PlayState.instance.p2Score) {
				winnerText.text = "Player 1 Wins!";
				winnerText.color = FlxColor.WHITE;
			} else if (PlayState.instance.p2Score > PlayState.instance.p1Score) {
				winnerText.text = "Player 2 Wins!";
				winnerText.color = FlxColor.BLUE;
			} else {
				winnerText.text = "It's a Tie!";
				winnerText.color = FlxColor.YELLOW;
			}
			winnerText.size = 32;
			winnerText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
			winnerText.alignment = CENTER;
			winnerText.scrollFactor.set();
			add(winnerText);

			FlxTween.tween(winnerText, {y: 80}, 0.5, {ease: FlxEase.expoInOut});
			FlxTween.tween(p1Text, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
			FlxTween.tween(p2Text, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
		} else {
			comboText = new FlxText(20, -75, 0, 'Judgements:\nScore: ${PlayState.instance.songScore}\nMisses - ${PlayState.instance.misses}');
			comboText.size = 28;
			comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
			comboText.color = FlxColor.WHITE;
			comboText.scrollFactor.set();
			add(comboText);

			var accuracylol:FlxText = new FlxText(20, -105, 0, 'Accuracy: ' + PlayState.instance.accuracy);
			accuracylol.size = 28;
			accuracylol.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
			accuracylol.color = FlxColor.WHITE;
			accuracylol.scrollFactor.set();
			add(accuracylol);

			var totalhit:FlxText = new FlxText(20, -125, 0, 'Total Notes Hit: ' + PlayState.instance.totalNotesHit);
			totalhit.size = 28;
			totalhit.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
			totalhit.color = FlxColor.WHITE;
			totalhit.scrollFactor.set();
			add(totalhit);

			FlxTween.tween(comboText, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
			FlxTween.tween(accuracylol, {y: 215}, 0.5, {ease: FlxEase.expoInOut});
			FlxTween.tween(totalhit, {y: 255}, 0.5, {ease: FlxEase.expoInOut});
		}

		contText = new FlxText(FlxG.width - 475, FlxG.height + 50, 0, 'Press ENTER to continue.');
		contText.size = 28;
		contText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		contText.color = FlxColor.WHITE;
		contText.scrollFactor.set();
		add(contText);

		anotherBackground = new FlxSprite(FlxG.width - 500, 45).makeGraphic(450, 240, FlxColor.BLACK);
		anotherBackground.scrollFactor.set();
		anotherBackground.alpha = 0;
		add(anotherBackground);

		FlxTween.tween(background, {alpha: 0.5}, 0.5);
		FlxTween.tween(text, {y: 20}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(contText, {y: FlxG.height - 45}, 0.5, {ease: FlxEase.expoInOut});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}

	var frames = 0;

	override function update(elapsed:Float) {
		FlxG.sound.music.stop();
		if (FlxG.keys.justPressed.ENTER) {
			FlxG.sound.music.stop();
			FlxG.switchState(new Freeplay());
		}
		super.update(elapsed);
	}
}
