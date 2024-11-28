package game;

#if desktop
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.StatePointer;
import flixel.FlxG;
import flixel.FlxSprite;
import states.PlayState;

class MoonLua {
    private var lua:State = null;
    private var scriptPath:String;

    public function new(scriptPath:String) {
        lua = LuaL.newstate();
        LuaL.openlibs(lua);
    }
}
#end
