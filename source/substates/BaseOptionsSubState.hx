package substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import options.Controls;
import options.Options;
import states.OptionSelectState;
import states.SkinState;
import util.Util;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;

class BaseOptionsSubState extends SwagSubState {
	var holdTime:Float = 0;

	var curSelected:Int = 0;

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	static public var menuShit:Array<Dynamic> = [["title", "desc", "save", "type"]];

	var menuItems:FlxTypedGroup<OptionBox>;

	override public function create() {
		FlxG.stage.window.title = "YA4KRG Demo - OptionsSubState";

		super.create();

		var coolBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/menubglol'), 0.2, 0, true, true);
		coolBackdrop.velocity.set(50, 30);
		coolBackdrop.alpha = 0.7;
		add(coolBackdrop);

		menuItems = new FlxTypedGroup<OptionBox>();
		add(menuItems);

		for (i in 0...menuShit.length) {
			var option:OptionBox = new OptionBox(0, (100 * i), menuShit[i][0], menuShit[i][1], menuShit[i][2], menuShit[i][3], i);
			menuItems.add(option);
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		changeSelection();
		camFollowPos = new FlxObject(camFollow.x, camFollow.y, 1, 1);
		add(camFollow);
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, null, 1);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		var lerpVal:Float = Util.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (Controls.UI_UP)
			changeSelection(-1);

		if (Controls.UI_DOWN)
			changeSelection(1);

		switch (menuShit[curSelected][3]) {
			case 'bool':
				if (Controls.ACCEPT) {
					var saveName = menuShit[curSelected][2];
					var save = Options.getData(saveName);

					Options.saveData(saveName, !save);
					trace(saveName, !save);
				}
			case 'float' | 'int':
				if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P) {
					holdTime += elapsed;

					if (holdTime > 0.5 || Controls.UI_LEFT || Controls.UI_RIGHT) {
						var saveName = menuShit[curSelected][2];
						var multi:Float = Controls.UI_LEFT_P ? (menuShit[curSelected][5] * -1) : menuShit[curSelected][5];
						var value:Float = Options.getData(saveName);

						if (menuShit[curSelected][3] == 'int')
							multi = Math.floor(multi);

						value += multi;

						if (value < menuShit[curSelected][4][0])
							value = menuShit[curSelected][4][0];

						if (value > menuShit[curSelected][4][1])
							value = menuShit[curSelected][4][1];

						Options.saveData(saveName, value);
						trace(saveName, value);
					}
				} else
					holdTime = 0;
			case 'string':
				if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P) {
					holdTime += elapsed;

					if (holdTime > 0.5 || Controls.UI_LEFT || Controls.UI_RIGHT) {
						var saveName = menuShit[curSelected][2];
						var multi:Int = Controls.UI_LEFT_P ? -1 : 1;
						var value:Float = Options.getData('$saveName-num');

						value += multi;

						if (value < 0)
							value = menuShit[curSelected][4].length - 1;

						if (value > menuShit[curSelected][4].length - 1)
							value = 0;

						Options.saveData('$saveName-num', value);
						Options.saveData(saveName, menuShit[curSelected][4][Math.floor(value)]);
						trace('$saveName-num', value);
					}
				} else
					holdTime = 0;
			case 'menu':
				if (Controls.ACCEPT) {
					switch (menuShit[curSelected][0]) {
						case 'UI Skin':
							transitionState(new SkinState());
					}
				}
		}

		if (Controls.BACK)
			exitMenu();
	}

	function exitMenu() {
		close();
	}

	function changeSelection(?change:Int = 0) {
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.members.length - 1;

		if (curSelected > menuItems.members.length - 1)
			curSelected = 0;

		for (i in 0...menuItems.members.length) {
			var optionBox = menuItems.members[i];
			for (text in optionBox.members) {
				if (Std.is(text, FlxText)) {
					var flxText = cast text;
					flxText.color = (curSelected == i) ? FlxColor.YELLOW : FlxColor.WHITE;
				}
			}
		}

		camFollow.setPosition(menuItems.members[curSelected].members[0].getGraphicMidpoint().x,
			menuItems.members[curSelected].members[0].getGraphicMidpoint().y);
	}
}

class OptionBox extends FlxTypedGroup<FlxText> {
	var titleText:FlxText;
	var descText:FlxText;
	var valueText:FlxText;

	var type:String = "bool";
	var save:String = "?";

	override public function new(x:Float, y:Float, title:String, desc:String, save:String, ?type:String = "bool", ?id:Int) {
		super();

		this.type = type;
		this.save = save;

		this.ID = id;

		var titleX:Float = 0;
		var titleY:Float = 0;

		switch (type) {
			case 'bool':
				titleX = 200;
				titleY = 50;

			case 'string' | 'float' | 'int':
				titleX = 200;
				titleY = 50;

				valueText = new FlxText(x + titleX, y + 150, 0, "", 24);
				valueText.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, LEFT);
				valueText.antialiasing = Options.getData('antialiasing');
				add(valueText);

				refreshValueText();
			default:
				titleX = 200;
				titleY = 50;
		}

		titleText = new FlxText(x + titleX, y + titleY, 0, title, 32);
		titleText.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, LEFT);
		titleText.antialiasing = Options.getData('antialiasing');
		add(titleText);

		descText = new FlxText(titleText.x, titleText.y + 50, 0, desc + "\n", 24);
		descText.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, LEFT);
		descText.antialiasing = Options.getData('antialiasing');
		add(descText);

		if (type == 'string') {
			if (Options.getData('$save-num') == null)
				Options.saveData('$save-num', 0);

			if (Options.getData('$save') == null || !BaseOptionsSubState.menuShit[ID][4].contains(Options.getData('$save'))) {
				Options.saveData('$save', BaseOptionsSubState.menuShit[ID][4][0]);
			}
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		refreshValueText();
	}

	function refreshValueText() {
		if (valueText != null) {
			if (Std.isOfType(Options.getData('$save'), Float))
				valueText.text = 'Value: ' + FlxMath.roundDecimal(Options.getData('$save'), 2) + "\n";
			else
				valueText.text = 'Value: ' + Options.getData('$save') + "\n";
		}
	}
}
