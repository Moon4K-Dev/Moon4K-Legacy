package ui;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import states.PlayState;
import game.Note;

class UI extends FlxSpriteGroup {
	private var scoreTxt:FlxText;
	private var notesHitTXT:FlxText;
	private var accTxt:FlxText;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songTimerTxt:FlxText;
	private var laneUnderlay:FlxSprite;

	public function new() {
		super();

		var textWidth:Int = 300;
		var textPadding:Int = 10;
		var textStartY:Int = 30;

		healthBarBG = new FlxSprite(FlxG.width - 160, textPadding);
		healthBarBG.makeGraphic(150, 10, FlxColor.BLACK);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 2, healthBarBG.y + 2, LEFT_TO_RIGHT, 146, 6, PlayState.instance, 'health', 0, 1);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFFFFFF, 0x00FFFFFF);
		add(healthBar);

		scoreTxt = new FlxText(FlxG.width - textWidth - textPadding, textStartY, textWidth, "Score: 0", 20);
		scoreTxt.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.wordWrap = false;
		add(scoreTxt);

		notesHitTXT = new FlxText(FlxG.width - textWidth - textPadding, textStartY + 30, textWidth, "0x", 20);
		notesHitTXT.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		notesHitTXT.scrollFactor.set();
		notesHitTXT.wordWrap = false;
		add(notesHitTXT);

		accTxt = new FlxText(FlxG.width - textWidth - textPadding, textStartY + 60, textWidth, "Accuracy: 0%", 20);
		accTxt.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		accTxt.scrollFactor.set();
		accTxt.wordWrap = false;
		add(accTxt);

		songTimerTxt = new FlxText(FlxG.width - textWidth - textPadding, FlxG.height - 30, textWidth, "0:00 / 0:00", 20);
		songTimerTxt.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songTimerTxt.scrollFactor.set();
		songTimerTxt.wordWrap = false;
		add(songTimerTxt);

		laneUnderlay = new FlxSprite(0,0);
		laneUnderlay.makeGraphic(Std.int(Note.swagWidth * 4), FlxG.height, 0xA4000000);
		laneUnderlay.scrollFactor.set();
		laneUnderlay.screenCenter(X);
		add(laneUnderlay);

		members.remove(laneUnderlay);
		members.insert(0, laneUnderlay);
	}

	override public function update(elapsed:Float) {
		updateText();
		super.update(elapsed);
	}

	public function updateText() {
		scoreTxt.text = "Score: " + PlayState.instance.songScore;
		notesHitTXT.text = PlayState.instance.notesHit + "x";
		accTxt.text = "Accuracy: " + PlayState.instance.accuracy;
		
		if (FlxG.sound.music != null && FlxG.sound.music.playing) {
			var currentTime:Float = FlxG.sound.music.time / 1000;
			var totalTime:Float = FlxG.sound.music.length / 1000;
			songTimerTxt.text = formatTime(currentTime) + " / " + formatTime(totalTime);
		} else {
			songTimerTxt.text = "0:00 / 0:00";
		}
	}

	private function formatTime(seconds:Float):String {
		var minutes:Int = Std.int(seconds / 60);
		var remainingSeconds:Int = Std.int(seconds % 60);
		return minutes + ":" + (remainingSeconds < 10 ? "0" : "") + remainingSeconds;
	}
}
