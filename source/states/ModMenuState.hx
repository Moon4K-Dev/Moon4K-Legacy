package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import sys.FileSystem;

class ModMenuState extends FlxState {
    var grpMods:FlxTypedGroup<FlxText>;
    var mods:Array<String>;
    public var curSelected:Int = 0;
    public var selectedMod:String;
    var modHeight:Int = 100;
    public static var activeMods:Array<String> = [];

    public function new() {
        super();
        this.curSelected = 0;
        loadMods();
    }

    override public function create() {
        FlxG.stage.window.title = "YA4KRG Demo - ModMenuState";

        var coolBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('menubglol'), 0.2, 0, true, true);
        coolBackdrop.velocity.set(50, 30);
        coolBackdrop.alpha = 0.7;
        add(coolBackdrop);

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
        textBG.alpha = 0.6;
        add(textBG);

        var leText:String = "Press Enter to toggle the mod // Press ESCAPE to go back.";
        var size:Int = 18;
        var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
        text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
        text.scrollFactor.set();
        add(text);
        super.create();

        grpMods = new FlxTypedGroup<FlxText>();
        add(grpMods);

        if (mods.length == 0) {
            var noModsText:FlxText = new FlxText(0, FlxG.height / 2 - 10, FlxG.width, "No mods found!", 32);
            noModsText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER);
            noModsText.scrollFactor.set();
            add(noModsText);
        } else {
            for (i in 0...mods.length) {
                var modTxt:FlxText = new FlxText(0, 50 + (i * modHeight), FlxG.width, mods[i], 32);
                modTxt.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, CENTER);
                modTxt.scrollFactor.set();
                modTxt.ID = i;
                grpMods.add(modTxt);
            }

            selectedMod = mods[curSelected];
            changeSelection();
        }

        super.create();
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(new SplashState());
        }

        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
            changeSelection(FlxG.keys.justPressed.UP ? -1 : 1);

        if (FlxG.keys.justPressed.ENTER) {
            toggleMod(selectedMod);
        }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;

        if (curSelected < 0) curSelected = 0;
        if (curSelected >= grpMods.length) curSelected = grpMods.length - 1;

        var startY:Int = 50;
        var spacing:Int = 100;
        var visibleCount:Int = 5;
        var offset:Int = Math.floor(visibleCount / 2);

        grpMods.forEach((txt:FlxText) -> {
            var index = txt.ID - (curSelected - offset);
            txt.y = startY + (index * spacing);

            if (txt.ID == curSelected) {
                txt.color = FlxColor.YELLOW;
                txt.size = 36;
                txt.alpha = 1.0;
            } else {
                txt.color = FlxColor.WHITE;
                txt.size = 32;
                txt.alpha = 0.7;
            }
        });

        selectedMod = mods[curSelected];
    }

    function loadMods():Void {
        mods = [];
        var modDir:String = "mods/";
        var directories:Array<String> = FileSystem.readDirectory(modDir);

        for (dir in directories) {
            var fullPath:String = modDir + dir;
            if (FileSystem.isDirectory(fullPath)) {
                mods.push(dir);
            }
        }
    }

    function toggleMod(modName:String):Void {
        trace("Toggled mod: " + modName);
        if (activeMods.indexOf(modName) >= 0) {
            activeMods.remove(modName);
        } else {
            activeMods.push(modName);
        }
    }
}
