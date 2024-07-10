package states;

import flixel.util.FlxSort;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import backend.NoteMechanics;
import backend.StrumNote;

class PlayState extends FlxState
{
    // Main 4k rhythm game sys
    var playerKeys:Array<Array<FlxKey>> = [[A], [S], [K], [L]];
    var strumNotes:StrumNote;
    var despawnNotes:FlxTypedGroup<FlxSprite>;
    // Gameplay
    public static var curSong:String = "Template";
    // Mechanics
    var noteMechanics:NoteMechanics;
	var instance:PlayState;

    override public function create()
    {
        FlxG.camera.bgColor = 0xFF333333;

        despawnNotes = new FlxTypedGroup<FlxSprite>();
        add(despawnNotes);

        strumNotes = new StrumNote(playerKeys, 4);
        add(strumNotes.strumlineArrows);

        noteMechanics = new NoteMechanics(strumNotes.strumlineArrows);

        strumNotes.makeStrumline();

        super.create();

        despawnNotes.sort(FlxSort.byY);
    }

    override public function update(elapsed:Float)
    {
        #if !(mobile)
        if (FlxG.keys.anyJustPressed([ENTER, ESCAPE]))
        {
            var pauseSubState = new substates.PauseSubstate();
            openSubState(pauseSubState);
        }
        #end

        for (i in 0...playerKeys.length) {
            strumNotes.keyCheck(i);
        }

        // Cool mechanic shits
        noteMechanics.update(elapsed);

        super.update(elapsed);
    }
}
