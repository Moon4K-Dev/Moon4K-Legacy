package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class SplashState extends FlxState
{
    var arrowsexylogo:FlxSprite;
    var funnyText:FlxText;
    static public var titleStarted:Bool = false;
    var curWacky:String;

    override public function create()
    {
        super.create();

        var introTexts:Array<String> = [
            "Look Ma, I'm in a video game!",
            "Swag Swag Cool Shit",
            "I love ninjamuffin99",
            "FNF chart support coming never"
        ];
        
        curWacky = FlxG.random.getObject(introTexts);
        trace(curWacky);

        if (!titleStarted)
        {
            // splash screen
            arrowsexylogo = new FlxSprite().loadGraphic(Paths.image('splash/notelogo'));
            arrowsexylogo.screenCenter();
            arrowsexylogo.setGraphicSize(Std.int(arrowsexylogo.width * 0.3));
            arrowsexylogo.antialiasing = true;
            arrowsexylogo.alpha = 0;
            add(arrowsexylogo);

            funnyText = new FlxText(0, 0, 0, "Welcome to StrumShit!", 24);
            funnyText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
            funnyText.screenCenter();
            funnyText.alpha = 0;
            add(funnyText);

            FlxTween.tween(arrowsexylogo, {y: arrowsexylogo.y - 35, alpha: 1}, 1, {
                ease: FlxEase.cubeOut,
                startDelay: 0.5
            });

            FlxTween.tween(funnyText, {y: funnyText.y + 35, alpha: 1}, 1, {
                ease: FlxEase.cubeOut,
                startDelay: 0.5,
                onComplete: function(twn:FlxTween)
                {
                    FlxTween.tween(funnyText, {alpha: 0}, 1, {
                        ease: FlxEase.cubeOut,
                        startDelay: 1,
                        onComplete: function(twn:FlxTween)
                        {
                            funnyText.text = curWacky;
                            funnyText.screenCenter(null);
                            FlxTween.tween(funnyText, {alpha: 1}, 1, {
                                ease: FlxEase.cubeOut
                            });
                        }
                    });
                }
            });
        }    
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}
