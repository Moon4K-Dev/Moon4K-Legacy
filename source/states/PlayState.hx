package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import backend.NoteMechanics;
import backend.StrumNote;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSort;
import game.Conductor;

class PlayState extends SwagState {
    var playerKeys = [[A], [S], [K], [L]];
    var strumNotes:StrumNote;
    var despawnNotes:FlxTypedGroup<FlxSprite>;
    public static var curSong = "Template";
    var noteMechanics:NoteMechanics;
    var noteFrames:FlxAtlasFrames;

    override public function create() {
        FlxG.camera.bgColor = 0xFF333333;
        despawnNotes = new FlxTypedGroup<FlxSprite>();
        add(despawnNotes);
        noteFrames = Paths.getSparrowAtlas('notes');
        strumNotes = new StrumNote(playerKeys, 4, noteFrames);
        add(strumNotes.strumlineArrows);
        noteMechanics = new NoteMechanics(strumNotes.strumlineArrows, strumNotes.numStrumNotes);
        strumNotes.makeStrumline();
        super.create();
        despawnNotes.sort(FlxSort.byY);
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.anyJustPressed([ENTER, ESCAPE])) {
            openSubState(new substates.PauseSubstate());
        }
        for (i in 0...playerKeys.length) {
            strumNotes.keyCheck(i);
        }
        noteMechanics.update(elapsed);
        super.update(elapsed);
    }
}
