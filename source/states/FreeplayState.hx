package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import sys.io.File;
import haxe.Json;

class FreeplayState extends SwagState
{
    var grpSongs:FlxTypedGroup<FlxText>;
    var songs:Array<Dynamic>;
    var curSelected:Int = 0;
    var scoreText:FlxText;
    var lerpScore:Int = 0;
    var intendedScore:Int = 0;
    var coolbackdro:FlxBackdrop;

    override public function create()
    {
        try {
            var jsonString:String = File.getContent("assets/data/freeplay.json");
            songs = Json.parse(jsonString);
            trace(songs);
        } catch (e:Dynamic) {
            trace("Failed to load or parse freeplay.json: " + e);
            songs = [];
        }

        coolbackdro = new FlxBackdrop(Paths.image('menubglol'), 0.2, 0, true, true);
        coolbackdro.velocity.set(200, 110);
        coolbackdro.updateHitbox();
        coolbackdro.alpha = 0.5;
        coolbackdro.screenCenter();
        add(coolbackdro);

        grpSongs = new FlxTypedGroup<FlxText>();
        add(grpSongs);

        for (i in 0...songs.length)
        {
            var songName:String = songs[i].SongName;
            var songTxt:FlxText = new FlxText(0, 50 + (i * 130), FlxG.width, songName, 100);
            songTxt.screenCenter();
            songTxt.ID = i;
            grpSongs.add(songTxt);
        }

        scoreText = new FlxText(FlxG.width * 0.7, 5, FlxG.width * 0.3, "Score: 0", 32);
        scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
        add(scoreText);

        changeSelection();

        super.create();
    }

    override public function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
        {
            FlxG.switchState(new states.MainMenuState());
        }

        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
            changeSelection(FlxG.keys.justPressed.UP ? -1 : 1);

        if (FlxG.keys.justPressed.ENTER)
        {
            FlxG.sound.music.stop();
            FlxG.switchState(new PlayState());
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
