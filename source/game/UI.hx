package game;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import states.PlayState;

class UI extends FlxSpriteGroup
{
    private var scoreTxt:FlxText;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

    public function new()
    {
        super();
		
        scoreTxt = new FlxText(0, (FlxG.height * 0.89) + 24, FlxG.height, "Score: 0 | CurCombo: 0", 20);
        scoreTxt.setFormat(Paths.font('vcr.ttf'), 48, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        scoreTxt.scrollFactor.set();
        scoreTxt.screenCenter(X);
        add(scoreTxt);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		//add(healthBar);
		
    }

    override public function update(elapsed:Float)
    {
		updateText();
        super.update(elapsed);
    }

    public function updateText()
    {
		scoreTxt.text = "Score: " + PlayState.songScore + " Misses: " + PlayState.misses;
    }
}