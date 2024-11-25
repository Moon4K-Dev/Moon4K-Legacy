package;

import flixel.FlxG;
import options.Controls;

class SaveManager {
	private static inline var SAVE_NAME:String = "moon4k";

	public static function initializeSave():Void {
		FlxG.save.bind(SAVE_NAME);
	}

	public static function hasSaveData():Bool {
		return FlxG.save.data.initialized == true;
	}

	public static function getOption(option:String):Bool {
		return switch (option.toLowerCase()) {
			default: false;
		}
	}

	public static function setOption(option:String, value:Bool):Void {
		switch (option.toLowerCase()) {
			// nuh
		}
	}

	public static function setControls(controls:Map<String, Array<Int>>):Void {
		trace('Debug: Saving controls to FlxG.save: ${controls}');
		FlxG.save.data.controls = controls;
		FlxG.save.flush();
	}

	public static function getControls():Map<String, Array<Int>> {
		var loadedControls:Map<String, Array<Int>> = FlxG.save.data.controls;
		trace('Debug: Loaded controls from FlxG.save: ${loadedControls}');
		return loadedControls;
	}

	public static function initializeSaveData():Void {
		if (!hasSaveData()) {
			FlxG.save.data.initialized = true;
			FlxG.save.data.controls = null;
			FlxG.save.data.playerName = "Player";
			FlxG.save.data.profilePicture = "default";
			FlxG.save.flush();
		}

		if (FlxG.save.data.controls == null) {
			var defaultControlsMap = new Map<String, Array<Int>>();
			for (action => keys in Controls.defaultActions) {
				defaultControlsMap[action] = keys.map(key -> key == null ? -1 : key);
			}
			FlxG.save.data.controls = defaultControlsMap;
			FlxG.save.flush();
		}
	}
}
