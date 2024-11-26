package ui;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import states.PlayState;
import game.Note;
import flixel.math.FlxMath;

class UI extends FlxSpriteGroup {
	private var scoreTxt:FlxText;
	private var notesHitTXT:FlxText;
	private var accTxt:FlxText;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songTimerTxt:FlxText;
	private var p2ScoreTxt:FlxText;
	private var p2AccTxt:FlxText;

	public function new() {
		super();

		var textWidth:Int = 300;
		var textPadding:Int = 10;
		var isDownscroll:Bool = Options.getData('downscroll');
		
		var textStartY:Int;
		if (PlayState.instance.isMultiplayer) {
			textStartY = isDownscroll ? 30 : FlxG.height - 120;
		} else {
			textStartY = isDownscroll ? FlxG.height - 120 : 30;
		}

		healthBarBG = new FlxSprite(FlxG.width - 160, isDownscroll ? FlxG.height - 30 : textPadding);
		healthBarBG.makeGraphic(150, 10, FlxColor.BLACK);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 2, healthBarBG.y + 2, LEFT_TO_RIGHT, 146, 6, PlayState.instance, 'health', 0, 1);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFFFFFF, 0x00FFFFFF);
		add(healthBar);

		if (PlayState.instance.isMultiplayer) {
			p2ScoreTxt = new FlxText(20, textStartY, textWidth, "P2 Score: 0", 20);
			p2ScoreTxt.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.BLUE, FlxTextAlign.LEFT);
			p2ScoreTxt.scrollFactor.set();
			p2ScoreTxt.wordWrap = false;
			add(p2ScoreTxt);
			
			p2AccTxt = new FlxText(20, textStartY + 30, textWidth, "P2 Accuracy: 0%", 20);
			p2AccTxt.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.BLUE, FlxTextAlign.LEFT);
			p2AccTxt.scrollFactor.set();
			p2AccTxt.wordWrap = false;
			add(p2AccTxt);
			
			scoreTxt = new FlxText(FlxG.width - textWidth - textPadding, textStartY, textWidth, "P1 Score: 0", 20);
			scoreTxt.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
			scoreTxt.scrollFactor.set();
			scoreTxt.wordWrap = false;
			add(scoreTxt);

			notesHitTXT = new FlxText(FlxG.width - textWidth - textPadding, textStartY + 30, textWidth, "0x", 20);
			notesHitTXT.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
			notesHitTXT.scrollFactor.set();
			notesHitTXT.wordWrap = false;
			notesHitTXT.visible = false;
			add(notesHitTXT);

			accTxt = new FlxText(FlxG.width - textWidth - textPadding, textStartY + 60, textWidth, "P1 Accuracy: 0%", 20);
			accTxt.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
			accTxt.scrollFactor.set();
			accTxt.wordWrap = false;
			add(accTxt);
		} else {
			scoreTxt = new FlxText(FlxG.width - textWidth - textPadding, textStartY, textWidth, "Score: 0", 20);
			scoreTxt.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
			scoreTxt.scrollFactor.set();
			scoreTxt.wordWrap = false;
			add(scoreTxt);

			notesHitTXT = new FlxText(FlxG.width - textWidth - textPadding, textStartY + 30, textWidth, "0x", 20);
			notesHitTXT.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
			notesHitTXT.scrollFactor.set();
			notesHitTXT.wordWrap = false;
			notesHitTXT.visible = true;
			add(notesHitTXT);

			accTxt = new FlxText(FlxG.width - textWidth - textPadding, textStartY + 60, textWidth, "Accuracy: 0%", 20);
			accTxt.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
			accTxt.scrollFactor.set();
			accTxt.wordWrap = false;
			add(accTxt);
		}

		var timerY:Float = isDownscroll ? 50 : FlxG.height - 30;
		songTimerTxt = new FlxText(FlxG.width - textWidth - textPadding, timerY, textWidth, "0:00 / 0:00", 20);
		songTimerTxt.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
		songTimerTxt.scrollFactor.set();
		songTimerTxt.wordWrap = false;
		add(songTimerTxt);
	}

	override public function update(elapsed:Float) {
		updateText();
		updateHealthBar();
		super.update(elapsed);
	}

	public function updateText() {
		if (PlayState.instance.isMultiplayer) {
			scoreTxt.text = "P1 Score: " + PlayState.instance.p1Score;
			accTxt.text = "P1 Accuracy: " + Std.string(FlxMath.roundDecimal(PlayState.instance.p1Accuracy, 2)) + "%";
			notesHitTXT.visible = false;

			p2ScoreTxt.text = "P2 Score: " + PlayState.instance.p2Score;
			p2AccTxt.text = "P2 Accuracy: " + Std.string(FlxMath.roundDecimal(PlayState.instance.p2Accuracy, 2)) + "%";
		} else {
			scoreTxt.text = "Score: " + PlayState.instance.songScore;
			notesHitTXT.text = PlayState.instance.notesHit + "x";
			accTxt.text = "Accuracy: " + Std.string(FlxMath.roundDecimal(PlayState.instance.accuracy, 2)) + "%";
		}

		if (FlxG.sound.music != null && FlxG.sound.music.playing) {
			var currentTime:Float = FlxG.sound.music.time / 1000;
			var totalTime:Float = FlxG.sound.music.length / 1000;
			songTimerTxt.text = formatTime(currentTime) + " / " + formatTime(totalTime);
		} else {
			songTimerTxt.text = "0:00 / 0:00";
		}
	}

	public function updateHealthBar() {
		if (PlayState.instance != null) {
			healthBar.percent = PlayState.instance.health * 50;
		}
	}

	private function formatTime(seconds:Float):String {
		var minutes:Int = Std.int(seconds / 60);
		var remainingSeconds:Int = Std.int(seconds % 60);
		return minutes + ":" + (remainingSeconds < 10 ? "0" : "") + remainingSeconds;
	}
}
