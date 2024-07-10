package game;

import flixel.util.FlxSort;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import game.StrumNote;

class NoteMechanics {
    var strumlineArrows:FlxTypedGroup<FlxSprite>;
    var isRotating:Bool = false;
    var rotationTime:Float = 0;
    var rotationSpeed:Float = 2 * Math.PI / 2;
    var isMovingUpDown:Bool = false;
    var verticalMovementTime:Float = 0;
    var verticalSpeed:Float = 2.5;
    var numStrumNotes:Int;

    public function new(strumlineArrows:FlxTypedGroup<FlxSprite>, numStrumNotes:Int) {
        this.strumlineArrows = strumlineArrows;
        this.numStrumNotes = numStrumNotes;
    }

    public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ONE) {
            isRotating = true;
        }

        if (FlxG.keys.justPressed.TWO) {
            isMovingUpDown = true;
        }

        if (FlxG.keys.justPressed.THREE) {
            isRotating = true;
            isMovingUpDown = true;
        }

        if (FlxG.keys.justPressed.R) {
            resetStrumlinePositions();
            isRotating = false;
            rotationTime = 0;
            isMovingUpDown = false;
            verticalMovementTime = 0;
        }

        if (isRotating) {
            rotationTime += elapsed;
            updateStrumlinePositions(rotationTime);
        }

        if (isMovingUpDown) {
            verticalMovementTime += elapsed;
            updateVerticalMovement(verticalMovementTime);
        }
    }

    public function updateStrumlinePositions(time:Float) {
        var centerX:Float = FlxG.width / 2;
        var centerY:Float = FlxG.height / 2;
        var radius:Float = 100;
        var angleIncrement:Float = 2 * Math.PI / numStrumNotes;

        for (i in 0...numStrumNotes) {
            var angle:Float = time * rotationSpeed + i * angleIncrement;
            var arrow:FlxSprite = strumlineArrows.members[i];
            arrow.x = centerX + radius * Math.cos(angle) - arrow.width / 2;
            arrow.y = centerY + radius * Math.sin(angle) - arrow.height / 2;
        }
    }

    public function updateVerticalMovement(time:Float) {
        var baseY:Float = FlxG.height / 2;
        var amplitude:Float = FlxG.height / 2;

        for (i in 0...numStrumNotes) {
            var arrow:FlxSprite = strumlineArrows.members[i];
            arrow.y = baseY + amplitude * Math.sin(verticalSpeed * time) - arrow.height / 2;
        }
    }

    public function resetStrumlinePositions() {
        var arrowSpacing = 120;
        var arrowWidth = 112;
        var totalWidth = (arrowSpacing * (numStrumNotes - 1)) + arrowWidth;
        var startX = Std.int((FlxG.width - totalWidth) / 2);
        var yPos = 50;

        for (i in 0...numStrumNotes) {
            var arrow:FlxSprite = strumlineArrows.members[i];
            arrow.x = startX + (arrowSpacing * i);
            arrow.y = yPos;
        }
    }
}
