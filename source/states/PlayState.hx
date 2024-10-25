package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxInput.FlxInputState;
import options.Controls;
import options.Options;
import ui.StrumNote;
import game.Note;
import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import game.Conductor;
import game.Song;
import util.Util;
import ui.UI;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
#if desktop
import sys.FileSystem;
import hxcodec.flixel.FlxVideo;
import hscript.Hscript;
#end
import flixel.math.FlxRandom;
import flixel.system.FlxAssets.FlxShader;

class PlayState extends SwagState {
	static public var instance:PlayState;

	static public var songMultiplier:Float = 1;

	public var speed:Float = 1;
	public var song:SwagSong;

	var strumNotes:FlxTypedGroup<StrumNote>;
	var spawnNotes:Array<Note> = [];

	var keyCount:Int = 4;
	var laneOffset:Int = 100;

	var strumArea:FlxSprite;
	var notes:FlxTypedGroup<Note>;

	static public var strumY:Float = 0;
	public var curSong:String = '';

	var hud:UI;
	private var camHUD:FlxCamera;

	public var songScore:Int = 0;
	public var misses:Int = 0;
	public var notesHit:Int = 0;
	public var accuracy:Float = 0.00;
	public var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	public var pfc:Bool = false;
	public var curRank:String = "P";
	private var ratingText:FlxText;

	// swag
	var startedCountdown:Bool = false;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	// health
	static public var healthGain:Float = 10;
	static public var healthLoss:Float = -10;

	public var health:Float = 1;

	// Discord RPC variables
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#if desktop
	public var video:FlxVideo = new FlxVideo();
	#end
	// GameJolt Achievement crap
	var achievementget:Bool = false;
	// HSCRIPT
	#if desktop
	public var script:Hscript = new Hscript();
	#end

	public var botPlay:Bool = false;

	override public function new() {
		super();

		if (song == null) {
			song = {
				song: "",
				notes: [],
				bpm: 100,
				sections: 0,
				sectionLengths: [],
				speed: 1,
				keyCount: 4,
				timescale: [4, 4]
			};
		}

		curSong = Freeplay.instance.selectedSong;
		instance = this;

		botPlay = Options.getData('botplay');
	}

	override public function create() {
		FlxG.stage.window.title = "Moon4K - PlayState";

		#if desktop
		checkAndSetBackground();
		#else
		var swagbg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/bg'));
		swagbg.setGraphicSize(Std.int(swagbg.width * 1.1));
		swagbg.updateHitbox();
		swagbg.screenCenter();
		swagbg.visible = true;
		swagbg.antialiasing = true;
		add(swagbg);
		#end

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);
		hud = new UI();
		add(hud);
		
		#if desktop
		script.interp.variables.set("add", function(value:Dynamic)
		{
			add(value);
		});

		script.call("onCreate"); // Stuff may or NOT work properly lol.
		#end
		super.create();

		laneOffset = Options.getData('lane-offset');

		strumArea = new FlxSprite(0, 50);
		strumArea.visible = false;

		if (Options.getData('downscroll'))
			strumArea.y = FlxG.height - 150;

		strumArea.y -= 20;

		add(strumArea);

		if (songMultiplier < 0.1)
			songMultiplier = 0.1;

		Conductor.changeBPM(song.bpm, songMultiplier);

		Conductor.recalculateStuff(songMultiplier);

		Conductor.safeZoneOffset *= songMultiplier;

		resetSongPos();

		if (song.keyCount != null)
			keyCount = song.keyCount;
		else
			keyCount = 4;

		speed = Options.getData('scroll-speed');

		speed /= songMultiplier;

		if (speed < 0.1 && songMultiplier > 1)
			speed = 0.1;

		strumNotes = new FlxTypedGroup<StrumNote>();
		add(strumNotes);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		for (i in 0...keyCount) {
			var noteskin:String = Options.getNoteskins()[Options.getData('ui-skin')];
			var daStrum:StrumNote = new StrumNote(0, strumArea.y, i, noteskin);
			daStrum.screenCenter(X);
			daStrum.x += (keyCount * ((laneOffset / 2) * -1)) + (laneOffset / 2);
			daStrum.x += i * laneOffset;

			strumNotes.add(daStrum);
		}

		Controls.init();

		hud.cameras = [camHUD];
		strumNotes.cameras = [camHUD];
		notes.cameras = [camHUD];

		startingSong = true;
		startCountdown();
		generateNotes(song.song);
		#if desktop
		checkandrunscripts();
		script.call("createPost");
		#end

		ratingText = new FlxText(0, 0, 0, "", 26);
		ratingText.setFormat(Paths.font('Zero G.ttf'), 26, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ratingText.screenCenter();
		ratingText.visible = false;
		add(ratingText);
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;
		if (accuracy >= 100.00)
		{
			if (pfc && misses == 0)
				accuracy = 100.00;
			else
			{
				accuracy = 99.98;
				pfc = false;
			}
		}
		accuracy = FlxMath.roundDecimal(accuracy, 2);
	}
	
	function updateRank()
	{
		if (accuracy == 100.00) // Straight 100% accuracy the whole song
			curRank = "P";
		else if (accuracy >= 90.00) // 90 or higher up to 99.9
			curRank = "A";
		else if (accuracy >= 80.00) // 80 or higher (up to 89.9)
			curRank = "B";
		else if (accuracy >= 70.00) // 80 or higher (up to 79.9)
			curRank = "C";
		else if (accuracy >= 60.00) // 60 or higher (up to 69.9)
			curRank = "D";
		else
			curRank = "F"; // yeah u suck lol!
	}
	
	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

	#if desktop
	function checkandrunscripts():Void {
		var daSongswagg = song.song;
		var scriptPath:String = 'assets/charts/' + daSongswagg + '/script.hx';
		if (sys.FileSystem.exists(scriptPath)) {
			var scriptContent = sys.io.File.getContent(scriptPath);
			script.loadScript(scriptContent);
			trace("SCRIPT FOUND AND RUNNING LOL!");
		} else {
			trace("no script found for the current song");
		}
	}	
	function checkAndSetBackground():Void {
		var daSongswag = song.song;
		var bgImagePath:String = 'assets/charts/' + daSongswag + '/image.png';
		var bgVideoPath:String = 'assets/charts/' + daSongswag + '/video.mp4';
		if (FileSystem.exists(bgImagePath)) {
			trace(bgImagePath);
			var songbg:FlxSprite = new FlxSprite(-80).loadGraphic(Util.getchartImage(daSongswag + '/image'));
			songbg.setGraphicSize(Std.int(songbg.width * 1.1));
			songbg.updateHitbox();
			songbg.screenCenter();
			songbg.visible = true;
			songbg.antialiasing = true;
			add(songbg);
		}
		else if (FileSystem.exists(bgVideoPath)) {
			trace(bgVideoPath);
			video.play(bgVideoPath, true); // location:String, shouldLoop:Bool = false
		}
	}
	#end

	function startSong():Void {
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;
		startingSong = false;
		// FlxG.sound.playMusic(Paths.song(curSong +'/music'));
		var daSong = song.song;
		FlxG.sound.playMusic(Util.getSong(daSong));
		FlxG.sound.music.onComplete = endSong;
	}

	function startCountdown():Void {
		var startTimer:FlxTimer;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 5000, function(tmr:FlxTimer) {
			switch (swagCounter) {
				case 0:
					trace("THREE!");
				case 1:
					trace("TWO!");
				case 2:
					trace("ONE!");
				case 3:
					trace("GO!");
				case 4:
			}
			swagCounter += 1;
		}, 5);
	}

	function endSong():Void {
		FlxG.sound.music.stop();
		#if desktop
		video.stop();
		#end
		if (!Options.getData('botplay'))
        	HighScoreManager.saveHighScore(curSong, songScore, misses);

		#if desktop
		if (curSong == 'run-insane' && !Options.getData('botplay'))
		{
			Main.gjToastManager.createToast(GJInfo.imagePath, "You outran him....", "Beat Run-Insane");
			GameJoltAPI.getTrophy(240114);
			achievementget = true;
		}	
		#end

		transitionState(new ResultsState());
	}

	function resetSongPos() {
		Conductor.songPosition = 0 - (Conductor.crochet * 4.5);
	}

	private var paused:Bool = false;
	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;
	
	override public function update(elapsed:Float) 
	{
		#if desktop
		if (!Options.getData('botplay')) {
			Discord.changePresence("Playing: " + curSong, "Score: " + songScore + " - " + accuracy + "% - " + notesHit + " combo");
		} else {
			Discord.changePresence("Playing: " + curSong, "Botplay!");
		}
		#end
		inputFunction();

		if (health > 2)
			health = 2;

		if (health <= 0)
		{
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;
			FlxG.sound.music.stop();
			transitionState(new states.Freeplay());
		}

		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		} else {
			if (FlxG.sound.music != null && FlxG.sound.music.active && FlxG.sound.music.playing) {
				Conductor.songPosition = FlxG.sound.music.time;
			} else {
				Conductor.songPosition += (FlxG.elapsed) * 1000;
			}

			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition) {
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		#if desktop
		script.call("update", [elapsed]);
		#end
		super.update(elapsed);

		if (spawnNotes[0] != null) {
			while (spawnNotes.length > 0 && spawnNotes[0].strum - Conductor.songPosition < (1500 * songMultiplier)) {
				var dunceNote:Note = spawnNotes[0];
				notes.add(dunceNote);

				var index:Int = spawnNotes.indexOf(dunceNote);
				spawnNotes.splice(index, 1);
			}
		}

		for (note in notes) {
			var strum = strumNotes.members[note.direction % keyCount];
			if (Options.getData('downscroll'))
				note.y = strum.y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
			else
				note.y = strum.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
		}

		if (FlxG.keys.justPressed.BACKSPACE)
			transitionState(new MainMenuState());

		#if !(mobile)
		if (FlxG.keys.anyJustPressed([ENTER, ESCAPE]) && startedCountdown) {
			var pauseSubState = new substates.PauseSubstate();
			paused = true;
			#if desktop
			video.pause();
			Discord.changePresence("Paused on: " + curSong, "Score: " + songScore + " - " + accuracy + "% - " + notesHit + " combo");
			#end
			openSubState(pauseSubState);
		}
		#end

		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
			}
		}

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.sound.music.stop();
			#if desktop
			video.stop();
			transitionState(new ChartingState());
			ChartingState.instance.song = song;
			#end
		}

		if (FlxG.keys.justPressed.EIGHT) {
			FlxG.sound.music.stop();
			#if desktop
			video.stop();
			#end
			transitionState(new ResultsState());
		}

		#if desktop
		script.call("updatePost", [elapsed]);
		#end
	}

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
			}
		}
		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.play();
			}
			paused = false;
		}
		super.closeSubState();
	}

	var justPressed:Array<Bool> = [];
	var pressed:Array<Bool> = [];
	var released:Array<Bool> = [];

	function rateNoteHit(noteMs:Float):Int 
	{
		var rating:Int = 0;
		if (Math.abs(noteMs) < 50) {
			rating = 350;
			totalNotesHit += 1;
			health += 0.023;
			ratingText.text = "SWAGGER";
		} else if (Math.abs(noteMs) < 100) {
			rating = 300;
			totalNotesHit += 0.65;
			health += 0.004;
			pfc = false;
			ratingText.text = "GOOD";
		} else if (Math.abs(noteMs) < 200) {
			rating = 50;
			pfc = false;
			totalNotesHit += 0.05;
			ratingText.text = "SHIT!";
		} else {
			rating = 0;
			pfc = false;
			totalNotesHit += 0;
			ratingText.text = "Nuh uh!";
		}
		
		ratingText.visible = true;
		ratingText.alpha = 1;
		
		return rating;
	}

	function inputFunction() 
	{
		justPressed = [];
		pressed = [];
		released = [];

		var actionKeys = ["left", "down", "up", "right"];

		for (i in 0...keyCount) {
			var action = actionKeys[i];
			justPressed.push(Controls.getPressEvent(action, 'justPressed'));
			pressed.push(Controls.getPressEvent(action, 'pressed'));
			released.push(Controls.getPressEvent(action, 'justReleased'));
		}

		for (i in 0...justPressed.length) {
			if (justPressed[i]) {
				strumNotes.members[i].playAnim("press", true);
			}
		}

		for (i in 0...released.length) {
			if (released[i]) {
				strumNotes.members[i].playAnim("static");
			}
		}

		var possibleNotes:Array<Note> = [];

		for (note in notes) {
			note.calculateCanBeHit();

			if (note.canBeHit && !note.isSustainNote && !note.wasGoodHit)
				possibleNotes.push(note);
		}

		possibleNotes.sort((a, b) -> Std.int(a.strum - b.strum));

		if (botPlay) {
			// Botplay snazz
			for (note in possibleNotes) {
				if (Conductor.songPosition >= note.strum) {
					noteHit(note, "perfect");
					strumNotes.members[note.direction].playAnim("confirm", true);
				}
			}
		} else {
			// Player snazz
			for (i in 0...keyCount) {
				if (justPressed[i]) {
					var hitNotes:Array<Note> = [];
					for (note in possibleNotes) {
						if (note.direction == i && !note.wasGoodHit) {
							hitNotes.push(note);
						}
					}

					if (hitNotes.length > 0) {
						var closestNote:Note = hitNotes[0];
						var noteMs = (Conductor.songPosition - closestNote.strum) / songMultiplier;
						var hitResult = judgeNote(noteMs);

						if (hitResult != "miss") {
							closestNote.wasGoodHit = true;
							strumNotes.members[i].playAnim("confirm", true);
							noteHit(closestNote, hitResult);
						}
					}
				}
			}
		}

		for (note in possibleNotes) {
			if (Conductor.songPosition > note.strum + (120 * songMultiplier) && note != null && !botPlay) { 
				noteMiss(note.direction);
				notes.remove(note);
				note.kill();
				note.destroy();
			}
		}
	}

	function judgeNote(noteMs:Float):String {
		var absNoteMs = Math.abs(noteMs);
		if (absNoteMs <= 16) return "perfect";
		if (absNoteMs <= 64) return "great";
		if (absNoteMs <= 97) return "good";
		if (absNoteMs <= 127) return "ok";
		if (absNoteMs <= 151) return "meh";
		if (absNoteMs <= 188) return "bad";
		return "miss";
	}

	function noteMiss(direction:Int) {
		health -= 0.04;
		misses++;
		songScore -= 10;
		totalNotesHit += 0;
		notesHit = 0;
		updateAccuracy();
		updateRank();
		#if desktop
		script.call("noteMiss", [direction]);
		#end
	}
	
	function noteHit(note:Note, judgment:String) {
		var score:Int = 0;
		var accuracy:Float = 0;

		switch (judgment) {
			case "perfect":
				score = 350;
				accuracy = 1;
				health += 0.023;
			case "great":
				score = 300;
				accuracy = 0.98;
				health += 0.015;
			case "good":
				score = 200;
				accuracy = 0.65;
				health += 0.008;
			case "ok":
				score = 100;
				accuracy = 0.25;
			case "meh":
				score = 50;
				accuracy = 0.1;
			case "bad":
				score = 20;
				accuracy = 0;
		}

		songScore += score;
		totalNotesHit += accuracy;
		notesHit++;
		updateAccuracy();
		updateRank();

		#if desktop
		script.call("goodNoteHit", [note, judgment]);
		#end

		notes.remove(note);
		note.kill();
		note.destroy();
	}

	function generateNotes(dataPath:String):Void {
		for (section in song.notes) {
			Conductor.recalculateStuff(songMultiplier);

			for (note in section.sectionNotes) {
				var strum = strumNotes.members[note.noteData % keyCount];

				var daStrumTime:Float = note.noteStrum + (Options.getData('song-offset') * songMultiplier);
				var daNoteData:Int = Std.int(note.noteData % keyCount);

				var oldNote:Note;

				if (spawnNotes.length > 0)
					oldNote = spawnNotes[Std.int(spawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(strum.x, strum.y, daNoteData, daStrumTime, Options.getNoteskins()[Options.getData("ui-skin")], false, false,
					keyCount);
				swagNote.scrollFactor.set();
				swagNote.lastNote = oldNote;

				swagNote.playAnim('note');

				spawnNotes.push(swagNote);
			}
		}

		spawnNotes.sort(sortByShit);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strum, Obj2.strum);
	}

    override public function destroy():Void
    {
        super.destroy();
        Controls.destroy();
    }
}
