package util;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.utils.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
#if desktop
import hxcodec.flixel.FlxVideo;
#end

using StringTools;

class Util {
	static public var soundExt:String = #if web '.mp3' #else '.ogg' #end;

	/**
	 * Return a font from the `assets` folder with the correct format, ttf & otf are supported.
	 * @param   fontPath            Path to the font.
	 */
	static public function getFont(font:String) // defaults to "assets/fonts/main.ttf"
	{
		var fontPath:String = 'assets/fonts/$font.ttf';
		#if web
		if (Assets.exists(fontPath)) {
			return Assets.getText(fontPath);
		} else {
			fontPath = 'assets/fonts/$font.otf';
			if (Assets.exists(fontPath)) {
				return Assets.getText(fontPath);
			}
		}
		return Assets.getText('assets/fonts/main.ttf');
		#else
		if (sys.FileSystem.exists(Sys.getCwd() + 'assets/fonts/$font.ttf'))
			return Sys.getCwd() + 'assets/fonts/$font.ttf';
		else if (sys.FileSystem.exists(Sys.getCwd() + 'assets/fonts/$font.otf'))
			return Sys.getCwd() + 'assets/fonts/$font.otf';

		return Sys.getCwd() + 'assets/fonts/main.ttf';
		#end
	}

	/**
	 * Return an image from the `assets` folder.
	 * Only works for static png files. Use getSparrow for animated sprites.
	 * @param   imagePath            Path to the image.
	 */
	static public function getImage(path:String, ?customPath:Bool = false):Dynamic {
		var png = path;

		if (!customPath)
			png = "assets/images/" + png;
		else
			png = "assets/" + png;

		#if web
		if (Assets.exists(png + ".png")) {
			if (Cache.getFromCache(png, "image") == null) {
				var graphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(png + ".png"), false, png, false);
				graphic.destroyOnNoUse = false;

				Cache.addToCache(png, graphic, "image");
			}

			return Cache.getFromCache(png, "image");
		}
		#else
		if (sys.FileSystem.exists(Sys.getCwd() + png + ".png")) {
			if (Cache.getFromCache(png, "image") == null) {
				var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(Sys.getCwd() + png + ".png"), false, png, false);
				graphic.destroyOnNoUse = false;

				Cache.addToCache(png, graphic, "image");
			}

			return Cache.getFromCache(png, "image");
		}
		#end

		return null;
	}

	static public function getchartImage(path:String, ?customPath:Bool = false):Dynamic {
		var png = path;

		if (!customPath)
			png = "assets/charts/" + png;
		else
			png = "assets/" + png;

		#if web
		if (Assets.exists(png + ".png")) {
			if (Cache.getFromCache(png, "image") == null) {
				var graphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(png + ".png"), false, png, false);
				graphic.destroyOnNoUse = false;

				Cache.addToCache(png, graphic, "image");
			}

			return Cache.getFromCache(png, "image");
		}
		#else
		if (sys.FileSystem.exists(Sys.getCwd() + png + ".png")) {
			if (Cache.getFromCache(png, "image") == null) {
				var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(Sys.getCwd() + png + ".png"), false, png, false);
				graphic.destroyOnNoUse = false;

				Cache.addToCache(png, graphic, "image");
			}

			return Cache.getFromCache(png, "image");
		}
		#end

		return null;
	}

	static public function getchartVideo(path:String, ?customPath:Bool = false):Dynamic {
		var videoPath = path;

		if (!customPath)
			videoPath = "assets/charts/" + videoPath;
		else
			videoPath = "assets/" + videoPath;

		#if desktop
		if (sys.FileSystem.exists(Sys.getCwd() + videoPath + ".mp4")) {
			if (Cache.getFromCache(videoPath, "video") == null) {
				var video = new FlxVideo();
				video.onEndReached.add(video.dispose);

				Cache.addToCache(videoPath, video, "video");
			}

			return Cache.getFromCache(videoPath, "video");
		}
		#end

		return null;
	}

	/**
	 * Return an animated image from the `assets` folder using a png and xml.
	 * Only works if there is a png and xml file with the same directory & name.
	 * @param   imagePath            Path to the image.
	 */
	static public function getSparrow(pngName:String, ?xmlName:Null<String>, ?customPath:Bool = false) {
		var png = pngName;
		var xml = xmlName;

		if (xmlName == null)
			xml = png;

		if (customPath) {
			png = 'assets/$png';
			xml = 'assets/$xml';
		} else {
			png = 'assets/images/$png';
			xml = 'assets/images/$xml';
		}

		#if web
		if (Assets.exists(png + ".png") && Assets.exists(xml + ".xml")) {
			var xmlData = Assets.getText(xml + ".xml");

			if (Cache.getFromCache(png, "image") == null) {
				var graphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(png + ".png"), false, png, false);
				graphic.destroyOnNoUse = false;

				Cache.addToCache(png, graphic, "image");
			}

			return FlxAtlasFrames.fromSparrow(Cache.getFromCache(png, "image"), xmlData);
		}
		#else
		if (sys.FileSystem.exists(Sys.getCwd() + png + ".png") && sys.FileSystem.exists(Sys.getCwd() + xml + ".xml")) {
			var xmlData = sys.io.File.getContent(Sys.getCwd() + xml + ".xml");

			if (Cache.getFromCache(png, "image") == null) {
				var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(Sys.getCwd() + png + ".png"), false, png, false);
				graphic.destroyOnNoUse = false;

				Cache.addToCache(png, graphic, "image");
			}

			return FlxAtlasFrames.fromSparrow(Cache.getFromCache(png, "image"), xmlData);
		}
		#end

		return FlxAtlasFrames.fromSparrow("assets/images/errorSparrow" + ".png", "assets/images/errorSparrow" + ".xml");
	}

	/**
	 * Return a sound from the `assets` folder.
	 * MP3 is used for web, OGG is used for Desktop.
	 * @param   soundPath            Path to the sound.
	 * @param   isMusic              Define if the sound is from the `music` folder.
	 * @param   customPath           Define a custom path for your sound. EX: `data/mySound`
	 */
	static public function getSound(path:String, ?music:Bool = false, ?customPath:Bool = false):Dynamic {
		var base:String = "";

		if (!customPath) {
			base = music ? "music/" : "sounds/";
		}

		var gamingPath = base + path + soundExt;
		if (Cache.getFromCache(gamingPath, "sound") == null) {
			var sound:Sound = null;
			#if web
			if (Assets.exists("assets/" + gamingPath)) {
				sound = Assets.getSound("assets/" + gamingPath);
			}
			#else
			sound = Sound.fromFile("assets/" + gamingPath);
			#end
			if (sound != null) {
				Cache.addToCache(gamingPath, sound, "sound");
				trace("Loaded sound from assets: " + gamingPath);
			}
		}

		return Cache.getFromCache(gamingPath, "sound");
	}

	/**
	 * Return a song from the `assets` folder.
	 * MP3 is used for web, OGG is used for Desktop.
	 * @param   songName            The name of the song.
	 */
	static public function getSong(song:String):Dynamic {
		var sound = getSound('charts/$song/$song', false, true);
		return sound;
	}

	/**
	 * Return text from a file in the `assets` folder.
	 * @param   filePath            Path to the file.
	 */
	static public function getText(filePath:String) {
		#if web
		if (Assets.exists("assets/" + filePath)) {
			return Assets.getText("assets/" + filePath);
		}
		#else
		if (sys.FileSystem.exists(Sys.getCwd() + "assets/" + filePath))
			return sys.io.File.getContent(Sys.getCwd() + "assets/" + filePath);
		#end

		return "";
	}

	/**
	 * Return the contents of a JSON file in the `assets` folder.
	 * @param   jsonPath            Path to the json.
	 */
	static public function getJson(filePath:String) {
		#if web
		if (Assets.exists('assets/$filePath.json')) {
			return Json.parse(Assets.getText('assets/$filePath.json'));
		}
		#else
		if (sys.FileSystem.exists(Sys.getCwd() + 'assets/$filePath.json'))
			return Json.parse(sys.io.File.getContent(Sys.getCwd() + 'assets/$filePath.json'));
		#end

		return null;
	}

	/**
	 * Limit how big or small a value can get. Example:
	 * If the value is less than -1, we set it back to -1.
	 * If the value is bigger than 1, we set it back to 1.
	 * @param   value            The initial value.
	 * @param   min              The minimum value.
	 * @param   max              The maximum value.
	 */
	static public function boundTo(value:Float, min:Float, max:Float):Float {
		var newValue:Float = value;

		if (newValue < min)
			newValue = min;
		else if (newValue > max)
			newValue = max;

		return newValue;
	}
}
