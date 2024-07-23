package game;

import sys.io.File;
import sys.FileSystem;
import sys.io.FileOutput;
import haxe.Json;

class HighScoreManager {
    private static var filePath:String = "assets/highscores.json";
    public static var highScores:Array<Dynamic>;

    public static function init():Void {
        if (FileSystem.exists(filePath)) {
            var fileContent:String = File.getContent(filePath);
            highScores = Json.parse(fileContent);
        } else {
            highScores = [];
            saveHighScores();
        }
    }

    public static function saveHighScore(song:String, score:Int, misses:Int):Void {
        highScores.push({song: song, score: score, misses: misses});
        highScores.sort((a, b) -> {
            if (b.score != a.score) return b.score - a.score;
            return a.misses - b.misses; // less misses is better :pray:
        });
        if (highScores.length > 10) {
            highScores.pop();
        }
        saveHighScores();
    }

    private static function saveHighScores():Void {
        var jsonString:String = Json.stringify(highScores);
        var fileOutput = File.write(filePath);
        fileOutput.writeString(jsonString);
        fileOutput.close();
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
