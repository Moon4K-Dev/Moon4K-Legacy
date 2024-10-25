package states;

import states.Freeplay;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flixel.system.FlxSound;
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

		var score = PlayState.instance.songScore;

		comboText = new FlxText(20, -75, 0, 'Judgements:\nScore: ${PlayState.instance.songScore}\nMisses - ${PlayState.instance.misses}
        ');
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
		comboText.color = FlxColor.WHITE;
		totalhit.scrollFactor.set();
		add(totalhit);

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
		FlxTween.tween(comboText, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(contText, {y: FlxG.height - 45}, 0.5, {ease: FlxEase.expoInOut});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();

		#if desktop
		if (PlayState.instance.misses == 0) {
			Main.gjToastManager.createToast(null, "A Full Combo???", "You got a full combo on any song!");
			GameJoltAPI.getTrophy(240116);
		}

		if (PlayState.instance.misses == 0
			&& PlayState.instance.pfc == true
			&& PlayState.instance.curSong == 'run-insane'
			&& !Options.getData('botplay'))
			Main.gjToastManager.createToast(null, "How the fuck.", "You got a perfect full combo on Run Insane....");
		// GameJoltAPI.getTrophy(); // todo: make trophy for dis lol!
		#end
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
