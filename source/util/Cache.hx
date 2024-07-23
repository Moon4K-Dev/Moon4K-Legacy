package util;

import flixel.graphics.FlxGraphic;
import openfl.media.Sound;
import hxcodec.flixel.FlxVideo;

class Cache {
	public static var soundCache:Map<String, Sound> = [];
	public static var imageCache:Map<String, FlxGraphic> = [];
	public static var vidyaCache:Map<String, FlxVideo> = [];

	public static function addToCache(key:String, value:Dynamic, cacheName:String) {
		var cache = convertStringToCache(cacheName);

		cache.set(key, value);
	}

	public static function getFromCache(key:String, cacheName:String) {
		var cache = convertStringToCache(cacheName);

		return cache.get(key);
	}

	public static function convertStringToCache(name:String):Dynamic {
		switch (name.toLowerCase()) {
			case "sound":
				return soundCache;
			case "image":
				return imageCache;
			case "video":
					return vidyaCache;
			default:
				return new Map<String, String>();
		}
	}
}
