package options;

import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;
import options.Options;

class Controls
{
	// ui controls
	// held down variants
	static public var UI_LEFT_P:Bool = false;
	static public var UI_DOWN_P:Bool = false;
	static public var UI_UP_P:Bool = false;
	static public var UI_RIGHT_P:Bool = false;
	static public var BACK_P:Bool = false;
	static public var ACCEPT_P:Bool = false;

	// just pressed variants
	static public var UI_LEFT:Bool = false;
	static public var UI_DOWN:Bool = false;
	static public var UI_UP:Bool = false;
	static public var UI_RIGHT:Bool = false;
	static public var BACK:Bool = false;
	static public var ACCEPT:Bool = false;

	static public var uiBinds:Array<String> = [];
	static public var uiBindsAlt:Array<String> = [];

	static public function refreshControls()
	{
		uiBinds = Options.getData('uibinds')[0];
		uiBindsAlt = Options.getData('uibinds')[1];

		UI_LEFT_P = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[2]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[2]), FlxInputState.PRESSED);
		UI_DOWN_P = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[3]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[3]), FlxInputState.PRESSED);
		UI_UP_P = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[4]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[4]), FlxInputState.PRESSED);
		UI_RIGHT_P = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[5]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[5]), FlxInputState.PRESSED);
		BACK_P = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[0]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[0]), FlxInputState.PRESSED);
		ACCEPT_P = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[1]), FlxInputState.PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[1]), FlxInputState.PRESSED);

		UI_LEFT = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[2]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[2]), FlxInputState.JUST_PRESSED);
		UI_DOWN = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[3]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[3]), FlxInputState.JUST_PRESSED);
		UI_UP = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[4]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[4]), FlxInputState.JUST_PRESSED);
		UI_RIGHT = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[5]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[5]), FlxInputState.JUST_PRESSED);
		BACK = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[0]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[0]), FlxInputState.JUST_PRESSED);
		ACCEPT = FlxG.keys.checkStatus(FlxKey.fromString(uiBinds[1]), FlxInputState.JUST_PRESSED) || FlxG.keys.checkStatus(FlxKey.fromString(uiBindsAlt[1]), FlxInputState.JUST_PRESSED);
	}
}