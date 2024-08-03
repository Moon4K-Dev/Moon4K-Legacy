package hscript;

import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import haxe.io.Path;
import flixel.group.FlxGroup;
import states.PlayState;
import game.Conductor;
import game.Song;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import hscript.Interp;
import hscript.Parser;
import openfl.Assets;
import sys.FileSystem;
import sys.io.File;
import options.Options;
import flixel.system.FlxAssets.FlxShader;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxPoint;
import ui.StrumNote;

using StringTools;

class Hscript
{
	public var interp = new Interp();
	public var parser = new Parser();
	public var script:hscript.Expr;

	public function new()
	{
		parser.allowTypes = true;
		parser.allowJSON = true;
		parser.allowMetadata = true;

		interp.variables.set("Int", Int);
		interp.variables.set("String", String);
		interp.variables.set("Float", Float);
		interp.variables.set("Array", Array);
		interp.variables.set("Bool", Bool);
		interp.variables.set("Dynamic", Dynamic);
		interp.variables.set("Math", Math);
		interp.variables.set("Main", Main);
		interp.variables.set("FlxMath", FlxMath);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxText", FlxText);
		interp.variables.set("FlxGraphic", FlxGraphic);
		interp.variables.set("FlxTween", FlxTween);
		interp.variables.set("FlxCamera", FlxCamera);
		interp.variables.set("FlxShader", FlxShader);
		interp.variables.set("FlxPoint", FlxPoint);
		interp.variables.set("File", File);
		interp.variables.set("Assets", Assets);
		interp.variables.set("FileSystem", FileSystem);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("FlxGroup", FlxGroup);
		interp.variables.set("FlxTypedGroup", FlxTypedGroup);
		interp.variables.set("Paths", Paths);
		interp.variables.set("FlxAtlasFrames", FlxAtlasFrames);
		interp.variables.set("FlxAtlas", FlxAtlas);
		interp.variables.set("Song", Song);
		interp.variables.set("Conductor", Conductor);
        interp.variables.set("Options", Options);
		interp.variables.set("FlxBackdrop", FlxBackdrop);
		interp.variables.set("StrumNote", StrumNote);

		interp.allowStaticVariables = interp.allowPublicVariables = true;

		// regular ol' functions
		interp.variables.set("trace", function(value:Dynamic)
		{
			trace(value);
		});

		/*interp.variables.set("forceAnimPlay", function(val:Character, val2:String, val3:Bool){
			val.animation.play(val2, val3);
		});*/

		interp.variables.set("import", function(class_name:String)
		{
			var classes = class_name.split(".");

			if (Type.resolveClass(class_name) != null)
				interp.variables.set(classes[classes.length - 1], Type.resolveClass(class_name));
			else if (Type.resolveEnum(class_name) != null)
			{
				var enum_new = {};
				var good_enum = Type.resolveEnum(class_name);

				for (constructor in good_enum.getConstructors())
				{
					Reflect.setField(enum_new, constructor, good_enum.createByName(constructor));
				}

				interp.variables.set(classes[classes.length - 1], enum_new);
			}
			else
				trace(class_name + " isn't a valid class or enum!");
		});
	}

	public function call(funcName:String, ?args:Array<Dynamic>):Dynamic
	{
		if (args == null)
			args = [];

		try
		{
			var func:Dynamic = interp.variables.get(funcName);
			if (func != null && Reflect.isFunction(func))
				return Reflect.callMethod(null, func, args);
		}
		catch (e)
		{
			FlxG.log.add(e.details());
		}

		return true;
	}

	/**
	 * Load App Script
	 * @param location Location of the Script (Root starts at 'data', you can't change this.)
	 * @param scriptName name of Script.
	 */
    public function loadScript(scriptContent:String)
    {
        try {
            var script = parser.parseString(scriptContent);
            interp.execute(script);
            trace(scriptContent);
        } catch (e:Dynamic) {
            trace('Hscript Error! ' + e);
        }
    }
}