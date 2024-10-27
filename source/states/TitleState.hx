package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import sys.FileSystem;
import sys.io.File;
import util.AudioDisplay;
import util.Util;
using StringTools;

class TitleState extends SwagState {
	var titlesprite:FlxSprite;
	var songList:Array<String> = [];
	var currentSongIndex:Int = 0;
	var songText:FlxText;
	var instructionsText:FlxText;

	override public function create():Void {
		songList = loadSongList();
		
		songText = new FlxText(10, 10, 0, "", 16);
		songText.setFormat(null, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(songText);

		if (songList.length > 0) {
			playSong(0);
		} else {
			updateSongText();
		}

		var audio:AudioDisplay = new AudioDisplay(FlxG.sound.music, 0, FlxG.height, FlxG.width, FlxG.height, 200, FlxColor.WHITE);
		add(audio);

		titlesprite = new FlxSprite(0, -50).loadGraphic(Paths.image('sexylogobyhiro'));
		titlesprite.scale.set(0.45, 0.45);
		titlesprite.updateHitbox();
		titlesprite.screenCenter(Y);
		add(titlesprite);

		instructionsText = new FlxText(10, FlxG.height - 30, 0, "Use LEFT/RIGHT arrows to change songs", 16);
		instructionsText.setFormat(null, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(instructionsText);

		FlxG.stage.window.title = "Moon4K - TitleState";
		#if desktop
		updateDiscordPresence();
		#end

		super.create();
	}

	override public function update(elapsed:Float):Void {
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
			transitionState(new MainMenuState());
		}

		if (FlxG.keys.justPressed.LEFT) {
			changeSong(-1);
		} else if (FlxG.keys.justPressed.RIGHT) {
			changeSong(1);
		}

		super.update(elapsed);
	}

	private function loadSongList():Array<String> {
		var songs:Array<String> = [];
		var musicFolder = "music";
		var chartsFolder = "charts";

		songs = songs.concat(findOggFiles(musicFolder));
		songs = songs.concat(findOggFiles(chartsFolder));

		trace("Found " + songs.length + " songs");

		return songs;
	}

	private function findOggFiles(folder:String):Array<String> {
		var files:Array<String> = [];
		#if sys
		var fullPath = Sys.getCwd() + 'assets/' + folder;
		if (sys.FileSystem.exists(fullPath) && sys.FileSystem.isDirectory(fullPath)) {
			traverseDirectory(fullPath, files);
		}
		#end
		return files;
	}

	private function traverseDirectory(dir:String, files:Array<String>):Void {
		#if sys
		for (file in sys.FileSystem.readDirectory(dir)) {
			var path = dir + "/" + file;
			if (sys.FileSystem.isDirectory(path)) {
				traverseDirectory(path, files);
			} else if (file.endsWith(".ogg")) {
				files.push(path);
			}
		}
		#end
	}

	private function playSong(index:Int):Void {
		if (songList.length > 0) {
			currentSongIndex = (index + songList.length) % songList.length;
			var songPath = songList[currentSongIndex];
			var sound = Util.getSound(songPath, false, true);
			if (sound != null) {
				FlxG.sound.playMusic(sound, 1);
				updateSongText();
				updateDiscordPresence();
			} else {
				trace("Failed to load sound: " + songPath);
				playSong(index + 1);
			}
		} else {
			FlxG.sound.music.stop();
			updateSongText();
		}
	}

	private function changeSong(direction:Int):Void {
		playSong(currentSongIndex + direction);
	}

	private function updateSongText():Void {
		if (songText != null) {
			if (songList.length > 0) {
				var songName = extractSongName(songList[currentSongIndex]);
				songText.text = "Now Playing: " + songName;
			} else {
				songText.text = "No songs available";
			}
		}
	}

	private function extractSongName(fullPath:String):String {
		var relativePath = fullPath.replace(Sys.getCwd(), "");
		var parts = relativePath.split("/");
		
		var chartsIndex = parts.indexOf("charts");
		if (chartsIndex != -1 && chartsIndex < parts.length - 2) {
			return parts[chartsIndex + 1];
		} else {
			var fileName = parts[parts.length - 1];
			var songName = fileName.substr(0, fileName.lastIndexOf("."));
			return songName;
		}
	}

	private function updateDiscordPresence():Void {
		#if desktop
		var songName = extractSongName(songList[currentSongIndex]);
		if (songList.length > 0) {
			Discord.changePresence("Listening to music in the TitleState", "Now playing: " + songName, null);
		} else {
			Discord.changePresence("In TitleState", "No songs available", null);
		}
		#end
	}
}
