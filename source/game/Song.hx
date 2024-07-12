package game;

import game.Section.SwagSection;

using StringTools;

typedef SwagSong  =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;

	var keyCount:Null<Int>;
	var timescale:Array<Int>;
}