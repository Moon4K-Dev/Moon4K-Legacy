package options;

import flixel.FlxG;

class Options {
	public static var framerate(get, set):Int;

	static function get_framerate():Int {
		return 60;
	}

	static function set_framerate(value:Int):Int {
		return 60;
	}

	// functions
	static public function init() {
		FlxG.save.bind("Moon4K", "YoPhlox");

		for (option in defaultOptions) {
			if (getData(option[0]) == null)
				saveData(option[0], option[1]);
		}
	}

	static public function saveData(save:String, value:Dynamic) {
		Reflect.setProperty(FlxG.save.data, save, value);
		FlxG.save.flush();
	}

	static public function getData(save:String):Dynamic {
		return Reflect.getProperty(FlxG.save.data, save);
	}

	static public function resetData() {
		FlxG.save.erase();
		init();
	}

	// variables
	static public var defaultOptions:Array<Array<Dynamic>> = [
		[
			"uibinds",
			[
				["BACKSPACE", "ENTER", "LEFT", "DOWN", "UP", "RIGHT"],
				["ESCAPE", "SPACE", "A", "S", "W", "D"]
			]
		],
		["downscroll", false],
		["botplay", false],
		["scroll-speed", 1.0],
		["lane-offset", 100],
		["note-offset", 0],
		["fps-cap", 120],
		["ui-skin", 1],
	];

	static public function getNoteskins():Array<String> {
		var swagArray:Array<String> = [];

		#if sys
		swagArray = sys.FileSystem.readDirectory(Sys.getCwd() + "content/images/ui-skins");
		#else
		swagArray = ["default", "funkin"];
		#end

		return swagArray;
	}
}
