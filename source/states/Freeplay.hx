package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

class Freeplay extends SwagState {
	var grpSongs:FlxTypedGroup<FlxText>;
	var songs:Array<String>;

	public var curSelected:Int = 0;

	var scoreText:FlxText;
	var diffText:FlxText;

	public var selectedSong:String;

	static public var instance:Freeplay;

	var songData:Dynamic;

	public var songInfoData:Array<Dynamic>;

	var songHeight:Int = 100;
	var noSongsText:FlxText;

	public function new() {
		super();
		this.curSelected = 0;
		instance = this;
		loadSongs();
	}

	override public function create() {
		FlxG.stage.window.title = "YA4KRG Demo - FreeplayState";
		Discord.changePresence("Selecting a song...", null);

		var coolBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/menubglol'), 0.2, 0, true, true);
		coolBackdrop.velocity.set(50, 30);
		coolBackdrop.alpha = 0.7;
		add(coolBackdrop);

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var leText:String = "Press R to scan the songs folder. // Press TAB to see the Song Info";
		var size:Int = 18;
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		super.create();

		grpSongs = new FlxTypedGroup<FlxText>();
		add(grpSongs);

		updateSongList();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
		add(scoreText);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		changeSelection();
		super.create();
	}

	override public function update(elapsed:Float) {
		if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE) {
			transitionState(new states.MainMenuState());
		}

		if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN) {
			changeSelection(FlxG.keys.justPressed.UP ? -1 : 1);
		}

		if (FlxG.keys.justPressed.ENTER) {
			loadSongJson(selectedSong);
			transitionState(new PlayState());
			PlayState.instance.song = songData;
		}

		if (FlxG.keys.justPressed.TAB) {
			loadSongInfoJson(selectedSong);
			var infosubstate = new substates.SongInfoSubstate();
			openSubState(infosubstate);
		}

		if (FlxG.keys.justPressed.R) {
			rescanSongs();
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;

		if (curSelected < 0)
			curSelected = 0;
		if (curSelected >= grpSongs.length)
			curSelected = grpSongs.length - 1;

		var startY:Int = 50;
		var spacing:Int = 100;

		grpSongs.forEach((txt:FlxText) -> {
			txt.y = startY + (txt.ID * spacing);
			txt.color = FlxColor.WHITE;

			if (txt.ID == curSelected) {
				txt.size = 36;
				txt.alpha = 1.0;
			} else {
				txt.size = 32;
				txt.alpha = 0.7;
			}
		});

		selectedSong = songs[curSelected];
	}

	function loadSongInfoJson(songName:String):Void {
		var path = "assets/charts/" + songName + "/songInfo.json";
		var jsonContent:String = File.getContent(path);
		songInfoData = Json.parse(jsonContent);
		trace("Loaded from assets: " + path);
	}

	function loadSongJson(songName:String):Void {
		var path = "assets/charts/" + songName + "/" + songName + ".json";
		var jsonContent:String = File.getContent(path);
		songData = Json.parse(jsonContent);
		trace("Loaded from assets: " + path);
	}

	function loadSongs():Void {
		songs = [];
		var dataDir:String = "assets/charts/";
		var directories:Array<String> = FileSystem.readDirectory(dataDir);

		for (dir in directories) {
			var fullPath:String = dataDir + dir;
			if (FileSystem.isDirectory(fullPath)) {
				songs.push(dir);
			}
		}
	}

	function updateSongList():Void {
		grpSongs.clear();
		loadSongs();

		if (songs.length == 0) {
			if (noSongsText == null) {
				noSongsText = new FlxText(0, FlxG.height / 2 - 10, FlxG.width, "There's no songs in the songs folder!", 24);
				noSongsText.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.RED, CENTER);
				add(noSongsText);
			}
		} else {
			if (noSongsText != null) {
				remove(noSongsText);
				noSongsText = null;
			}
			for (i in 0...songs.length) {
				var songTxt:FlxText = new FlxText(0, 50 + (i * songHeight), FlxG.width, songs[i], 32);
				songTxt.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER);
				songTxt.scrollFactor.set();
				songTxt.ID = i;
				grpSongs.add(songTxt);
			}
			selectedSong = songs[curSelected];
		}
	}

	function rescanSongs():Void {
		updateSongList();
		changeSelection();
	}
}
