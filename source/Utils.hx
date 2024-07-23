package;

import flixel.math.FlxPoint;

class Utils {
	// MAIN SWAGGER SHITS!
	public static var VERSION:String = " v1.0 (DEMO)";
	static public var soundExt:String = ".mp3";
	public static final discordRpc:String = "1139936005785407578";

	public function create():Void {
		#if (!web)
		soundExt = '.ogg';
		#end
	}
}
