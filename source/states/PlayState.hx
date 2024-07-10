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
import flixel.FlxObject;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import game.Note;
import game.ChartParser;
import game.Conductor;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

class PlayState extends FlxState 
{

    // music shit LOLOL
    private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var canHit:Bool = false;

	private var totalBeats:Int = 0;
	private var totalSteps:Int = 0;

    private var curSection:Int = 0;
    private var notes:FlxTypedGroup<Note>;
    private var sectionScores:Array<Dynamic> = [[], []];

    // othr
    var strumNotes:StrumNote;
    var despawnNotes:FlxTypedGroup<FlxSprite>;
    public static var curSong = 'Bopeebo';
    var noteMechanics:NoteMechanics;
    var noteFrames:FlxAtlasFrames;
    private var strumLine:FlxSprite;

    override public function create() {
        FlxG.camera.bgColor = 0xFF333333;
        despawnNotes = new FlxTypedGroup<FlxSprite>();
        add(despawnNotes);
        noteFrames = Paths.getSparrowAtlas('notes');

        // Define player keys for each direction
        var playerKeys:Array<Array<FlxKey>> = [
            [FlxKey.A, FlxKey.LEFT],  // Left
            [FlxKey.S, FlxKey.DOWN],  // Down
            [FlxKey.K, FlxKey.UP],    // Up
            [FlxKey.L, FlxKey.RIGHT]  // Right
        ];

        strumNotes = new StrumNote(playerKeys, 4, noteFrames);
        add(strumNotes.strumlineArrows);
        noteMechanics = new NoteMechanics(strumNotes.strumlineArrows, strumNotes.numStrumNotes);
        strumNotes.makeStrumline();
        super.create();
        strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
        strumLine.screenCenter();
		strumLine.scrollFactor.set();
        generateSong('assets/data/bopeebo/bopeebo.json');
        despawnNotes.sort(FlxSort.byY);
        FlxG.sound.playMusic("assets/music/" + curSong + "_Inst" + Utils.soundExt, 1, false);
    }

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = Json.parse(Assets.getText(dataPath));
        FlxG.sound.playMusic("assets/music/" + curSong + "_Inst" + Utils.soundExt, 1, false);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<Dynamic> = [];

		for (i in 1...songData.sections + 1)
		{
			trace(i);
			noteData.push(ChartParser.parse(songData.song.toLowerCase(), i));
		}

		var playerCounter:Int = 0;

		while (playerCounter < 2)
		{
			var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
			for (section in noteData)
			{
				var dumbassSection:Array<Dynamic> = section;

				var daStep:Int = 0;

				for (songNotes in dumbassSection)
				{
					sectionScores[0].push(0);
					sectionScores[1].push(0);

					if (songNotes != 0)
					{
						var daStrumTime:Float = (((daStep * Conductor.stepCrochet) + (Conductor.crochet * 8 * daBeats))
							+ ((Conductor.crochet * 4) * playerCounter));

						var swagNote:Note = new Note(daStrumTime, songNotes);
						swagNote.scrollFactor.set(0, 0);

						swagNote.x += ((FlxG.width / 2) * playerCounter); // general offset

						if (playerCounter == 1) // is the player
						{
							swagNote.mustPress = true;
						}
						else
						{
							sectionScores[0][daBeats] += swagNote.noteScore;
						}

						if (notes.members.length > 0)
							swagNote.prevNote = notes.members[notes.members.length - 1];
						else
							swagNote.prevNote = swagNote;

						notes.add(swagNote);
					}

					daStep += 1;
				}

				daBeats += 1;
			}

			playerCounter += 1;
		}
	}

    override public function update(elapsed:Float) {
        if (FlxG.keys.anyJustPressed([ENTER, ESCAPE])) {
            openSubState(new substates.PauseSubstate());
        }
        noteMechanics.update(elapsed);
        super.update(elapsed);

		everyBeat();
		everyStep();

		notes.forEachAlive(function(daNote:Note)
		{
            // Adjusting the y position based on the current song position and the note's strum time
            daNote.y = (strumLine.y + 5 - (daNote.height / 2)) - ((Conductor.songPosition - daNote.strumTime) * 0.4);

            // Visibility and activity check
            if (daNote.y > FlxG.height)
            {
                daNote.active = false;
                daNote.visible = false;
            }
            else
            {
                daNote.active = true;
                daNote.visible = true;
            }

            // Remove notes that have gone off the top of the screen
            if (daNote.y < -daNote.height)
            {
                daNote.kill();
            }

            // Remove notes that were hit
            if (!daNote.mustPress && daNote.wasGoodHit)
            {
                daNote.kill();
            }
		});    

        keyShit();    
    }

    function keyShit():Void
    {
        // HOLDING
        var up = FlxG.keys.anyPressed([K, UP]);
        var right = FlxG.keys.anyPressed([L, RIGHT]);
        var down = FlxG.keys.anyPressed([S, DOWN]);
        var left = FlxG.keys.anyPressed([A, LEFT]);
        var upP = FlxG.keys.anyJustPressed([K, UP]);
        var rightP = FlxG.keys.anyJustPressed([L, RIGHT]);
        var downP = FlxG.keys.anyJustPressed([S, DOWN]);
        var leftP = FlxG.keys.anyJustPressed([A, LEFT]);

        // Check key animations
        strumNotes.keyCheck(0); // Left note
        strumNotes.keyCheck(1); // Down note
        strumNotes.keyCheck(2); // Up note
        strumNotes.keyCheck(3); // Right note

        if (up || right || down || left)
        {
            notes.forEach(function(daNote:Note)
            {
                if (daNote.canBeHit)
                {
                    switch (daNote.noteData)
                    {
                        // NOTES YOU ARE HOLDING
                        case -1:
                            if (up && daNote.prevNote.wasGoodHit)
                                goodNoteHit(daNote);
                        case -2:
                            if (right && daNote.prevNote.wasGoodHit)
                                goodNoteHit(daNote);
                        case -3:
                            if (down && daNote.prevNote.wasGoodHit)
                                goodNoteHit(daNote);
                        case -4:
                            if (left && daNote.prevNote.wasGoodHit)
                                goodNoteHit(daNote);
                        case 1: // NOTES YOU JUST PRESSED
                            if (upP)
                                goodNoteHit(daNote);
                        case 2:
                            if (rightP)
                                goodNoteHit(daNote);
                        case 3:
                            if (downP)
                                goodNoteHit(daNote);
                        case 4:
                            if (leftP)
                                goodNoteHit(daNote);
                    }
                    if (daNote.wasGoodHit)
                    {
                        daNote.kill();
                    }
                }
            });
        }
    }

    function goodNoteHit(note:Note):Void
    {
        if (!note.wasGoodHit)
        {
            sectionScores[1][curSection] += note.noteScore;
            note.wasGoodHit = true;
        }
    }

    function everyBeat():Void
    {
        if (Conductor.songPosition > lastBeat + Conductor.crochet - Conductor.safeZoneOffset
            || Conductor.songPosition < lastBeat + Conductor.safeZoneOffset)
        {
            if (Conductor.songPosition > lastBeat + Conductor.crochet)
            {
                lastBeat += Conductor.crochet;

                totalBeats += 1;
            }
        }
    }

    function everyStep()
    {
        if (Conductor.songPosition > lastStep + Conductor.stepCrochet - Conductor.safeZoneOffset
            || Conductor.songPosition < lastStep + Conductor.safeZoneOffset)
        {
            canHit = true;

            if (Conductor.songPosition > lastStep + Conductor.stepCrochet)
            {
                totalSteps += 1;
                lastStep += Conductor.stepCrochet;
            }
        }
        else
            canHit = false;
    }    
}
