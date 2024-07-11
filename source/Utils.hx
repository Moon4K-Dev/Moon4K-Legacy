package;

import flixel.math.FlxPoint;

class Utils
{
    // MAIN SWAGGER SHITS!
    public static var VERSION:String = "0.0.1";
    static public var soundExt:String = ".mp3";

    public function create():Void
	{
		#if (!web)
		soundExt = '.ogg';
		#end
    }
}