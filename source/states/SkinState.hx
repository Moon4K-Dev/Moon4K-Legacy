package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.system.System;
import options.Controls;
import options.Options;
import ui.StrumNote;
import util.Util;
import flixel.addons.display.FlxBackdrop;

class SkinState extends SwagState
{
	var box:FlxSprite;

	var skinText:FlxText;

	var gridDir:Float = 0;
	var curSelected:Int = 0;

	var laneOffset:Int = 100;

	var keyCount:Int = 4;

	var json:Dynamic;
	var noteskins:Array<String> = Options.getNoteskins();

	var strumNotes:FlxTypedGroup<StrumNote>;

	override public function create()
	{
        FlxG.stage.window.title = "YA4KRG Demo - SkinState";
		Discord.changePresence("Selecting a Note skin...", null);


        var coolBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/menubglol'), 0.2, 0, true, true);
        coolBackdrop.velocity.set(50, 30);
        coolBackdrop.alpha = 0.7;
        add(coolBackdrop);

		super.create();

		curSelected = Options.getData('ui-skin');

		box = new FlxSprite(0, FlxG.height - 150).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		box.alpha = 0.6;
		add(box);

		skinText = new FlxText(100, box.y + 50, 0, "", 32);
		skinText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		skinText.borderSize = 2;
		add(skinText);

		strumNotes = new FlxTypedGroup<StrumNote>();
		add(strumNotes);

		for (i in 0...keyCount)
		{
			var daStrum:StrumNote = new StrumNote(0, 0, i, Options.getNoteskins()[Options.getData('ui-skin')]);

			daStrum.screenCenter();
			daStrum.x += (keyCount * ((laneOffset / 2) * -1)) + (laneOffset / 2);
			daStrum.x += i * laneOffset;

			strumNotes.add(daStrum);
		}

		changeSelection();
		refreshText();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// background speeeeeeeeeen
		gridDir += elapsed * 5;

		if (gridDir > 360)
			gridDir = 0;

		if (Controls.BACK)
		{
			Options.saveData('ui-skin', curSelected);
			transitionState(new OptionSelectState());
		}

		if (Controls.UI_LEFT)
		{
			changeSelection(-1);
		}

		if (Controls.UI_RIGHT)
		{
			changeSelection(1);
		}

		refreshText();
	}

	function refreshText()
	{
		skinText.text = json.name;
		skinText.screenCenter(X);
	}

	function changeSelection(?change:Int = 0)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = noteskins.length - 1;

		if (curSelected > noteskins.length - 1)
			curSelected = 0;

		json = Util.getJson('images/ui-skins/' + noteskins[curSelected] + '/config');

		for (i in 0...strumNotes.members.length)
		{
			var note = strumNotes.members[i];

			note.loadNoteSkin(noteskins[curSelected]);
		}
	}
}