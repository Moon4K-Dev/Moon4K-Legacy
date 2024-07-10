package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import game.NoteMechanics;
import game.StrumNote;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSort;
import flixel.FlxCamera;
import game.UI;
import game.Note;

class PlayState extends FlxState 
{
    var instance:PlayState;
    // input
    var playerKeys = [[A], [S], [K], [L]];
    // strums
    var strumNotes:StrumNote;
    var despawnNotes:FlxTypedGroup<FlxSprite>;
    var noteFrames:FlxAtlasFrames;
    // song stuff
    public static var curSong = 'Template';
    public var speed:Int = 1;
    public static var songScore:Int = 0;
    public static var curCombo:Int = 0;
    // mechanics
    var noteMechanics:NoteMechanics;
    // hud
    var hud:UI;
    // Note
    var notes:FlxTypedGroup<Note>;

    override public function create() {
        
        instance = this;
        FlxG.camera.bgColor = 0xFF333333;
        despawnNotes = new FlxTypedGroup<FlxSprite>();
        add(despawnNotes);
        noteFrames = Paths.getSparrowAtlas('noteslol/notes');
        strumNotes = new StrumNote(playerKeys, 4, noteFrames);
        add(strumNotes.strumlineArrows);
        noteMechanics = new NoteMechanics(strumNotes.strumlineArrows, strumNotes.numStrumNotes);
        strumNotes.makeStrumline();
        super.create();
        despawnNotes.sort(FlxSort.byY);
        hud = new UI();
		add(hud);

        generateNotes();
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

    function generateNotes()
	{
		// generate notes.exe virus free apk
	}
}
