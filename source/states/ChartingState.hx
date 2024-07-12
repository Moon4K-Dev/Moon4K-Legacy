package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import game.Conductor;
import game.Note;
import game.Section;
import game.Song;
import options.Controls;
import util.Util;

class ChartingState extends SwagState
{
	static public var instance:ChartingState;

	var gridSize:Int = 40;
	var columns:Int = 4;
	var rows:Int = 16;

	var gridBG:FlxSprite;

	var curSection:Int = 0;
	var dummyArrow:FlxSprite;

	var beatSnap:Int = 16;

	var renderedNotes:FlxTypedGroup<Note>;

	public var song:SwagSong;

	override public function new()
	{
		super();

		instance = this;

		song = {
			song: "Test",
			notes: [],
			bpm: 100,
			sections: 0,
			sectionLengths: [],
			keyCount: 4,
			timescale: [4, 4]
		};
	}

	var curSelectedNote:SwagNote;

	var songInfoText:FlxText;

	override public function create()
	{
        FlxG.stage.window.title = "YA4KRG Demo - ChartingState";
		super.create();

		loadSong(song.song);

		beatSnap = Conductor.stepsPerSection;

		gridBG = FlxGridOverlay.create(gridSize, gridSize, gridSize * columns, gridSize * rows, true, 0xFF404040, 0xFF525252);
		gridBG.screenCenter();
		add(gridBG);

		dummyArrow = new FlxSprite().makeGraphic(gridSize, gridSize);
		add(dummyArrow);

		renderedNotes = new FlxTypedGroup<Note>();
		add(renderedNotes);

		addSection();
		updateGrid();

		songInfoText = new FlxText(10, 10, 0, 18);
		add(songInfoText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.BACK)
			transitionState(new SplashState());

		if (Controls.UI_LEFT)
			changeSection(curSection - 1);

		if (Controls.UI_RIGHT)
			changeSection(curSection + 1);

		if (Controls.ACCEPT)
		{
			transitionState(new PlayState());
			PlayState.instance.song = song;
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (gridSize * Conductor.stepsPerSection))
		{
			var snappedGridSize = (gridSize / (beatSnap / Conductor.stepsPerSection));

			dummyArrow.x = Math.floor(FlxG.mouse.x / gridSize) * gridSize;

			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / snappedGridSize) * snappedGridSize;
		}

		if (FlxG.mouse.justPressed)
		{
			var coolNess = true;

			if (FlxG.mouse.overlaps(renderedNotes))
			{
				renderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note)
						&& (Math.floor((gridBG.x + FlxG.mouse.x / gridSize) - 2)) == note.rawNoteData && coolNess)
					{
						coolNess = false;

						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							deleteNote(note);
						}
					}
				});
			}

			if (coolNess)
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (gridSize * Conductor.stepsPerSection))
				{
					addNote();
				}
			}
		}

		Conductor.songPosition = FlxG.sound.music.time;

		songInfoText.text = ("Time: "
			+ Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nBPM: "
			+ Conductor.bpm
			+ "\nCurStep: "
			+ curStep
			+ "\nCurBeat: "
			+ curBeat
			+ "\nNote Snap: "
			+ beatSnap
			+ (FlxG.keys.pressed.SHIFT ? "\n(DISABLED)" : "\n(CONTROL + ARROWS)")
			+ "\n");
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.music = new FlxSound().loadEmbedded(Util.getSong(daSong));

		FlxG.sound.music.pause();

		FlxG.sound.music.onComplete = function()
		{
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function addNote()
	{
		if (song.notes[curSection] == null)
			addSection();

		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((gridBG.x + (FlxG.mouse.x / gridSize)) - 2);
		var noteSus = 0;

		song.notes[curSection].sectionNotes.push({
			noteStrum: noteStrum,
			noteData: noteData,
			noteSus: noteSus
		});

		updateGrid();
	}

	function deleteNote(note:Note):Void
	{
		for (sectionNote in song.notes[curSection].sectionNotes)
		{
			if (sectionNote.noteStrum == note.strum && sectionNote.noteData == note.rawNoteData)
			{
				song.notes[curSection].sectionNotes.remove(sectionNote);
			}
		}

		updateGrid();
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (sectionNote in song.notes[curSection].sectionNotes)
		{
			if (sectionNote.noteStrum == note.strum && sectionNote.noteData % song.keyCount == note.direction)
			{
				curSelectedNote = sectionNote;
			}

			swagNum += 1;
		}

		updateGrid();
	}

	function updateGrid()
	{
		renderedNotes.forEach(function(note:Note)
		{
			note.kill();
			note.destroy();
		}, true);

		renderedNotes.clear();

		for (sectionNote in song.notes[curSection].sectionNotes)
		{
			var note:Note = new Note(0, 0, sectionNote.noteData % song.keyCount, sectionNote.noteStrum, "default", false, false, song.keyCount);

			note.setGraphicSize(gridSize, gridSize);
			note.updateHitbox();

			note.x = gridBG.x + Math.floor((sectionNote.noteData % song.keyCount) * gridSize);
			note.y = Math.floor(getYfromStrum((sectionNote.noteStrum - sectionStartTime())));

			note.rawNoteData = sectionNote.noteData;

			renderedNotes.add(note);
		}
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, Conductor.stepsPerSection * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, Conductor.stepsPerSection * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	function addSection(?coolLength:Int = 0):Void
	{
		var col:Int = Conductor.stepsPerSection;

		if (coolLength == 0)
			col = Std.int(Conductor.timeScale[0] * Conductor.timeScale[1]);

		var sec:SwagSection = {
			sectionNotes: [],
			bpm: song.bpm,
			changeBPM: false,
			timeScale: Conductor.timeScale,
			changeTimeScale: false
		};

		song.notes.push(sec);
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (song.notes[sec] != null)
		{
			curSection = sec;

			if (curSection < 0)
				curSection = 0;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();

				FlxG.sound.music.time = sectionStartTime();
				updateCurStep();
			}

			updateGrid();
		}
		else
		{
			addSection();

			curSection = sec;

			if (curSection < 0)
				curSection = 0;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();

				FlxG.sound.music.time = sectionStartTime();
				updateCurStep();
			}

			updateGrid();
		}
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();

		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		updateCurStep();

		updateGrid();
	}

	function sectionStartTime(?section:Int):Float
	{
		if (section == null)
			section = curSection;

		var daBPM:Float = song.bpm;
		var daPos:Float = 0;

		for (i in 0...section)
		{
			if (song.notes[i].changeBPM)
			{
				daBPM = song.notes[i].bpm;
			}

			daPos += Conductor.timeScale[0] * (1000 * (60 / daBPM));
		}

		return daPos;
	}
}