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
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	public function new() {
		super();

		scoreTxt = new FlxText(0, 240, FlxG.width, "Score: 0", 20);
		scoreTxt.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		missTxt = new FlxText(0, 290, FlxG.width, "Misses: 0", 60);
		missTxt.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missTxt.scrollFactor.set();
		add(missTxt);

		healthBarBG = new FlxSprite(!FlxG.save.data.quaverbar ? 0 : FlxG.width, !FlxG.save.data.quaverbar ? FlxG.height * 0.88 : 0).loadGraphic(Paths.image('game/healthBar'));	
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.angle = 90;
		healthBarBG.x = -290;
		healthBarBG.y = 340;
		healthBar = new FlxBar(5, healthBarBG.y + 53, BOTTOM_TO_TOP, Std.int(healthBarBG.height - 8), Std.int(healthBarBG.width - 8), this, 'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFFFFFF, 0xFF66FF33);
		add(healthBar);
		add(healthBarBG);

	}

	override public function update(elapsed:Float) {
		updateText();
		super.update(elapsed);
	}

	public function updateText() {
		scoreTxt.text = "Score: \n" + PlayState.instance.songScore;
		missTxt.text = "Misses: \n" + PlayState.instance.misses;
	}
}
