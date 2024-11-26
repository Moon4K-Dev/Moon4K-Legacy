package game;

import game.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSong = {
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var sections:Int;
	var sectionLengths:Array<Dynamic>;
	var speed:Float;
	var keyCount:Null<Int>;
	var timescale:Array<Int>;
}

class Song {
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var sections:Int;
	public var sectionLengths:Array<Dynamic> = [];
	public var speed:Float = 1;
	public var keyCount:Null<Int>;
	public var timescale:Array<Int>;

	public function new(song, notes, bpm, sections, keyCount, timescale) {
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
		this.sections = sections;
		this.keyCount = keyCount;
		this.timescale = timescale != null ? timescale : [];

		for (i in 0...notes.length) {
			this.sectionLengths.push(notes[i]);
		}
	}
}
