package game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;

class StrumNote {
    var playerKeys:Array<Array<FlxKey>>;
    public var strumlineArrows:FlxTypedGroup<FlxSprite>;
    public var numStrumNotes:Int; 
    var noteFrames:FlxAtlasFrames;

    public function new(playerKeys:Array<Array<FlxKey>>, numStrumNotes:Int, noteFrames:FlxAtlasFrames) {
        this.playerKeys = playerKeys;
        this.numStrumNotes = numStrumNotes;
        this.noteFrames = noteFrames;
        this.strumlineArrows = new FlxTypedGroup<FlxSprite>();
    }

    public function makeStrumline() {
        var arrowSpacing = 120;
        var arrowWidth = 112;
        var totalWidth = (arrowSpacing * (numStrumNotes - 1)) + arrowWidth;
        var startX = Std.int((FlxG.width - totalWidth) / 2);
        var yPos = 50;

        for (i in 0...numStrumNotes) {
            var babyArrow = new FlxSprite(startX + (arrowSpacing * i), yPos);
            babyArrow.frames = noteFrames;
            babyArrow.animation.addByPrefix("note", getFrameName(i), 0, false);
            babyArrow.animation.addByPrefix("pressed", getPressedFrameName(i), 24, false);
            babyArrow.animation.play("note");
            strumlineArrows.add(babyArrow);
        }
    }

    public function keyCheck(data:Int) {
        if (data < strumlineArrows.length && FlxG.keys.anyPressed(playerKeys[data])) {
            strumlineArrows.members[data].animation.play("pressed");
        } else if (data < strumlineArrows.length) {
            strumlineArrows.members[data].animation.play("note");
        }
    }

    private function getFrameName(index:Int):String {
        switch(index) {
            case 0: return "left note0000";
            case 1: return "down note0000";
            case 2: return "up note0000";
            case 3: return "right note0000";
            case 4: return "middle note000";
            default: return "left note0000";
        }
    }

    private function getPressedFrameName(index:Int):String {
        switch(index) {
            case 0: return "left press0000";
            case 1: return "down press0000";
            case 2: return "up press0000";
            case 3: return "right press0000";
            case 4: return "middle pressed0000";
            default: return "left press0000";
        }
    }
}
