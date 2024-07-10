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
		
        scoreTxt = new FlxText(0, (FlxG.height * 0.89) + 24, FlxG.height, "Score: 0 | Combo: 0", 20);
        scoreTxt.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        scoreTxt.scrollFactor.set();
        scoreTxt.screenCenter(X);
        add(scoreTxt);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function updateText()
    {
		scoreTxt.text = "Score: " + PlayState.songScore + "| Combo: " + PlayState.curCombo;
    }
}