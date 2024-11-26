package game;

#if desktop
import sys.io.File;
import sys.FileSystem;
import sys.io.FileOutput;
#end
import haxe.Json;
#if web
import openfl.net.SharedObject;
#end

class HighScoreManager {
	private static var filePath:String = "data/highscores.json";
	private static var sharedObject:Dynamic;

	public static var highScores:Array<Dynamic>;

	public static function init():Void {
		#if web
		sharedObject = SharedObject.getLocal("highscores");
		if (sharedObject.data.highScores != null) {
			highScores = sharedObject.data.highScores;
		} else {
			highScores = [];
			saveHighScores();
		}
		#else
		if (FileSystem.exists(filePath)) {
			var fileContent:String = File.getContent(filePath);
			highScores = Json.parse(fileContent);
		} else {
			highScores = [];
			saveHighScores();
		}
		#end
	}

	public static function saveHighScore(song:String, score:Int, misses:Int):Void {
		highScores.push({song: song, score: score, misses: misses});
		highScores.sort((a, b) -> {
			if (b.score != a.score)
				return b.score - a.score;
			return a.misses - b.misses;
		});
		if (highScores.length > 10) {
			highScores.pop();
		}
		saveHighScores();
	}

	private static function saveHighScores():Void {
		#if web
		sharedObject.data.highScores = highScores;
		sharedObject.flush();
		#else
		var jsonString:String = Json.stringify(highScores);
		var fileOutput = File.write(filePath);
		fileOutput.writeString(jsonString);
		fileOutput.close();
		#end
	}

	public static function getHighScores():Array<Dynamic> {
		return highScores;
	}

	public static function getHighScoreForSong(song:String):Dynamic {
		for (score in highScores) {
			if (score.song == song) {
				return score;
			}
		}

		for (misses in highScores) {
			if (misses.song == song) {
				return misses;
			}
		}
		return {song: song, score: 0, misses: 0};
	}
}
