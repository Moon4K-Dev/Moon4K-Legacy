package game;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import states.PlayState;

class UI extends FlxSpriteGroup {
	private var scoreTxt:FlxText;
	private var missTxt:FlxText;
	private var accTxt:FlxText;
	private var rankTxt:FlxText;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	public function new() {
		super();

		var textWidth:Int = 200; // Adjust this value as needed

		scoreTxt = new FlxText(FlxG.width - textWidth - 10, 10, textWidth, "Score: 0", 20);
		scoreTxt.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		missTxt = new FlxText(FlxG.width - textWidth - 10, 40, textWidth, "Misses: 0", 20);
		missTxt.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missTxt.scrollFactor.set();
		add(missTxt);

		accTxt = new FlxText(FlxG.width - textWidth - 10, 70, textWidth, "Accuracy: 0%", 20);
		accTxt.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, FlxTextAlign.RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		accTxt.scrollFactor.set();
		add(accTxt);
	}

	override public function update(elapsed:Float) {
		updateText();
		super.update(elapsed);
	}

	public function updateText() {
		scoreTxt.text = "Score: " + PlayState.instance.songScore;
		missTxt.text = "Misses: " + PlayState.instance.misses;
		accTxt.text = "Accuracy: " + PlayState.instance.accuracy;
	}
}
