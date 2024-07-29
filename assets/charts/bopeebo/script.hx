import Paths;
import flixel.FlxG;
import flixel.FlxSprite;

var sprite:FlxSprite;
function create()
{
    sprite = new FlxSprite().loadGraphic(Paths.image('splash/notelogo'));
    add(sprite);
}