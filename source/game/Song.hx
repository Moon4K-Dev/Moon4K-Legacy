package game;

import game.Section;

using StringTools;

typedef Song =
{
	var song:String;
	var notes:Array<Section>;
	var bpm:Float;

	var keyCount:Null<Int>;
	var timescale:Array<Int>;
}