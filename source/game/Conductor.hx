package game;

/**
 * ...
 * @author
 */
class Conductor
{
	public static var bpm:Int = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var offset:Float = 0;
    public static var stepsPerSection:Int = 16;
	public static var safeFrames:Int = 5;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
    public static var timeScale:Array<Int> = [4, 4];

	public function new() {}

	public static function recalculateStuff(?multi:Float = 1)
	{
		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / timeScale[1];
		stepsPerSection = Math.floor((16 / timeScale[1]) * timeScale[0]);
	}    
}