package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import mobile.flixel.FlxVirtualPad;
import flixel.FlxSubState;
import flixel.FlxCamera;
import states.PlayState;

class PauseSubstate extends FlxSubState
{
	#if mobile
	var flxPad:FlxVirtualPad;
	var controlsCam:FlxCamera;
	#end	

	public function new()
	{
		super();

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.scrollFactor.set();
        bg.alpha = 0.65;
		bg.screenCenter();
        add(bg);

		var songInfo:FlxText = new FlxText(20, 15, 0, "", 32);
        songInfo.text += "Song: " + PlayState.curSong;
		songInfo.scrollFactor.set();
		songInfo.setFormat(Paths.font("vcr.ttf"), 32);
		songInfo.updateHitbox();
		add(songInfo);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
        #if mobile
		flxPad = new FlxVirtualPad(NONE, A);
		add(flxPad);
		#end

        #if (!mobile)
		if (FlxG.keys.justPressed.ENTER)
		{
            close();
		}
        #end

        #if mobile
        if (flxPad.buttonA.pressed)
        {
            close();
        }
        #end
	}

	override function destroy()
	{
		super.destroy();
	}	
}