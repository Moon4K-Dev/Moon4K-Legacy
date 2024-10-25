package options;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import lime.app.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

using StringTools;

enum KeyState {
	PRESSED;
	RELEASED;
}

typedef KeyCall = (Int, KeyState) -> Void;
typedef BindCall = (String, Int, KeyState) -> Void;
typedef Key = Null<Int>;

/**
 * the Controls Class manages the main inputs for the game
 * it can be used by every other class for any type of event
**/
class Controls {
	public static var keyPressed:Event<KeyCall> = new Event<KeyCall>();
	public static var keyReleased:Event<KeyCall> = new Event<KeyCall>();
	public static var keyTriggered:Event<KeyCall> = new Event<KeyCall>();

	public static var keyEventPress:Event<BindCall> = new Event<BindCall>();
	public static var keyEventRelease:Event<BindCall> = new Event<BindCall>();
	public static var keyEventTrigger:Event<BindCall> = new Event<BindCall>();

	public static var defaultActions:Map<String, Array<Key>> = [
		"left" => [Keyboard.LEFT, Keyboard.A],
		"down" => [Keyboard.DOWN, Keyboard.S],
		"up" => [Keyboard.UP, Keyboard.W],
		"right" => [Keyboard.RIGHT, Keyboard.D],
		"accept" => [Keyboard.ENTER, Keyboard.SPACE],
		"pause" => [Keyboard.ENTER, Keyboard.P],
		"back" => [Keyboard.ESCAPE, Keyboard.BACKSPACE],
	];

	public static var actionSort:Map<String, Int> = [
		"left" => 0,
		"down" => 1,
		"up" => 2,
		"right" => 3,
		"accept" => 5,
		"pause" => 6,
		"back" => 7,
	];

	public static var actions:Map<String, Array<Key>> = [];

	public static var keysHeld:Array<Key> = [];

	public static function init() {
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		loadControls();
		if (actions.keys().hasNext() == false) {
			actions = defaultActions.copy();
			trace('Debug: Using default actions: ${actions}');
		} else {
			trace('Debug: Loaded custom actions: ${actions}');
		}
	}

	public static function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
	}

	public static function onKeyPress(event:KeyboardEvent) {
		if (FlxG.keys.enabled && (FlxG.state.active || FlxG.state.persistentUpdate)) {
			if (!keysHeld.contains(event.keyCode)) {
				keysHeld.push(event.keyCode);
				keyPressed.dispatch(event.keyCode, PRESSED);
				keyTriggered.dispatch(event.keyCode, PRESSED);

				for (key in catchKeys(event.keyCode)) {
					keyEventPress.dispatch(key, event.keyCode, PRESSED);
					keyEventTrigger.dispatch(key, event.keyCode, PRESSED);
				}
			}
		}
	}

	public static function onKeyRelease(event:KeyboardEvent) {
		if (FlxG.keys.enabled && (FlxG.state.active || FlxG.state.persistentUpdate)) {
			if (keysHeld.contains(event.keyCode)) {
				keysHeld.remove(event.keyCode);
				keyReleased.dispatch(event.keyCode, RELEASED);
				keyTriggered.dispatch(event.keyCode, RELEASED);

				for (key in catchKeys(event.keyCode)) {
					keyEventRelease.dispatch(key, event.keyCode, RELEASED);
					keyEventTrigger.dispatch(key, event.keyCode, RELEASED);
				}
			}
		}
	}

	inline private static function catchKeys(key:Key):Array<String> {
		if (key == null)
			return [];

		var gottenKeys:Array<String> = [];
		for (action => keys in actions) {
			if (keys.contains(key))
				gottenKeys.push(action);
		}

		return gottenKeys;
	}

	inline public static function getKeyState(key:Key):KeyState {
		return keysHeld.contains(key) ? PRESSED : RELEASED;
	}

	public static function getKeyString(action:String, id:Int) {
		var keyString = "None";
		if (actions.exists(action)) {
			var keys = actions.get(action);
			if (id >= 0 && id < keys.length && keys[id] != null) {
				keyString = FlxKey.toStringMap.get(keys[id]);
			}
		}
		trace('Debug: Get key string for ${action} key ${id}: ${keyString}');
		return keyString;
	}

	public static function returnStringKey(arrayThingy:Dynamic):String {
		var keyString:String = 'none';
		if (arrayThingy != null) {
			var keyDisplay:FlxKey = arrayThingy;
			keyString = keyDisplay.toString();
		}

		keyString = keyString.replace(" ", "");

		return keyString;
	}

	public static function getPressEvent(action:String, type:String = 'justPressed'):Bool {
		if (actions.exists(action)) {
			var keys:Array<Key> = actions.get(action);

			switch (type) {
				case 'pressed':
					return FlxG.keys.anyPressed(keys);
				case 'justPressed':
					return FlxG.keys.anyJustPressed(keys);
				case 'justReleased':
					return FlxG.keys.anyJustReleased(keys);
			}
		}
		return false;
	}

	inline public static function addActionKey(action:String, keys:Array<Key>) {
		if (actions.exists(action))
			actions.set(action, keys);
	}

	inline public static function setActionKey(action:String, id:Int, key:Key):Void {
		trace('Debug: Attempting to set ${action} key ${id} to ${key}');
		if (actions.exists(action)) {
			var keys = actions.get(action);
			if (id >= 0 && id < keys.length) {
				keys[id] = key;
				actions.set(action, keys);
				trace('Debug: Successfully set ${action} key ${id} to ${key}');
			} else {
				trace('Debug: Invalid id ${id} for action ${action}');
			}
		} else {
			trace('Debug: Action ${action} does not exist in actions map');
			actions.set(action, [key]);
			trace('Debug: Created new action ${action} with key ${key}');
		}
	}

	public static function saveControls():Void {
		trace('Debug: Current actions before saving: ${actions}');
		var savedControls:Map<String, Array<Int>> = [];
		for (action => keys in actions) {
			savedControls[action] = keys.map(key -> key == null ? -1 : key);
		}
		SaveManager.setControls(savedControls);
		trace('Debug: Saved controls: ${savedControls}');
	}

	public static function loadControls():Void {
		var savedControls = SaveManager.getControls();
		if (savedControls != null && savedControls.keys().hasNext()) {
			actions = new Map<String, Array<Key>>();
			for (action => keys in savedControls) {
				actions[action] = keys.map(key -> key == -1 ? null : key);
			}
			trace('Debug: Loaded controls: ${actions}');
		} else {
			trace('Debug: No saved controls found, using defaults');
			actions = defaultActions.copy();
		}
	}
}
