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
import game.UI;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import sys.FileSystem;
import hxcodec.flixel.FlxVideo;
import tea.SScript;

class PlayState extends SwagState {
	static public var instance:PlayState;

	static public var songMultiplier:Float = 1;

	public var speed:Float = 2.5;
	public var song:SwagSong;

	var strumNotes:FlxTypedGroup<StrumNote>;
	var spawnNotes:Array<Note> = [];

	var keyCount:Int = 4;
	var laneOffset:Int = 100;

	var strumArea:FlxSprite;
	var notes:FlxTypedGroup<Note>;

	static public var strumY:Float = 0;
	public static var curSong:String = '';

	var hud:UI;
	private var camHUD:FlxCamera;

	public var songScore:Int = 0;
	public var misses:Int = 0;

	var rating:FlxSprite = new FlxSprite();
	// swag
	var startedCountdown:Bool = false;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	// health
	static public var healthGain:Float = 10;
	static public var healthLoss:Float = -10;

	public var health:Float = 100;
	public var minHealth:Float = 0;
	public var maxHealth:Float = 100;

	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;
	// Discord RPC variables
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	public var video:FlxVideo = new FlxVideo();
	// Buddies shit
	public static var reimu:FlxSprite;
	public static var boyfriend:FlxSprite;

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
	}

	override public function create() {
		FlxG.stage.window.title = "YA4KRG Demo - PlayState";

		//FlxG.camera.bgColor = 0xFF333333;
		checkAndSetBackground();

		// Buddies shit
        reimu = new FlxSprite(0, 0).loadGraphic(Paths.image('buddies/reimu/reimu'));
		if (!Options.getData('reimulol')) {  reimu.visible = false;} else {reimu.visible = true;}  
		reimu.scale.set(0.5, 0.5);
        add(reimu);

        boyfriend = new FlxSprite(770, 450);
        boyfriend.frames = Paths.getSparrowAtlas('buddies/bf/BOYFRIEND');
        boyfriend.animation.addByPrefix('idle', 'BF idle dance', 24, false);
		boyfriend.animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
		boyfriend.animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
		boyfriend.animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
		boyfriend.animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
		boyfriend.animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
		boyfriend.animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
		boyfriend.animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
		boyfriend.animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
		if (!Options.getData('bffunky')) {  boyfriend.visible = false;} else {boyfriend.visible = true;}  
        boyfriend.animation.play('idle', true, false);
		boyfriend.animation.finishCallback = function(name:String)
        {
            boyfriend.animation.play('idle', true, false);
        };
        add(boyfriend);

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);

		super.create();

		SScript.superClassInstances["PlayState"] = this;
		var scripts:Array<SScript> = SScript.listScripts('assets/scripts/'); // Every script with a class extending PlayState will use 'this' instance
		var songscripts:Array<SScript> = SScript.listScripts('assets/charts/' + song.song + "/"); // Every script with a class extending PlayState will use 'this' instance

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

		speed = song.speed;

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

		hud = new UI();
		add(hud);

		hud.cameras = [camHUD];
		strumNotes.cameras = [camHUD];
		notes.cameras = [camHUD];

		startingSong = true;
		startCountdown();
		generateNotes(song.song);
		checkandrunscripts();
	}

	function checkandrunscripts():Void {
		//var songscript:SScript = new SScript("script.hx");
		var daSongswagg = song.song;
		var scriptPath:String = 'assets/charts/' + daSongswagg + '/script.hx';
		if (FileSystem.exists(scriptPath)) 
		{
			var songscript:SScript = new SScript("assets/charts/" + daSongswagg + "/script.hx");
			var randomNumber:Float = songscript.call('returnRandom').returnValue;
		}	
		else {trace("no script found for the current song");} // probably the most disgusting thing I've ever wrote...
	}
	function checkAndSetBackground():Void {
		var daSongswag = song.song;
		var bgImagePath:String = 'assets/charts/' + daSongswag + '/image.png';
		trace(bgImagePath);
		var bgVideoPath:String = 'assets/charts/' + daSongswag + '/video.mp4';
		trace(bgVideoPath);
		if (FileSystem.exists(bgImagePath)) {
			var songbg:FlxSprite = new FlxSprite(-80).loadGraphic(Util.getchartImage(daSongswag + '/image'));
			songbg.setGraphicSize(Std.int(songbg.width * 1.1));
			songbg.updateHitbox();
			songbg.screenCenter();
			songbg.visible = true;
			songbg.antialiasing = true;
			add(songbg);
		}
		else if (FileSystem.exists(bgVideoPath)) {
			video.play(bgVideoPath, true); // location:String, shouldLoop:Bool = false
		}
	}

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
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		video.stop();
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
		if (!Options.getData('botplay')) {
			Discord.changePresence("Playing: " + curSong + " with " + songScore + " Score and " + misses + " Misses!");
		} else {
			Discord.changePresence("Playing: " + curSong + " with Botplay!");
		}

		if (!Options.getData('reimulol')) 
		{        
			// no reimu input :(
		}
		else
		{
			if (FlxG.keys.pressed.A)
			{
				reimu.x -= 10;
				reimu.flipX = false;
			}
	
			if (FlxG.keys.pressed.L)
			{
				reimu.x += 10;
				reimu.flipX = true;
			}
	
			if (FlxG.keys.pressed.K)
			{
				reimu.y -= 10;
			}
	
			if (FlxG.keys.pressed.S)
			{
				reimu.y += 10;
			}
		}

		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		} else {
			Conductor.songPosition = FlxG.sound.music.time;

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

		super.update(elapsed);

		if (FlxG.sound.music != null && FlxG.sound.music.active && FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;
		else
			Conductor.songPosition += (FlxG.elapsed) * 1000;

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

			if (Conductor.songPosition > note.strum + (120 * songMultiplier) && note != null) {
				notes.remove(note);
				note.kill();
				note.destroy();
				misses++;
				songScore -= 25;

				if (Options.getData('bffunky')) 
				{
					switch (note.direction) 
					{
						case 0:
							boyfriend.animation.play('singLEFTmiss', true, false);
						case 1:
							boyfriend.animation.play('singDOWNmiss', true, false);
						case 2:
							boyfriend.animation.play('singUPmiss', true, false);
						case 3:
							boyfriend.animation.play('singRIGHTmiss', true, false);
					}
				}
			}
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		if (FlxG.keys.justPressed.BACKSPACE)
			transitionState(new MainMenuState());

		#if !(mobile)
		if (FlxG.keys.anyJustPressed([ENTER, ESCAPE]) && startedCountdown) {
			var pauseSubState = new substates.PauseSubstate();
			paused = true;
			video.pause();
			Discord.changePresence("Paused on: " + curSong);
			openSubState(pauseSubState);
		}
		#end

		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
			}
		}

		if (FlxG.keys.justPressed.SEVEN) {
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			video.stop();
			transitionState(new ChartingState());
			ChartingState.instance.song = song;
		}

		if (FlxG.keys.justPressed.EIGHT) {
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			video.stop();
			transitionState(new ResultsState());
		}

		if (!Options.getData('botplay')) {inputFunction();} else {}
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

	function inputFunction() {
		var binds:Array<String> = Options.getData('keybinds')[keyCount - 1];

		justPressed = [];
		pressed = [];
		released = [];

		for (i in 0...keyCount) {
			justPressed.push(false);
			pressed.push(false);
			released.push(false);
		}

		for (i in 0...binds.length) {
			justPressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.JUST_PRESSED);
			pressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.PRESSED);
			released[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.RELEASED);
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

			if (!Options.getData('botplay')) {
				if (note.canBeHit && !note.tooLate && !note.isSustainNote)
					possibleNotes.push(note);
			} else {
				if ((!note.isSustainNote ? note.strum : note.strum - 1) <= Conductor.songPosition)
					possibleNotes.push(note);
			}
		}

		possibleNotes.sort((a, b) -> Std.int(a.strum - b.strum));

		var doNotHit:Array<Bool> = [false, false, false, false];
		var noteDataTimes:Array<Float> = [-1, -1, -1, -1];

		if (possibleNotes.length > 0) {
			for (i in 0...possibleNotes.length) {
				var note = possibleNotes[i];

				if (((justPressed[note.direction] && !doNotHit[note.direction]) && !Options.getData('botplay'))
					|| Options.getData('botplay')) {
					var noteMs = (Conductor.songPosition - note.strum) / songMultiplier;

					if (Options.getData('botplay'))
						noteMs = 0;

					var roundedDecimalNoteMs:Float = FlxMath.roundDecimal(noteMs, 3);
					var noteDiff:Float = Math.abs(Conductor.songPosition);

					// curRating = "marvelous";

					var score:Int = 350;
					var daRating:String = "sick";

					if (noteDiff > Conductor.safeZoneOffset * 1) {
						daRating = "sick";
						trace("sick!");
						score = 350;
					}
					if (noteDiff > Conductor.safeZoneOffset * 0.9) {
						daRating = "good";
						trace("good!");
						score = 200;
					} else if (noteDiff > Conductor.safeZoneOffset * 0.7) {
						daRating = "bad";
						trace("BAD");
						score = 100;
					} else if (noteDiff > Conductor.safeZoneOffset * 0.9) {
						daRating = "shit";
						trace("SHIT");
						score = 50;
					}
					songScore += score;

					var placement:String = "my balls hurt";
					var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
					coolText.screenCenter();
					coolText.x = FlxG.width * 0.55;

					rating.loadGraphic('assets/images/' + daRating + ".png");
					rating.screenCenter(X);
					rating.x = coolText.x - 40;
					rating.y -= 60;
					rating.acceleration.y = 550;
					rating.velocity.y -= FlxG.random.int(140, 175);
					rating.setGraphicSize(Std.int(rating.width * 0.7));
					rating.updateHitbox();
					rating.antialiasing = true;
					rating.velocity.x -= FlxG.random.int(0, 10);
					add(rating);
					rating.updateHitbox();

					noteDataTimes[note.direction] = note.strum;
					doNotHit[note.direction] = true;

					strumNotes.members[note.direction].playAnim("confirm", true);

					if (Options.getData('bffunky'))
					{
						switch (note.direction) 
						{
							case 0:
								boyfriend.animation.play('singLEFT', true, false);
							case 1:
								boyfriend.animation.play('singDOWN', true, false);
							case 2:
								boyfriend.animation.play('singUP', true, false);
							case 3:
								boyfriend.animation.play('singRIGHT', true, false);
						}
					}

					note.active = false;
					notes.remove(note);
					note.kill();
					note.destroy();
				}
			}

			if (possibleNotes.length > 0) {
				for (i in 0...possibleNotes.length) {
					var note = possibleNotes[i];

					if (note.strum == noteDataTimes[note.direction] && doNotHit[note.direction]) {
						note.active = false;
						notes.remove(note);
						note.kill();
						note.destroy();
					}
				}
			}
		}
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

	override function destroy()
	{
		super.destroy();

		SScript.superClassInstances.clear(); // May cause memory leaks if not cleared
	}
}
