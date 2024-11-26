package substates;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.geom.Matrix;

class RoomCodeInput extends FlxSubState {
    private var inputText:FlxInputText;
    
    public function new(callback:String->Void) {
        super();
        
        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x88000000);
        add(bg);
        
        var containerWidth = 400;
        var containerHeight = 200;
        var centerX = (FlxG.width - containerWidth) / 2;
        var centerY = (FlxG.height - containerHeight) / 2;
        
        var container = new FlxSprite(centerX, centerY);
        var gradientBitmap = new BitmapData(containerWidth, containerHeight, true, 0xFF2A2A2A);
        var gradient = new Shape();
        var matrix = new Matrix();
        matrix.createGradientBox(containerWidth, containerHeight, Math.PI / 2);
        gradient.graphics.beginGradientFill(LINEAR, 
            [0xFF2A2A2A, 0xFF222222], 
            [1, 1], 
            [0, 255], 
            matrix);
        gradient.graphics.drawRect(0, 0, containerWidth, containerHeight);
        gradientBitmap.draw(gradient);
        container.loadGraphic(gradientBitmap);
        add(container);
        
        var titleText = new FlxText(0, centerY + 20, FlxG.width, "Enter Room Code", 32);
        titleText.alignment = CENTER;
        add(titleText);
        
        var inputWidth = 200;
        inputText = new FlxInputText(
            centerX + (containerWidth - inputWidth) / 2,
            titleText.y + 60,
            inputWidth,
            "",
            24
        );
        inputText.backgroundColor = 0xFF333333;
        inputText.textField.textColor = 0xFFFFFFFF;
        inputText.maxLength = 6;
        add(inputText);
        
        var joinBtn = createStyledButton(
            centerX + (containerWidth - 160) / 2,
            inputText.y + 60,
            "Join",
            function() {
                if (inputText.text.length > 0) {
                    callback(inputText.text);
                    close();
                }
            }
        );
        add(joinBtn);
    }
    
    private function createStyledButton(x:Float, y:Float, label:String, callback:Void->Void):FlxButton {
        var button = new FlxButton(x, y, label, callback);
        
        var width = 160;
        var height = 40;
        var buttonBitmap = new BitmapData(width, height, true, 0xFF3498db);
        
        var buttonShape = new Shape();
        var matrix = new Matrix();
        matrix.createGradientBox(width, height, Math.PI / 2);
        buttonShape.graphics.beginGradientFill(LINEAR,
            [0xFF3498db, 0xFF2980b9],
            [1, 1],
            [0, 255],
            matrix);
        buttonShape.graphics.drawRoundRect(0, 0, width, height, 10, 10);
        buttonBitmap.draw(buttonShape);
        
        button.loadGraphic(buttonBitmap);
        button.label.setFormat(null, 16, 0xFFFFFFFF, CENTER);
        return button;
    }
    
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (FlxG.keys.justPressed.ESCAPE) {
            close();
        }
    }
}