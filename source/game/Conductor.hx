package game;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = Math.floor((safeFrames / 60) * 1000); // is calculated in create(), is safeFrames in milliseconds

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static var timeScale:Array<Int> = [4, 4]; // no use this yet cuz it buggy and stuffs

	public static function recalculateStuff(?multi:Float = 1)
	{
		safeZoneOffset = Math.floor((safeFrames / 60) * 1000) * multi;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / (16 / timeScale[1]);
	}

	public static function changeBPM(newBpm:Float, ?multi:Float = 1)
	{
		bpm = newBpm;

		recalculateStuff(multi);
	}
}