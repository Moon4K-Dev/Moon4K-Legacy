package;

import flixel.math.FlxPoint;

class Utils {
	// MAIN SWAGGER SHITS!
	public static var VERSION:String = " v1.0";
	static public var soundExt:String = ".mp3";
	public static final discordRpc:String = "1298163987464060978"; /// OG RPC: 1139936005785407578, CURRENT ONE IS SONIC X SHADOW GENS RPC ID

	public function create():Void {
		#if (!web)
		soundExt = '.ogg';
		#end
	}
}
