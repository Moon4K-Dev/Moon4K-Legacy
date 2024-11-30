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

class MoonLua extends FlxBasic
{
	public static var Function_Stop:Dynamic = 1;
	public static var Function_Continue:Dynamic = 0;

    private var game:PlayState;

    var lua:State;

	public function new(file:String, ?execute:Bool = true)
	{
		super();

        this.game = PlayState.instance;

		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		try
		{
			var result:Dynamic = LuaL.dofile(lua, file);
			var resultStr:String = Lua.tostring(lua, result);
			if (resultStr != null && result != 0)
			{
				trace('lua error!!! ' + resultStr);
				Lib.application.window.alert(resultStr, "Error!");
				lua = null;
				return;
			}
		}
		catch (e)
		{
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
	}

    public function set(variable:String, data:Dynamic) {
		if (lua == null)
			return;

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}

	function add_callback(name:String, eventToDo:Dynamic)
		return Lua_helper.add_callback(lua, name, eventToDo);

	public function call(event:String, args:Array<Dynamic>):Dynamic
	{
		if (lua == null)
		{
			return Function_Continue;
		}

		Lua.getglobal(lua, event);

		for (arg in args)
		{
			Convert.toLua(lua, arg);
		}

		var result:Null<Int> = Lua.pcall(lua, args.length, 1, 0);
		if (result != null && resultIsAllowed(lua, result))
		{
			if (Lua.type(lua, -1) == Lua.LUA_TSTRING)
			{
				var error:String = Lua.tostring(lua, -1);
				if (error == 'attempt to call a nil value')
				{
					return Function_Continue;
				}
			}
			var conv:Dynamic = Convert.fromLua(lua, result);
			return conv;
		}
		return Function_Continue;
	}

	function resultIsAllowed(leLua:State, leResult:Null<Int>)
	{
		switch (Lua.type(leLua, leResult))
		{
			case Lua.LUA_TNIL | Lua.LUA_TBOOLEAN | Lua.LUA_TNUMBER | Lua.LUA_TSTRING | Lua.LUA_TTABLE:
				return true;
		}
		return false;
	}
}