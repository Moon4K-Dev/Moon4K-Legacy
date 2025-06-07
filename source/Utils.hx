package;

import flixel.math.FlxPoint;

class Utils {
	// MAIN SWAGGER SHITS!
	public static final VERSION:String = "1.2";
	static public var soundExt:String = ".mp3";
	public static final discordRpc:String = "1139936005785407578";

	public function create():Void {
		#if (!web)
		soundExt = '.ogg';
		#end
	}
}
