package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxObject;
import flixel.util.FlxColor;
import game.Song;
import game.Highscore;
import flixel.addons.display.FlxBackdrop;

class Freeplay extends SwagState
{
    var grpSongs:FlxTypedGroup<FlxText>;
    var songs:Array<String> = ["2hot"];
    var curSelected:Int = 0;
    var scoreText:FlxText;
    var lerpScore:Int = 0;
    var intendedScore:Int = 0;
	// diff
	var curDifficulty:Int = 1;
	var diffText:FlxText;

	override public function create()
	{
        FlxG.stage.window.title = "YA4KRG Demo - FreeplayState";
        var coolbackdro:FlxBackdrop = new FlxBackdrop(Paths.image('menubglol'), 0.2, 0, true, true);
        coolbackdro.velocity.set(200, 110);
        coolbackdro.updateHitbox();
        coolbackdro.alpha = 0.5;
        coolbackdro.screenCenter();
        add(coolbackdro);

        grpSongs = new FlxTypedGroup<FlxText>();
        add(grpSongs);

        for (i in 0...songs.length)
        {
            var songTxt:FlxText = new FlxText(0, 50 + (i * 130), 0, songs[i], 100);
            songTxt.screenCenter(X);
            songTxt.ID = i;
            grpSongs.add(songTxt);
        }

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;
		add(scoreText);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

        changeSelection();

		super.create();
	}

	override public function update(elapsed:Float)
	{		
		if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
		{
			transitionState(new states.SplashState());
        } 

        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
            changeSelection(FlxG.keys.justPressed.UP ? -1 : 1);

        if (FlxG.keys.justPressed.ENTER)
        {
			var poop:String = Highscore.formatSong(songs[curSelected].toLowerCase(), curDifficulty);
			PlayState.instance.song = Song.loadFromJson(poop, songs[curSelected].toLowerCase());
			transitionState(new PlayState());
        }

		super.update(elapsed);
	}

    function changeSelection(change:Int = 0)
    {
        curSelected += change;

        if (curSelected < 0)
            curSelected = grpSongs.length - 1;
        if (curSelected >= grpSongs.length)
            curSelected = 0;

        grpSongs.forEach((txt:FlxText) ->
        {
            txt.color = (txt.ID == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
        });
    }    
}