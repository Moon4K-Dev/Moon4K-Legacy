package substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
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
		FlxG.stage.window.title = "Moon4K - OptionsSubState";

		super.create();

		var coolBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/menubglol'), XY, 0.2, 0);		coolBackdrop.velocity.set(50, 30);
		coolBackdrop.alpha = 0.7;
		add(coolBackdrop);

		menuItems = new FlxTypedGroup<OptionBox>();
		add(menuItems);

		for (i in 0...menuShit.length) {
			var option:OptionBox = new OptionBox(50, (120 * i) + 100, menuShit[i][0], menuShit[i][1], menuShit[i][2], menuShit[i][3], i);
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

		if (FlxG.keys.justPressed.UP)
			changeSelection(-1);

		if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);

		switch (menuShit[curSelected][3]) {
			case 'bool':
				if (FlxG.keys.justPressed.ENTER) {
					var saveName = menuShit[curSelected][2];
					var save = Options.getData(saveName);

					Options.saveData(saveName, !save);
					trace(saveName, !save);
				}
			case 'float' | 'int':
				if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT) {
					holdTime += elapsed;

					if (holdTime > 0.5 || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT) {
						var saveName = menuShit[curSelected][2];
						var multi:Float = FlxG.keys.justPressed.LEFT ? (menuShit[curSelected][5] * -1) : menuShit[curSelected][5];
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
				if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT) {
					holdTime += elapsed;

					if (holdTime > 0.5 || FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT) {
						var saveName = menuShit[curSelected][2];
						var multi:Int = FlxG.keys.justPressed.LEFT ? -1 : 1;
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
				if (FlxG.keys.justPressed.ENTER) {
					switch (menuShit[curSelected][0]) {
						case 'UI Skin':
							transitionState(new SkinState());
					}
				}
		}

		if (FlxG.keys.justPressed.ESCAPE)
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
					var flxText = cast(text, FlxText);
					if (curSelected == i) {
						flxText.setFormat(Paths.font("vcr.ttf"), flxText.ID == 0 ? 26 : 18, FlxColor.YELLOW, LEFT);
					} else {
						flxText.setFormat(Paths.font("vcr.ttf"), flxText.ID == 0 ? 22 : 15, FlxColor.WHITE, LEFT);
					}
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

		titleText = new FlxText(x, y, 0, title, 22);
		titleText.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, LEFT);
		titleText.antialiasing = Options.getData('antialiasing');
		titleText.ID = 0;
		add(titleText);

		descText = new FlxText(x, y + 30, 0, desc + "\n", 15);
		descText.setFormat(Paths.font("vcr.ttf"), 15, FlxColor.WHITE, LEFT);
		descText.antialiasing = Options.getData('antialiasing');
		descText.ID = 1;
		add(descText);

		if (type != 'bool' && type != 'menu') {
			valueText = new FlxText(x, y + 60, 0, "", 18);
			valueText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT);
			valueText.antialiasing = Options.getData('antialiasing');
			valueText.ID = 2;
			add(valueText);

			refreshValueText();
		}

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
