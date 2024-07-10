package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSort;

class StrumNote {
    var playerKeys:Array<Array<FlxKey>>;
    public var strumlineArrows:FlxTypedGroup<FlxSprite>;
    var numStrumNotes:Int;

    public function new(playerKeys:Array<Array<FlxKey>>, numStrumNotes:Int) {
        this.playerKeys = playerKeys;
        this.numStrumNotes = numStrumNotes;
        this.strumlineArrows = new FlxTypedGroup<FlxSprite>();
    }

    public function makeStrumline() {
        var arrowSpacing:Int = 120;
        var arrowWidth:Int = 112;
        var totalWidth:Int = (arrowSpacing * (numStrumNotes - 1)) + arrowWidth;
        var startX:Int = Std.int((FlxG.width - totalWidth) / 2);
        var yPos:Int = 50;

        for (i in 0...numStrumNotes) {
            var babyArrow:FlxSprite = new FlxSprite(startX + (arrowSpacing * i), yPos).makeGraphic(112, 112, 0xFF666666);
            babyArrow.alpha = 0.5;
            strumlineArrows.add(babyArrow);
        }
    }

    public function keyCheck(data:Int) {
        if (data < strumlineArrows.length && FlxG.keys.anyPressed(playerKeys[data])) {
            strumlineArrows.members[data].scale.set(0.95, 0.95);
        } else if (data < strumlineArrows.length) {
            strumlineArrows.members[data].scale.set(1, 1);
        }
    }
}
