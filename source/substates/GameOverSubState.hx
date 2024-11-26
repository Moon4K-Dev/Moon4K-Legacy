// totally isn't a modified version of PauseSubstate.hx!!! (trust!!)
// also I literally only thought about making this a substate when I was in the shower last night
// I originally tried to do this as a state but resetting the song was hell (idk when I tried this I fogor lol)
package substates;

import substates.SwagSubState;
import options.Controls;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import states.PlayState;
import game.Song;

class GameOverSubState extends SwagSubState {
	var curSelected:Int = 0;
	var lastSong:SwagSong;

	public function new() {
		super();

		lastSong = PlayState.instance.song;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

        var tempGOText:FlxText = new FlxText(0, 0, 0, "temporary game over text goes hard");
        tempGOText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, "center");
        tempGOText.screenCenter();
        add(tempGOText);

		cameras = [FlxG.cameras.list[1]];
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var accepted = FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ENTER;
		var back = FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE;

		if (accepted && !back && !PlayState.instance.isMultiplayer) {
			var newPlayState = new PlayState();
			newPlayState.song = lastSong;
			#if desktop
			PlayState.instance.video.stop();
			#end
			transitionState(newPlayState);
		}
		else if (accepted && !back && PlayState.instance.isMultiplayer) {
			var newPlayState = new PlayState();
			newPlayState.song = lastSong;
			#if desktop
			PlayState.instance.video.stop();
			#end
			PlayState.instance.isMultiplayer = true;
			transitionState(newPlayState);
		}

		if (back && !accepted) {
			transitionState(new states.Freeplay());
			#if desktop
			PlayState.instance.video.stop();
			#end
		}
	}

	override function destroy() {
		super.destroy();
	}
}
