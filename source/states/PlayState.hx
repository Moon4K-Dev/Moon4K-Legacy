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
#if desktop
import sys.FileSystem;
import hxcodec.flixel.FlxVideo;
#end
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
	public var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;
	public var rank:String = "P";

	// swag
	var startedCountdown:Bool = false;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	// health
	static public var healthGain:Float = 10;
	static public var healthLoss:Float = -10;

	public var health:Float = 1;

	var healthBarBG:FlxSprite;
	var healthBar:FlxBar;
	// Discord RPC variables
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#if desktop
	public var video:FlxVideo = new FlxVideo();
	#end
	// Buddies shit
	public static var reimu:FlxSprite;
	public static var boyfriend:FlxSprite;
	// GameJolt Achievement crap
	var achievementget:Bool = false;

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
		FlxG.stage.window.title = "YA4KRG - PlayState";

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

		healthBarBG = new FlxSprite(!FlxG.save.data.quaverbar ? 0 : FlxG.width, !FlxG.save.data.quaverbar ? FlxG.height * 0.88 : 0).loadGraphic(Paths.image('game/healthBar'));	
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.angle = 90;
		healthBarBG.x = -290;
		healthBarBG.y = 340;

		healthBar = new FlxBar(5, healthBarBG.y - 287.5, BOTTOM_TO_TOP, Std.int(healthBarBG.height - 8), Std.int(healthBarBG.width - 8), this, 'health', 0, 1);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFFFFFF, 0xFF66FF33);
		add(healthBar);
		add(healthBarBG);

		hud.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		strumNotes.cameras = [camHUD];
		notes.cameras = [camHUD];

		startingSong = true;
		startCountdown();
		generateNotes(song.song);
		#if desktop
		checkandrunscripts();
		#end
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;
		if (accuracy >= 100.00)
		{
			if (ss && misses == 0)
				accuracy = 100.00;
			else
			{
				accuracy = 99.98;
				ss = false;
			}
		}
	}
	
	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

	#if desktop
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
			Discord.changePresence("Playing: " + curSong + " with " + songScore + " Score and " + misses + " Misses!");
		} else {
			Discord.changePresence("Playing: " + curSong + " with Botplay!");
		}
		#end

		if (health > 2)
			health = 2;

		if (health <= 0)
		{
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;
			FlxG.sound.music.stop();
			//openSubState(new GameOverSubstate());
			transitionState(new Freeplay());
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
				updateAccuracy();
				misses++;
				health -= 0.04;
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

		if (FlxG.keys.justPressed.BACKSPACE)
			transitionState(new MainMenuState());

		#if !(mobile)
		if (FlxG.keys.anyJustPressed([ENTER, ESCAPE]) && startedCountdown) {
			var pauseSubState = new substates.PauseSubstate();
			paused = true;
			#if desktop
			video.pause();
			Discord.changePresence("Paused on: " + curSong);
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

		inputFunction();
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

	function rateNoteHit(noteMs:Float):Int {
		var rating:Int = 0;
		if (Math.abs(noteMs) < 50) {
			rating = 350;
			totalNotesHit += 1;
			health += 0.023;
			trace("SWAGGER");
		} else if (Math.abs(noteMs) < 100) {
			rating = 300;
			totalNotesHit += 0.65;
			health += 0.004;
			ss = false;
			trace("GOOD");
		} else if (Math.abs(noteMs) < 200) {
			rating = 50;
			ss = false;
			totalNotesHit += 0.05;
			trace("SHIT");
		} else {
			rating = 0;
			ss = false;
			totalNotesHit += 0;
			trace("Nuh uh!");			
		}
		return rating;
	}

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

					var score:Int = rateNoteHit(noteMs);
					songScore += score;

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
					updateAccuracy();
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