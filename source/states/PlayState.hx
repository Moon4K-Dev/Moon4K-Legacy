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
import haxe.Json;
import sys.io.File;
import util.Cache;
import flixel.graphics.FlxGraphic;
import flixel.sound.FlxSound;
import openfl.media.Sound;
import game.Section.SwagNote;
import network.Server;

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
	private var laneUnderlay:FlxSprite;
	private var camHUD:FlxCamera;

	public var songScore:Int = 0;
	public var misses:Int = 0;
	public var notesHit:Int = 0;
	public var accuracy:Float = 0.00;
	public var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var accuracyDefault:Float = 0.00;

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

	public var vocals:FlxSound;

	// multiplayer shit
	public var isMultiplayer:Bool = false;
	public var p1Score:Int = 0;
	public var p2Score:Int = 0;
	public var p1Misses:Int = 0;
	public var p2Misses:Int = 0;
	public var p1Accuracy:Float = 0.00;
	public var p2Accuracy:Float = 0.00;
	public var currentPlayer:Int = 0; // 0 = p1, 1 = p2
	private var actionKeys:Array<String> = ["left", "down", "up", "right"];

	public var p1StrumNotes:FlxTypedGroup<StrumNote>;
	public var p2StrumNotes:FlxTypedGroup<StrumNote>;
	public var currentStrumNotes:FlxTypedGroup<StrumNote>; 

	public var p1TotalNotesHit:Float = 0;
	public var p2TotalNotesHit:Float = 0;
	public var p1TotalPlayed:Int = 0;
	public var p2TotalPlayed:Int = 0;

	static public var lastMultiplayerState:Bool = false;

	public var isOnline:Bool = false;
	public var isHost:Bool = false;

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
		isMultiplayer = lastMultiplayerState;

		botPlay = Options.getData('botplay');
		FlxG.sound.music.stop();
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

		#if desktop
		script.interp.variables.set("add", function(value:Dynamic) {
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

		laneUnderlay = new FlxSprite(0, 0);
		laneUnderlay.makeGraphic(Std.int(Note.swagWidth * 4), FlxG.height, 0xA4000000);
		laneUnderlay.scrollFactor.set();
		laneUnderlay.screenCenter(X);
		add(laneUnderlay);

		members.remove(laneUnderlay);
		members.insert(0, laneUnderlay);

		strumNotes = new FlxTypedGroup<StrumNote>();
		add(strumNotes);

		p1StrumNotes = new FlxTypedGroup<StrumNote>();
		p2StrumNotes = new FlxTypedGroup<StrumNote>();
		add(p1StrumNotes);
		add(p2StrumNotes);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		add(hud);

		for (i in 0...keyCount) {
			var noteskin:String = Options.getNoteskins()[Options.getData('ui-skin')];
			var daStrum:StrumNote = new StrumNote(0, strumArea.y, i, noteskin);
			
			daStrum.x = (FlxG.width * 0.25);
			daStrum.x += (keyCount * ((laneOffset / 2) * -1)) + (laneOffset / 2);
			daStrum.x += i * laneOffset;

			p1StrumNotes.add(daStrum);
		}

		for (i in 0...keyCount) {
			var noteskin:String = Options.getNoteskins()[Options.getData('ui-skin')];
			var daStrum:StrumNote = new StrumNote(0, strumArea.y, i, noteskin);
			
			daStrum.x = (FlxG.width * 0.75); 
			daStrum.x += (keyCount * ((laneOffset / 2) * -1)) + (laneOffset / 2);
			daStrum.x += i * laneOffset;

			p2StrumNotes.add(daStrum);
		}

		if (!isMultiplayer) {
			for (strum in p1StrumNotes.members) {
				strum.screenCenter(X);
				strum.x += (keyCount * ((laneOffset / 2) * -1)) + (laneOffset / 2);
				strum.x += strum.direction * laneOffset;
			}
			p2StrumNotes.visible = false;
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

		lastMultiplayerState = isMultiplayer;
	}

	function updateAccuracy() {
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function updateRank() {
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

	function truncateFloat(number:Float, precision:Int):Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
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
		var imagePath = 'assets/charts/${daSongswag}/image';
		var imagePathAlt = 'assets/charts/${daSongswag}/${daSongswag}-bg';
		var imagePathAlt2 = 'assets/charts/${daSongswag}/${daSongswag}';
		var bgVideoPath:String = 'assets/charts/' + daSongswag + '/video.mp4';

		var loadedImage:FlxGraphic = Cache.getFromCache(imagePath, "image");
		var loadedImageAlt:FlxGraphic = Cache.getFromCache(imagePathAlt, "image");
		var loadedImageAlt2:FlxGraphic = Cache.getFromCache(imagePathAlt2, "image");

		if (loadedImage == null && loadedImageAlt == null && loadedImageAlt2 == null) {
			loadedImage = Util.getchartImage('${daSongswag}/image');
			if (loadedImage != null) {
				Cache.addToCache(imagePath, loadedImage, "image");
				trace('Successfully loaded and cached image: $imagePath');
			} else {
				loadedImageAlt = Util.getchartImage('${daSongswag}/${daSongswag}-bg');
				if (loadedImageAlt != null) {
					Cache.addToCache(imagePathAlt, loadedImageAlt, "image");
					trace('Successfully loaded and cached image: $imagePathAlt');
				} else {
					loadedImageAlt2 = Util.getchartImage('${daSongswag}/${daSongswag}');
					if (loadedImageAlt2 != null) {
						Cache.addToCache(imagePathAlt2, loadedImageAlt2, "image");
						trace('Successfully loaded and cached image: $imagePathAlt2');
					}
				}
			}
		}

		var songbg:FlxSprite = new FlxSprite(-80);
		if (loadedImage != null) {
			songbg.loadGraphic(loadedImage);
		} else if (loadedImageAlt != null) {
			songbg.loadGraphic(loadedImageAlt);
		} else if (loadedImageAlt2 != null) {
			songbg.loadGraphic(loadedImageAlt2);
		} else if (FileSystem.exists(bgVideoPath)) {
			video.play(bgVideoPath, true);
			return;
		} else {
			trace('No background found for: $daSongswag');
			var swagbg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/bg'));
			swagbg.setGraphicSize(Std.int(swagbg.width * 1.1));
			swagbg.updateHitbox();
			swagbg.screenCenter();
			swagbg.visible = true;
			swagbg.antialiasing = true;
			add(swagbg);
			return;
		}

		songbg.setGraphicSize(Std.int(songbg.width * 1.1));
		songbg.updateHitbox();
		songbg.screenCenter();
		songbg.visible = true;
		songbg.antialiasing = true;
		add(songbg);
	}
	#end

	function startSong():Void {
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;
		startingSong = false;
		// FlxG.sound.playMusic(Paths.song(curSong +'/music'));
		var daSong = song.song;
		loadSongAudio(daSong);
		FlxG.sound.music.onComplete = endSong;
	}

	private function loadSongAudio(daSong:String):Void {
		var directory = "assets/charts/" + daSong + "/";
		
		if (FileSystem.exists(directory + "Inst.ogg")) {
			var instPath = directory + "Inst.ogg";
			FlxG.sound.playMusic(Sound.fromFile(instPath));
			
			if (FileSystem.exists(directory + "Voices.ogg")) {
				var voicesPath = directory + "Voices.ogg";
				vocals = new FlxSound();
				vocals.loadEmbedded(Sound.fromFile(voicesPath));
				FlxG.sound.music.play();
				vocals.play();
				
				FlxG.sound.music.time = 0;
				vocals.time = 0;
				
				FlxG.sound.music.volume = 1;
				vocals.volume = 1;
			} else {
				vocals = null;
			}
		} else {
			vocals = null;
			FlxG.sound.playMusic(Util.getSong(daSong));
		}
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

		transitionState(new ResultsState());
	}

	function resetSongPos() {
		Conductor.songPosition = 0 - (Conductor.crochet * 4.5);
	}

	private var paused:Bool = false;
	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	override public function update(elapsed:Float) {
		#if desktop
		if (!Options.getData('botplay')) {
			Discord.changePresence("Playing: " + curSong, "Score: " + songScore + " - " + accuracy + "% - " + notesHit + " combo");
		}
		else if (isMultiplayer && !Options.getData('botplay')) {
			Discord.changePresence("Playing: " + curSong, "Against P2!"); // will update to show scores later lol
		}
		else {
			Discord.changePresence("Playing: " + curSong, "Botplay!");
		}
		#end
		inputFunction();

		if (health > 2)
			health = 2;

		if (health <= 0 && !isMultiplayer) {
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;
			FlxG.sound.music.pause();
			if (vocals != null) {
				vocals.pause();
			}
			transitionState(new substates.GameOverSubState());
		}
		else if (FlxG.keys.justPressed.R && !isMultiplayer) {
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;
			FlxG.sound.music.pause();
			if (vocals != null) {
				vocals.pause();
			}
			transitionState(new substates.GameOverSubState());
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

		if (vocals != null) {
			if (Math.abs(FlxG.sound.music.time - vocals.time) > 100) {
				vocals.time = FlxG.sound.music.time;
			}
			
			if (paused) {
				FlxG.sound.music.pause();
				vocals.pause();
			}
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
			var strumGroup = note.isP1Note ? p1StrumNotes : p2StrumNotes;
			if (strumGroup != null) {
				var strum = strumGroup.members[note.direction % keyCount];
				if (strum != null) {
					if (Options.getData('downscroll'))
						note.y = strum.y + (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
					else
						note.y = strum.y - (0.45 * (Conductor.songPosition - note.strum) * FlxMath.roundDecimal(speed, 2));
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
			Discord.changePresence("Paused on: " + curSong, "Score: " + songScore + " - " + accuracy + "% - " + notesHit + " combo");
			#end
			openSubState(pauseSubState);
		}
		#end

		if (paused) {
			if (FlxG.sound.music != null) {
				if (vocals != null) {
					vocals.pause();
				}
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
			vocals.stop();
			transitionState(new ResultsState());
		}

		#if desktop
		script.call("updatePost", [elapsed]);
		#end

		for (note in notes.members) {
			if (note != null && !note.wasGoodHit && !note.isSustainNote) {
				var noteTime = note.strum - Conductor.songPosition;
				if (noteTime < -Conductor.safeZoneOffset) {
					note.wasGoodHit = true;
					if ((note.isP1Note && !isMultiplayer) || 
						(isMultiplayer && ((note.isP1Note && currentPlayer == 0) || (!note.isP1Note && currentPlayer == 1)))) {
						noteMiss(note.direction);
					}
					notes.remove(note, true);
				}
			}
		}

		if (isOnline) {
			Server.sendMessage("note_hit", {
				time: Conductor.songPosition
			});
			
			Server.sendMessage("score_update", {
				score: currentPlayer == 0 ? p1Score : p2Score,
				accuracy: currentPlayer == 0 ? p1Accuracy : p2Accuracy,
				misses: currentPlayer == 0 ? p1Misses : p2Misses
			});
		}

		if (FlxG.keys.justPressed.ENTER && !isOnline) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			openSubState(new PauseSubState());
		}
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

	function inputFunction() {
		if (isMultiplayer) {
			// P1 Controls (WASD)
			for (i in 0...4) {
				if (FlxG.keys.justPressed.A && i == 0
					|| FlxG.keys.justPressed.S && i == 1
					|| FlxG.keys.justPressed.W && i == 2
					|| FlxG.keys.justPressed.D && i == 3) {
					currentPlayer = 0;
					currentStrumNotes = p1StrumNotes;
					handleNotePress(i);
					p1StrumNotes.members[i].playAnim("press", true);
				}
				if (FlxG.keys.justReleased.A && i == 0
					|| FlxG.keys.justReleased.S && i == 1
					|| FlxG.keys.justReleased.W && i == 2
					|| FlxG.keys.justReleased.D && i == 3) {
					p1StrumNotes.members[i].playAnim("static");
				}
			}

			// P2 Controls (Arrow Keys)
			for (i in 0...4) {
				if (FlxG.keys.justPressed.LEFT && i == 0
					|| FlxG.keys.justPressed.DOWN && i == 1
					|| FlxG.keys.justPressed.UP && i == 2
					|| FlxG.keys.justPressed.RIGHT && i == 3) {
					currentPlayer = 1;
					currentStrumNotes = p2StrumNotes;
					handleNotePress(i);
					p2StrumNotes.members[i].playAnim("press", true);
				}
				if (FlxG.keys.justReleased.LEFT && i == 0
					|| FlxG.keys.justReleased.DOWN && i == 1
					|| FlxG.keys.justReleased.UP && i == 2
					|| FlxG.keys.justReleased.RIGHT && i == 3) {
					p2StrumNotes.members[i].playAnim("static");
				}
			}
		} else {
			justPressed = [];
			pressed = [];
			released = [];
			
			for (i in 0...keyCount) {
				justPressed.push(Controls.getPressEvent(actionKeys[i], 'justPressed'));
				pressed.push(Controls.getPressEvent(actionKeys[i], 'pressed'));
				released.push(Controls.getPressEvent(actionKeys[i], 'justReleased'));
			}

			currentPlayer = 0; 
			currentStrumNotes = p1StrumNotes;

			for (i in 0...justPressed.length) {
				if (justPressed[i] && p1StrumNotes != null && i < p1StrumNotes.members.length) {
					p1StrumNotes.members[i].playAnim("press", true);
					handleNotePress(i);
				}
			}

			for (i in 0...released.length) {
				if (released[i] && p1StrumNotes != null && i < p1StrumNotes.members.length) {
					p1StrumNotes.members[i].playAnim("static");
				}
			}
		}
	}

	function handleNotePress(direction:Int) {
		if (currentStrumNotes == null || direction >= currentStrumNotes.members.length) return;
		
		var possibleNotes:Array<Note> = [];
				
		for (note in notes) {
			if (note == null) continue;
			note.calculateCanBeHit();
			
			if (note.canBeHit && !note.isSustainNote && !note.wasGoodHit && 
				note.direction == direction && 
				((currentPlayer == 0 && note.isP1Note) || (currentPlayer == 1 && !note.isP1Note))) {
				possibleNotes.push(note);
			}
		}
		
		possibleNotes.sort((a, b) -> Std.int(a.strum - b.strum));
		
		if (possibleNotes.length > 0) {
			var closestNote = possibleNotes[0];
			var noteMs = (Conductor.songPosition - closestNote.strum) / songMultiplier;
			var hitResult = judgeNote(noteMs);
			
			if (hitResult != "miss") {
				closestNote.wasGoodHit = true;
				currentStrumNotes.members[direction].playAnim("confirm", true);
				noteHit(closestNote, hitResult);
			} else {
				noteMiss(direction);
			}
		}
	}

	function judgeNote(noteMs:Float):String {
		var absNoteMs = Math.abs(noteMs);
		if (absNoteMs <= 16)
			return "perfect";
		if (absNoteMs <= 64)
			return "great";
		if (absNoteMs <= 97)
			return "good";
		if (absNoteMs <= 127)
			return "ok";
		if (absNoteMs <= 151)
			return "meh";
		if (absNoteMs <= 188)
			return "bad";
		return "miss";
	}

	function noteMiss(direction:Int) {
		if (currentPlayer == 0) {
			p1Misses++;
			p1Score -= 10;
			if (p1TotalPlayed == 0) {
				p1TotalNotesHit = 0;
				p1TotalPlayed = 1;
			} else {
				p1TotalPlayed++;
			}
			p1Accuracy = Math.max(0, p1TotalNotesHit / p1TotalPlayed * 100);
		} else {
			p2Misses++;
			p2Score -= 10;
			if (p2TotalPlayed == 0) {
				p2TotalNotesHit = 0;
				p2TotalPlayed = 1;
			} else {
				p2TotalPlayed++;
			}
			p2Accuracy = Math.max(0, p2TotalNotesHit / p2TotalPlayed * 100);
		}
		
		health -= 0.04;
		notesHit = 0;
		
		#if desktop
		script.call("noteMiss", [direction]);
		#end
	}

	function noteHit(note:Note, judgment:String) {
		var score:Int = 0;
		var accuracyValue:Float = 0;

		switch (judgment) {
			case "perfect":
				score = 350;
				accuracyValue = 1;
				health += 0.023;
			case "great":
				score = 300;
				accuracyValue = 0.75;
				health += 0.015;
			case "good":
				score = 200;
				accuracyValue = 0.50;
				health += 0.008;
			case "ok":
				score = 100;
				accuracyValue = 0.25;
			case "meh":
				score = 50;
				accuracyValue = 0.1;
			case "bad":
				score = 20;
				accuracyValue = 0;
		}

		if (currentPlayer == 0) {
			p1Score += score;
			p1TotalNotesHit += accuracyValue;
			p1TotalPlayed++;
			p1Accuracy = Math.max(0, p1TotalNotesHit / p1TotalPlayed * 100);
		} else {
			p2Score += score;
			p2TotalNotesHit += accuracyValue;
			p2TotalPlayed++;
			p2Accuracy = Math.max(0, p2TotalNotesHit / p2TotalPlayed * 100);
		}

		notesHit++;
		
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
				if (isMultiplayer) {
					var p1Strum = p1StrumNotes.members[note.noteData % keyCount];
					var p2Strum = p2StrumNotes.members[note.noteData % keyCount];
					createNote(note, p1Strum, true);
					createNote(note, p2Strum, false);
				} else {
					var strum = p1StrumNotes.members[note.noteData % keyCount];
					createNote(note, strum, true);
				}
			}
		}
		spawnNotes.sort(sortByShit);
	}

	private function createNote(noteData:SwagNote, strum:StrumNote, isP1:Bool):Void {
		var daStrumTime:Float = noteData.noteStrum + (Options.getData('song-offset') * songMultiplier);
		var daNoteData:Int = Std.int(noteData.noteData % keyCount);

		var swagNote:Note = new Note(strum.x, strum.y, daNoteData, daStrumTime, 
			Options.getNoteskins()[Options.getData("ui-skin")], false, keyCount);
		swagNote.sustainLength = noteData.noteSus;
		swagNote.scrollFactor.set();
		swagNote.isP1Note = isP1;
		
		spawnNotes.push(swagNote);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strum, Obj2.strum);
	}

	override public function destroy():Void {
		super.destroy();
		Controls.destroy();
	}

	public function handleOnlineNoteHit(data:Dynamic) {
		if (currentPlayer == 0) {
			for (strum in p2StrumNotes.members) {
				if (strum.direction == data.direction) {
					strum.playAnim('confirm');
					break;
				}
			}
		} else {
			for (strum in p1StrumNotes.members) {
				if (strum.direction == data.direction) {
					strum.playAnim('confirm');
					break;
				}
			}
		}
	}

	public function updateOpponentScore(score:Int, accuracy:Float, misses:Int) {
		if (!isOnline) return;
		
		if (currentPlayer == 0) {
			p2Score = score;
			p2Accuracy = accuracy;
			p2Misses = misses;
		} else {
			p1Score = score;
			p1Accuracy = accuracy;
			p1Misses = misses;
		}
		
		if (hud != null) {
			hud.updateHUD();
		}
	}
}
