package states;

import states.SwagState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import options.Options;
import substates.BaseOptionsSubState;
import util.Util;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;

class OptionSelectState extends SwagState {
	var curSelected:Int = 0;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var menuShit:Array<Dynamic> = [["Graphics"], ["Gameplay"], ["UI Skin"], #if web ["Newgrounds Login"],#end #if !web ["GameJolt Login"],#end ["Controls"], ["Exit"]];
	var menuItems:FlxTypedGroup<OptionSelectBox>;

	override public function create() {
		FlxG.stage.window.title = "Moon4K - OptionsState";
		#if desktop
		Discord.changePresence("Changing Options!", null);
		#end

		super.create();

		var coolBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/menubglol'), XY, 0.2, 0);		coolBackdrop.velocity.set(50, 30);
		coolBackdrop.alpha = 0.7;
		add(coolBackdrop);

		menuItems = new FlxTypedGroup<OptionSelectBox>();
		add(menuItems);

		for (i in 0...menuShit.length) {
			var option:OptionSelectBox = new OptionSelectBox(0, (120 * i) + 100, menuShit[i][0], menuShit[i][1], i);
			menuItems.add(option);
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		changeSelection();
		camFollowPos = new FlxObject(camFollow.x, camFollow.y, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, null, 1);
	}

	override public function closeSubState() {
		super.closeSubState();

		persistentDraw = true;
		FlxG.camera.follow(camFollowPos, null, 1);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.camera.follow(camFollowPos, null, 1);

		var lerpVal:Float = Util.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
			transitionState(new MainMenuState());

		if (FlxG.keys.justPressed.UP)
			changeSelection(-1);

		if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);

		if (FlxG.keys.justPressed.ENTER) {
			switch (menuShit[curSelected][0]) {
				case 'Graphics':
					// "title", "desc", "save", "type", []
					BaseOptionsSubState.menuShit = [
						[
							"Anti-Aliasing",
							"Improves performance at the cost of sharper graphics when\ndisabled.",
							"antialiasing",
							"bool"
						]
					];

					persistentDraw = false;
					openSubState(new BaseOptionsSubState());
				case 'Gameplay':
					// "title", "desc", "save", "type", []
					BaseOptionsSubState.menuShit = [
						[
							"Downscroll",
							"Makes all notes scroll downwards instead of upwards.",
							"downscroll",
							"bool"
						],
						["Botplay", "Makes the bot play the game", "botplay", "bool"],
						[
							"Note Offset",
							"Adjust how early/late your notes appear on-screen.",
							"note-offset",
							"float",
							[-1000, 1000],
							0.1
						],
						[
							"Scroll Speed",
							"Adjust the speed at which notes scroll.",
							"scroll-speed",
							"float",
							[0.5, 20.0],
							0.1
						]
					];

					persistentDraw = false;
					openSubState(new BaseOptionsSubState());
				case 'UI Skin':
					transitionState(new SkinState());
				#if newgrounds	
				case 'Newgrounds Login':
					transitionState(new api.newgrounds.NGLogin());	
				#end		
				#if desktop
				case 'GameJolt Login':
					transitionState(new api.gamejolt.GameJoltLogin());
				#end		
				case 'Controls':
					transitionState(new states.ControlsOptionsState());
				case 'Exit':
					transitionState(new MainMenuState());
			}
		}
	}

	function changeSelection(?change:Int = 0) {
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		if (curSelected > menuItems.length - 1)
			curSelected = 0;

		var startY = 100;
		var spacing = 120;

		for (i in 0...menuItems.length) {
			var optionBox = menuItems.members[i];
			for (j in 0...optionBox.length) {
				var txt = optionBox.members[j];
				txt.y = startY + (i * spacing);

				if (i == curSelected) {
					txt.setFormat(Paths.font("vcr.ttf"), txt.ID == 0 ? 40 : 20, FlxColor.YELLOW, CENTER);
					txt.alpha = 1.0;
				} else {
					txt.setFormat(Paths.font("vcr.ttf"), txt.ID == 0 ? 32 : 16, FlxColor.WHITE, CENTER);
					txt.alpha = 0.7;
				}
			}
		}

		camFollow.setPosition(menuItems.members[curSelected].members[0].getGraphicMidpoint().x,
			menuItems.members[curSelected].members[0].getGraphicMidpoint().y);
	}
}

class OptionSelectBox extends FlxTypedGroup<FlxText> {
	public function new(x:Float, y:Float, title:String, desc:String, id:Int) {
		super();

		var titleText:FlxText = new FlxText(x, y, 0, title, 32);
		titleText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		titleText.screenCenter(X);
		titleText.antialiasing = Options.getData('antialiasing');
		titleText.ID = 0; // Set the ID for titleText
		add(titleText);

		var descText:FlxText = new FlxText(x, y + 40, 0, desc, 16);
		descText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		descText.screenCenter(X);
		descText.antialiasing = Options.getData('antialiasing');
		descText.ID = 1; // Set the ID for descText
		add(descText);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}
}
