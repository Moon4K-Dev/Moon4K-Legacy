package game;

import game.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong  = 
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var sections:Int;
	var sectionLengths:Array<Dynamic>;
	var keyCount:Null<Int>;
	var timescale:Array<Int>;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var sections:Int;
	public var sectionLengths:Array<Dynamic> = [];	
	public var keyCount:Null<Int>;
	public var timescale:Array<Int>;

	public function new(song, notes, bpm, sections, keyCount, timescale)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
		this.sections = sections;
		this.keyCount = keyCount;
		this.timescale = timescale != null ? timescale : [];

		for (i in 0...notes.length)
		{
			this.sectionLengths.push(notes[i]);
		}
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Assets.getText('assets/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json').trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		trace(swagShit.notes[0]);

		return swagShit;
	}
}
