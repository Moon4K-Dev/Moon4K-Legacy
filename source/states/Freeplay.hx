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
import haxe.Json;
import sys.io.File;

class Freeplay extends SwagState
{
    var grpSongs:FlxTypedGroup<FlxText>;
    public static var songs:Array<String> = ["test", "very", "swagger", "freeplay", "concept", "idk", "what else", "to put", "here"];
    public var curSelected:Int = 0;
    var scoreText:FlxText;
    var lerpScore:Int = 0;
    var intendedScore:Int = 0;
    var curDifficulty:Int = 1;
    var diffText:FlxText;
    public var selectedSong:String;
    static public var instance:Freeplay;
    var songData:Dynamic;
    var missesTxt:FlxText;
    public var songInfoData:Array<Dynamic>;
    var visibleRange:Int = 5;
    var songHeight:Int = 100;

    public function new() {
        super();
        this.curSelected = 0;
        this.selectedSong = songs[curSelected];
        instance = this;
    }

    override public function create()
    {
        FlxG.stage.window.title = "YA4KRG Demo - FreeplayState";
        
        var coolBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('menubglol'), 0.2, 0, true, true);
        coolBackdrop.velocity.set(50, 30);
        coolBackdrop.alpha = 0.7;
        add(coolBackdrop);

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var leText:String = "Press TAB to see the Song Info // Press Enter to start the song.";
		var size:Int = 18;
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		super.create();

        grpSongs = new FlxTypedGroup<FlxText>();
        add(grpSongs);

        for (i in 0...songs.length)
        {
            var songTxt:FlxText = new FlxText(0, 50 + (i * songHeight), FlxG.width, songs[i], 32);
            songTxt.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER);
            songTxt.scrollFactor.set();
            songTxt.ID = i;
            grpSongs.add(songTxt);
        }

        selectedSong = songs[curSelected];

        scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
        scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
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
            loadSongJson(selectedSong);
            transitionState(new PlayState());
            PlayState.instance.song = songData;
        }

        if (FlxG.keys.justPressed.TAB)
        {
            loadSongInfoJson(selectedSong);
            var infosubstate = new substates.SongInfoSubstate();
            openSubState(infosubstate);
        }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;

        if (curSelected < 0)
            curSelected = 0;
        if (curSelected >= grpSongs.length)
            curSelected = grpSongs.length - 1;

        var startY:Int = 50;
        var spacing:Int = 100;
        var visibleCount:Int = 5;
        var offset:Int = Math.floor(visibleCount / 2);

        grpSongs.forEach((txt:FlxText) ->
        {
            var index = txt.ID - (curSelected - offset);
            txt.y = startY + (index * spacing);
            
            if (txt.ID == curSelected)
            {
                txt.color = FlxColor.YELLOW;
                txt.size = 36;
                txt.alpha = 1.0;
            }
            else
            {
                txt.color = FlxColor.WHITE;
                txt.size = 32;
                txt.alpha = 0.7;
            }
        });

        selectedSong = songs[curSelected];
    } 
    
    function loadSongInfoJson(songName:String):Void {
        var path:String = "assets/data/" + songName + "/songInfo.json";
        var jsonContent:String = File.getContent(path);
        songInfoData = Json.parse(jsonContent);
        trace(songInfoData);
    }
    

    function loadSongJson(songName:String):Void
    {
        var path:String = "assets/data/" + songName + "/" + songName + ".json";
        var jsonContent:String = File.getContent(path);
        songData = Json.parse(jsonContent);
        trace(songData);
    }
}
