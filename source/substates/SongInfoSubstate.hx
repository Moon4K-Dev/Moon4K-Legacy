package substates;

import states.Freeplay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import states.Freeplay;

class SongInfoSubstate extends SwagSubState
{
    var bg:FlxSprite;
    var songInfoText:FlxText;

    public function new()
    {
        super();

        var bgdot:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bgdot.scrollFactor.set();
        bgdot.alpha = 0.65;
        bgdot.screenCenter();
        add(bgdot);

        bg = new FlxSprite(-80).loadGraphic(Paths.image('freeplay/sidebar'));
        bg.scrollFactor.x = 0;
        bg.scrollFactor.y = 0.18;
        bg.setGraphicSize(Std.int(bg.width * 1.1));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = true;
        add(bg);

        songInfoText = new FlxText(FlxG.width - 320, 15, 300, "", 32);
        songInfoText.scrollFactor.set();
        songInfoText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE);
        songInfoText.updateHitbox();
        add(songInfoText);
    }

    override public function update(elapsed:Float)
    {
        songInfoText.text = getSongInfoText();

        if (FlxG.keys.justPressed.TAB || FlxG.keys.justPressed.ENTER)
        {
            close();
        }
        super.update(elapsed);
    }

    function getSongInfoText():String
    {
        if (Freeplay.instance.songInfoData != null && Freeplay.instance.songInfoData.length > 0) {
            var info:Dynamic = Freeplay.instance.songInfoData[Freeplay.instance.curSelected];
            var infoText:String = "Song Name: " + info.SongName + "\n" +
                                  "Charter: " + info.Charter + "\n" +
                                  "Song by: " + info.MusicMaker;
            return infoText;
        } else {
            return "";
        }
    }

    override public function destroy()
    {
        super.destroy();
    }
}
