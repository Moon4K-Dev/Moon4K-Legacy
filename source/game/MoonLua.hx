package game;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import llua.Convert;
import llua.Lua.Lua_helper;
import llua.Lua;
import llua.LuaL;
import llua.State;
import openfl.Lib;
import sys.io.File;
import game.Conductor;
import states.PlayState;

class MoonLua extends FlxBasic {
	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

	private var game:PlayState;

	var lua:State;

	public function new(file:String, ?execute:Bool = true) {
		super();

		this.game = PlayState.instance;

		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		try {
			var result:Dynamic = LuaL.dofile(lua, file);
			var resultStr:String = Lua.tostring(lua, result);
			if (resultStr != null && result != 0) {
				trace('lua error!!! ' + resultStr);
				Lib.application.window.alert(resultStr, "Error!");
				lua = null;
				return;
			}
		} catch (e) {
			trace(e.message);
			Lib.application.window.alert(e.message, "Error!");
			return;
		}

		trace('Script Loaded Succesfully: $file');

		// PlayState vars
		set("score", game.songScore);
		set("misses", game.misses);
		set("health", game.health);
		set("accuracy", game.accuracy);

		// Song info
		set("curBPM", Conductor.bpm);
		set("crochet", Conductor.crochet);
		set("stepCrochet", Conductor.stepCrochet);
		set("songPos", Conductor.songPosition);
		set("curStep", game.curStep);
		set("curBeat", game.curBeat);

		add_callback("trace", function(text:Dynamic) {
			var traceText = Std.string(text);
			trace('Lua: $traceText');
		});

		add_callback("debugPrint", function(text:Dynamic) {
			var traceText = Std.string(text);
			trace('Lua Debug: $traceText');
		});

		add_callback("setScore", function(score:Int) {
			game.songScore = score;
		});

		add_callback("setHealth", function(health:Float) {
			game.health = health;
		});

		add_callback("getHealth", function():Float {
			return game.health;
		});

		add_callback("setCamZoom", function(zoom:Float) {
			FlxG.camera.zoom = zoom;
		});

		add_callback("getCamZoom", function():Float {
			return FlxG.camera.zoom;
		});

		add_callback("getPropertyFromClass", function(classes:String, value:String) {
			var splitDot:Array<String> = value.split(".");
			var getClassProperty:Dynamic = Type.resolveClass(classes);
			if (splitDot.length > 1) {
				for (i in 1...splitDot.length) {
					getClassProperty = Reflect.getProperty(getClassProperty, splitDot[i - 1]);
				}
				return Reflect.getProperty(getClassProperty, splitDot[splitDot.length - 1]);
			}
			return Reflect.getProperty(getClassProperty, value);
		});
		add_callback("setPropertyFromClass", function(classes:String, variable:String, value:Dynamic) {
			var splitDot:Array<String> = variable.split('.');
			var getClassProperty:Dynamic = Type.resolveClass(classes);
			if (splitDot.length > 1) {
				for (i in 1...splitDot.length - 1) {
					getClassProperty = Reflect.getProperty(getClassProperty, splitDot[i - 1]);
				}
				return Reflect.setProperty(getClassProperty, splitDot[splitDot.length - 1], value);
			}
			return Reflect.setProperty(getClassProperty, variable, value);
		});

		add_callback("makeText", function(tag:String, x:Float = 0, y:Float = 0, fieldWidth:Int = 0, text:String = "", size:Int = 8) {
			if (!PlayState.luaText.exists(tag)) {
				var text = new FlxText(x, y, fieldWidth, text, size);
				text.active = true;
				PlayState.luaText.set(tag, text);
			}
		});
		add_callback("setTextSize", function(tag:String, size:Int = 8) {
			if (PlayState.luaText.exists(tag)) {
				return PlayState.luaText.get(tag).size = size;
			}
			return PlayState.luaText.get(tag).size = size;
		});
		add_callback("setTextFont", function(tag:String, font:String) {
			if (PlayState.luaText.exists(tag)) {
				return PlayState.luaText.get(tag).font = Paths.font(font);
			}
			return null;
		});
		add_callback("setFormat", function(tag:String, font:String, size:Int, color:Int, reAliAsText:String, reBorAsText:String, borColor:Int) {
			if (PlayState.luaText.exists(tag)) {
				var reAli:FlxTextAlign;
				switch (reAliAsText) {
					case "left":
						reAli = LEFT;
					case "center":
						reAli = CENTER;
					case "right":
						reAli = RIGHT;
					default:
						reAli = LEFT;
				}
				var reBor:FlxTextBorderStyle;
				switch (reBorAsText) {
					case "outline":
						reBor = OUTLINE;
					case "outline_fast":
						reBor = OUTLINE_FAST;
					default:
						reBor = OUTLINE;
				}
				PlayState.luaText.get(tag).setFormat(Paths.font(font), size, color, reAli, reBor, borColor);
			}
		});
		add_callback("setTextProperty", function(tag:String, property:String, value:Dynamic) {
			if (PlayState.luaText.exists(tag)) {
				var text = PlayState.luaText.get(tag);
				var propertyParts:Array<String> = property.split(".");
				if (propertyParts.length > 1) {
					var subProperty:String = propertyParts[0];
					var subValue:String = propertyParts[1];
					Reflect.setProperty(Reflect.getProperty(text, subProperty), subValue, value);
				} else {
					Reflect.setProperty(text, property, value);
				}
			}
		});
		add_callback("getTextProperty", function(tag:String, property:String) {
			var splitDot:Array<String> = property.split('.');
			var getText:Dynamic = null;
			if (splitDot.length > 1) {
				if (PlayState.luaText.exists(splitDot[0])) {
					getText = PlayState.luaText.get(splitDot[0]);
				}
				for (i in 1...splitDot.length - 1) {
					getText = Reflect.getProperty(getText, splitDot[i]);
				}
				return Reflect.getProperty(getText, splitDot[splitDot.length - 1]);
			}
			return Reflect.getProperty(getText, splitDot[splitDot.length - 1]);
		});
		add_callback("addText", function(tag:String) {
			if (PlayState.luaText.exists(tag)) {
				return PlayState.instance.add(PlayState.luaText.get(tag));
			}
			return null;
		});

		add_callback("makeSprite", function(tag:String, x:Float, y:Float, ?paths:String = null) {
			if (!PlayState.luaImages.exists(tag)) {
				var sprite = new FlxSprite(x, y);
				sprite.loadGraphic(Paths.image(paths));
				sprite.active = true;
				PlayState.luaImages.set(tag, sprite);
			}
		});
		add_callback("makeAnimationSprite", function(tag:String, x:Float, y:Float, ?paths:String = null) {
			if (!PlayState.luaImages.exists(tag)) {
				var sprite = new FlxSprite(x, y);
				sprite.frames = Paths.getSparrowAtlas(paths);
				PlayState.luaImages.set(tag, sprite);
			}
		});
		add_callback("setSpriteOffset", function(tag:String, x:Float = 0, y:Float = 0) {
			if (PlayState.luaImages.exists(tag)) {
				return PlayState.luaImages.get(tag).offset.set(x, y);
			}
			return null;
		});
		add_callback("addAnimationByPrefix", function(tag:String, name:String, prefix:String, fps:Int = 24, looped:Bool = false) {
			if (PlayState.luaImages.exists(tag)) {
				var sprite = PlayState.luaImages.get(tag);
				return sprite.animation.addByPrefix(name, prefix, fps, looped);
			}
		});
		add_callback("playAnimation", function(tag:String, name:String, force:Bool = false, rev:Bool = false, frames:Int = 0) {
			if (PlayState.luaImages.exists(tag)) {
				return PlayState.luaImages.get(tag).animation.play(name, force, rev, frames);
			}
		});
		add_callback("playAnim", function(tag:String, name:String, force:Bool = false, rev:Bool = false, frames:Int = 0) {
			if (PlayState.luaImages.exists(tag)) {
				return PlayState.luaImages.get(tag).animation.play(name, force, rev, frames);
			}
		});
		add_callback("setSpriteProperty", function(tag:String, property:String, value:Dynamic) {
			if (PlayState.luaImages.exists(tag)) {
				var sprite = PlayState.luaImages.get(tag);
				var propertyParts:Array<String> = property.split(".");
				if (propertyParts.length > 1) {
					var subProperty:String = propertyParts[0];
					var subValue:String = propertyParts[1];
					Reflect.setProperty(Reflect.getProperty(sprite, subProperty), subValue, value);
				} else {
					Reflect.setProperty(sprite, property, value);
				}
			}
		});
		add_callback("getSpriteProperty", function(tag:String, property:String) {
			var splitDot:Array<String> = property.split('.');
			var getSprite:Dynamic = null;
			if (splitDot.length > 1) {
				if (PlayState.luaImages.exists(splitDot[0])) {
					getSprite = PlayState.luaImages.get(splitDot[0]);
				}
				for (i in 1...splitDot.length - 1) {
					getSprite = Reflect.getProperty(getSprite, splitDot[i]);
				}
				return Reflect.getProperty(getSprite, splitDot[splitDot.length - 1]);
			}
			return Reflect.getProperty(getSprite, splitDot[splitDot.length - 1]);
		});
		add_callback("addSprite", function(tag:String) {
			if (PlayState.luaImages.exists(tag)) {
				return PlayState.instance.add(PlayState.luaImages.get(tag));
			}
			return null;
		});

		add_callback("playSound", function(sound:String, loud:Float = 1, looped:Bool = false) {
			return PlayState.instance.playSound(sound, loud, looped);
		});
		add_callback("playMusic", function(music:String, loud:Float = 1, looped:Bool = false) {
			return PlayState.instance.playMusic(music, loud, looped);
		});

		add_callback("stdInt", function(x:Float) {
			return Std.int(x);
		});
	}

	public function set(variable:String, data:Dynamic) {
		if (lua == null)
			return;

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}

	function add_callback(name:String, eventToDo:Dynamic)
		return Lua_helper.add_callback(lua, name, eventToDo);

	public function call(event:String, args:Array<Dynamic>):Dynamic {
		if (lua == null) {
			return Function_Continue;
		}

		Lua.getglobal(lua, event);

		for (arg in args) {
			Convert.toLua(lua, arg);
		}

		var result:Null<Int> = Lua.pcall(lua, args.length, 1, 0);
		if (result != null && resultIsAllowed(lua, result)) {
			if (Lua.type(lua, -1) == Lua.LUA_TSTRING) {
				var error:String = Lua.tostring(lua, -1);
				if (error == 'attempt to call a nil value') {
					return Function_Continue;
				}
			}
			var conv:Dynamic = Convert.fromLua(lua, result);
			return conv;
		}
		return Function_Continue;
	}

	function resultIsAllowed(leLua:State, leResult:Null<Int>) {
		switch (Lua.type(leLua, leResult)) {
			case Lua.LUA_TNIL | Lua.LUA_TBOOLEAN | Lua.LUA_TNUMBER | Lua.LUA_TSTRING | Lua.LUA_TTABLE:
				return true;
		}
		return false;
	}
}
