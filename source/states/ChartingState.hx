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
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;
import haxe.Json;
import sys.io.File;
import sys.io.FileOutput;
import haxe.io.Path;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;

using StringTools;

class ChartingState extends SwagState {
	static public var instance:ChartingState;

	var _file:FileReference;

	var gridSize:Int = 40;
	var columns:Int = 4;
	var rows:Int = 16;

	var gridBG:FlxSprite;

	var curSection:Int = 0;
	var dummyArrow:FlxSprite;

	var beatSnap:Int = 16;

	var renderedNotes:FlxTypedGroup<Note>;
	var renderedSustains:FlxTypedGroup<FlxSprite>;

	public var song:SwagSong;

	var saveButton:FlxButton;
	var loadButton:FlxButton;
	var speedButton:FlxButton;
	var keyCountButton:FlxButton;
	var bpmButton:FlxButton;

	var speedInput:FlxInputText;
	var keyCountInput:FlxInputText;
	var bpmInput:FlxInputText;

	override public function new() {
		super();

		instance = this;

		song = {
			song: "test",
			notes: [],
			bpm: 100,
			sections: 0,
			sectionLengths: [],
			speed: 1,
			keyCount: 4,
			timescale: [4, 4]
		};
	}

	var curSelectedNote:SwagNote;

	var songInfoText:FlxText;

	override public function create() {
		FlxG.mouse.visible = true;

		FlxG.stage.window.title = "Moon4K - ChartingState";
		#if desktop
		Discord.changePresence("Charting: " + song.song, null);
		#end

		super.create();

		loadSong(song.song);

		beatSnap = Conductor.stepsPerSection;

		columns = song.keyCount;
		gridBG = FlxGridOverlay.create(gridSize, gridSize, gridSize * columns, gridSize * rows, true, 0xFF404040, 0xFF525252);
		gridBG.screenCenter();
		add(gridBG);

		dummyArrow = new FlxSprite().makeGraphic(gridSize, gridSize);
		add(dummyArrow);

		renderedNotes = new FlxTypedGroup<Note>();
		add(renderedNotes);

		renderedSustains = new FlxTypedGroup<FlxSprite>();
		add(renderedSustains);

		addSection();
		updateGrid();

		songInfoText = new FlxText(10, 10, 0, 18);
		add(songInfoText);

		saveButton = new FlxButton(70, FlxG.height - 40, "Save Chart", saveChart);
		add(saveButton);

		var inputYPos:Int = 10;
		var inputHeight:Int = 30;

		speedInput = new FlxInputText(FlxG.width - 60, inputYPos, 50);
		speedInput.text = Std.string(song.speed);
		add(speedInput);

		speedButton = new FlxButton(70, FlxG.height - 80, "Set Speed", setSpeed);
		add(speedButton);

		inputYPos += inputHeight + 10;

		keyCountInput = new FlxInputText(FlxG.width - 60, inputYPos, 50);
		keyCountInput.text = Std.string(song.keyCount);
		add(keyCountInput);

		keyCountButton = new FlxButton(70, FlxG.height - 120, "Set Key Count", setKeyCount);
		add(keyCountButton);

		inputYPos += inputHeight + 10;

		bpmInput = new FlxInputText(FlxG.width - 60, inputYPos, 50);
		bpmInput.text = Std.string(song.bpm);
		add(bpmInput);

		bpmButton = new FlxButton(70, FlxG.height - 160, "Set BPM", setBPM);
		add(bpmButton);

		loadButton = new FlxButton(70, FlxG.height - 200, "Load Song", loadSongFromFile);
		add(loadButton);
	}

	function loadSongFromFile():Void {
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onFileSelected);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([new FileFilter("JSON Files", "*.json")]);
	}

	function onFileSelected(event:Event):Void {
		_file.addEventListener(Event.COMPLETE, onLoadComplete);
		_file.load();
	}

	function onLoadComplete(event:Event):Void {
		_file.removeEventListener(Event.COMPLETE, onLoadComplete);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		var jsonData:String = _file.data.readUTFBytes(_file.data.length);
		var loadedSong:SwagSong = Json.parse(jsonData);

		song = loadedSong;
		updateGrid();

		speedInput.text = Std.string(song.speed);
		keyCountInput.text = Std.string(song.keyCount);
		bpmInput.text = Std.string(song.bpm);
	}

	function onLoadError(event:IOErrorEvent):Void {
		_file.removeEventListener(Event.COMPLETE, onLoadComplete);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		trace("Error loading song: " + event.text);
	}

	function saveChart():Void {
		var data:String = Json.stringify(song, null, "\t");
		if ((data != null) && (data.length > 0)) {
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		trace("Successfully saved LEVEL DATA.");
	}

	function onSaveCancel(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		trace("Problem saving Level data");
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
			transitionState(new MainMenuState());

		if (FlxG.keys.justPressed.LEFT)
			changeSection(curSection - 1);

		if (FlxG.keys.justPressed.RIGHT)
			changeSection(curSection + 1);

		if (FlxG.keys.justPressed.ENTER) {
			FlxG.mouse.visible = false;
			transitionState(new PlayState());
			PlayState.instance.song = song;
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.SPACE) {
			if (FlxG.sound.music.playing) {
				FlxG.sound.music.pause();
			} else {
				FlxG.sound.music.play();
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (gridSize * Conductor.stepsPerSection)) {
			var snappedGridSize = (gridSize / (beatSnap / Conductor.stepsPerSection));

			dummyArrow.x = Math.floor(FlxG.mouse.x / gridSize) * gridSize;

			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / snappedGridSize) * snappedGridSize;
		}

		if (FlxG.mouse.justPressed) {
			var coolNess = true;

			if (FlxG.mouse.overlaps(renderedNotes)) {
				renderedNotes.forEach(function(note:Note) {
					if (FlxG.mouse.overlaps(note)
						&& (Math.floor((gridBG.x + FlxG.mouse.x / gridSize) - 2)) == note.rawNoteData && coolNess) {
						coolNess = false;

						if (FlxG.keys.pressed.CONTROL) {
							selectNote(note);
						} else {
							deleteNote(note);
						}
					}
				});
			}

			if (coolNess) {
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (gridSize * Conductor.stepsPerSection)) {
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
			+ "\nSpeed: "
			+ song.speed
			+ "\nKeys: "
			+ song.keyCount
			+ (FlxG.keys.pressed.SHIFT ? "\n(DISABLED)" : "\n(CONTROL + ARROWS)")
			+ "\n");
	}

	function setSpeed():Void {
		song.speed = Std.parseFloat(speedInput.text);
	}

	function setKeyCount():Void {
		song.keyCount = Std.parseInt(keyCountInput.text);
		updateGrid();
	}

	function setBPM():Void {
		song.bpm = Std.parseFloat(bpmInput.text);
		Conductor.bpm = song.bpm;
		updateGrid();
	}

	function loadSong(daSong:String):Void {
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.music = new FlxSound().loadEmbedded(Util.getSong(daSong));

		FlxG.sound.music.pause();

		FlxG.sound.music.onComplete = function() {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function addNote() {
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

	function changeNoteSustain(value:Float):Void {
		if (curSelectedNote != null) {
			curSelectedNote.noteSus += value;
			curSelectedNote.noteSus = Math.max(curSelectedNote.noteSus, 0);
		}

		updateGrid();
	}

	function deleteNote(note:Note):Void {
		for (sectionNote in song.notes[curSection].sectionNotes) {
			if (sectionNote.noteStrum == note.strum && sectionNote.noteData == note.rawNoteData) {
				song.notes[curSection].sectionNotes.remove(sectionNote);
			}
		}

		updateGrid();
	}

	function selectNote(note:Note):Void {
		var swagNum:Int = 0;

		for (sectionNote in song.notes[curSection].sectionNotes) {
			if (sectionNote.noteStrum == note.strum && sectionNote.noteData % song.keyCount == note.direction) {
				curSelectedNote = sectionNote;
			}

			swagNum += 1;
		}

		updateGrid();
	}

	function updateGrid() {
		renderedNotes.forEach(function(note:Note) {
			note.kill();
			note.destroy();
		}, true);

		renderedNotes.clear();

		while (renderedSustains.members.length > 0)
		{
			renderedSustains.remove(renderedSustains.members[0], true);
		}

		for (sectionNote in song.notes[curSection].sectionNotes) {
			var daSus = sectionNote.noteSus;
			var note:Note = new Note(0, 0, sectionNote.noteData % song.keyCount, sectionNote.noteStrum, "default", false, song.keyCount);
			note.sustainLength = daSus;

			note.setGraphicSize(gridSize, gridSize);
			note.updateHitbox();

			note.x = gridBG.x + Math.floor((sectionNote.noteData % song.keyCount) * gridSize);
			note.y = Math.floor(getYfromStrum((sectionNote.noteStrum - sectionStartTime())));

			note.rawNoteData = sectionNote.noteData;

			renderedNotes.add(note);

			if (daSus > 0) {
				var sustainVis:FlxSprite = new FlxSprite(note.x + (gridSize / 2),
					note.y + gridSize).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				renderedSustains.add(sustainVis);
			}
		}
	}

	function getStrumTime(yPos:Float):Float {
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, Conductor.stepsPerSection * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float {
		return FlxMath.remapToRange(strumTime, 0, Conductor.stepsPerSection * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	function addSection(?coolLength:Int = 0):Void {
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

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void {
		trace('changing section' + sec);

		if (song.notes[sec] != null) {
			curSection = sec;

			if (curSection < 0)
				curSection = 0;

			updateGrid();

			if (updateMusic) {
				FlxG.sound.music.pause();

				FlxG.sound.music.time = sectionStartTime();
				updateCurStep();
			}

			updateGrid();
		} else {
			addSection();

			curSection = sec;

			if (curSection < 0)
				curSection = 0;

			updateGrid();

			if (updateMusic) {
				FlxG.sound.music.pause();

				FlxG.sound.music.time = sectionStartTime();
				updateCurStep();
			}

			updateGrid();
		}
	}

	function resetSection(songBeginning:Bool = false):Void {
		updateGrid();

		FlxG.sound.music.pause();

		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning) {
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		updateCurStep();

		updateGrid();
	}

	function sectionStartTime(?section:Int):Float {
		if (section == null)
			section = curSection;

		var daBPM:Float = song.bpm;
		var daPos:Float = 0;

		for (i in 0...section) {
			if (song.notes[i].changeBPM) {
				daBPM = song.notes[i].bpm;
			}

			daPos += Conductor.timeScale[0] * (1000 * (60 / daBPM));
		}

		return daPos;
	}
}
