package substates;

import substates.SwagSubState;
import options.Controls;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import states.PlayState;
import game.Song;

class PauseSubstate extends SwagSubState {
	var grpMenuShit:FlxTypedGroup<FlxText>;
	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;
	var lastSong:SwagSong;

	public function new() {
		super();

		lastSong = PlayState.instance.song;
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		var songInfo:FlxText = new FlxText(20, 15, 0, "", 21);
		songInfo.text += "Song: " + lastSong.song;
		songInfo.scrollFactor.set();
		songInfo.setFormat(Paths.font("vcr.ttf"), 21);
		songInfo.updateHitbox();
		add(songInfo);

		grpMenuShit = new FlxTypedGroup<FlxText>();
		add(grpMenuShit);

		for (i in 0...menuItems.length) {
			var swaggerTXT:FlxText = new FlxText(0, 0, FlxG.width, menuItems[i]);
			swaggerTXT.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, "center");
			swaggerTXT.alpha = 0.6;
			grpMenuShit.add(swaggerTXT);
		}

		centerMenuItems();

		cameras = [FlxG.cameras.list[1]];
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER;

		if (upP) {
			changeSelection(-1);
		}
		if (downP) {
			changeSelection(1);
		}

		if (accepted) {
			var daSelected:String = menuItems[curSelected];

			switch (daSelected) {
				case "Resume":
					close();
					#if desktop
					PlayState.instance.video.resume();
					if (PlayState.instance.vocals != null) {
						PlayState.instance.vocals.play();
					}
					#end
				case "Restart Song":
					PlayState.lastMultiplayerState = PlayState.instance.isMultiplayer;
					var newPlayState = new PlayState();
					newPlayState.song = lastSong;
					
					#if desktop
					PlayState.instance.video.stop();
					#end
					
					FlxG.switchState(newPlayState);
				case "Exit to menu":
					transitionState(new states.Freeplay());
					#if desktop
					PlayState.instance.video.stop();
					#end
			}
		}
	}

	override function destroy() {
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void {
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		centerMenuItems();
	}

	function centerMenuItems():Void {
		var totalHeight:Float = 70 * menuItems.length;
		var startY:Float = (FlxG.height - totalHeight) / 2;

		for (i in 0...grpMenuShit.members.length) {
			var item = grpMenuShit.members[i];
			item.y = startY + i * 70;

			item.alpha = (i == curSelected) ? 1 : 0.6;
		}
	}
}
