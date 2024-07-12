package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxInput.FlxInputState;
import options.Controls;
import options.Options;
import ui.StrumNote;
import game.Note;

class PlayState extends SwagState
{
	static public var instance:PlayState;

	public var speed:Int = 1;

	var strumNotes:FlxTypedGroup<StrumNote>;

	var keyCount:Int = 4;
	var laneOffset:Int = 100;

	var strumArea:FlxSprite;
	var notes:FlxTypedGroup<Note>;

	static public var strumY:Float = 0;

	override public function new()
	{
		super();
		instance = this;
	}

	override public function create()
	{
		FlxG.camera.bgColor = 0xFF333333;
		super.create();

		speed = Options.getData('scroll-speed');

		laneOffset = Options.getData('lane-offset');

		strumArea = new FlxSprite(0, 50);
		strumArea.visible = false;

		strumArea.y -= 20;

		add(strumArea);

		strumNotes = new FlxTypedGroup<StrumNote>();
		add(strumNotes);

		for (i in 0...keyCount)
		{
			var noteskin:String = Options.getNoteskins()[Options.getData('ui-skin')];
			var daStrum:StrumNote = new StrumNote(0, strumArea.y, i, noteskin);
			daStrum.screenCenter(X);
			daStrum.x += (keyCount * ((laneOffset / 2) * -1)) + (laneOffset / 2);
			daStrum.x += i * laneOffset;

			strumNotes.add(daStrum);
		}
		generateNotes();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Controls.BACK)
			transitionState(new SplashState());

		inputFunction();
	}

	var justPressed:Array<Bool> = [];
	var pressed:Array<Bool> = [];
	var released:Array<Bool> = [];

	function inputFunction()
	{
		var binds:Array<String> = Options.getData('keybinds')[keyCount - 1];

		justPressed = [];
		pressed = [];
		released = [];

		for (i in 0...keyCount)
		{
			justPressed.push(false);
			pressed.push(false);
			released.push(false);
		}

		for (i in 0...binds.length)
		{
			justPressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.JUST_PRESSED);
			pressed[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.PRESSED);
			released[i] = FlxG.keys.checkStatus(FlxKey.fromString(binds[i]), FlxInputState.RELEASED);
		}

		for (i in 0...justPressed.length)
		{
			if (justPressed[i])
			{
				strumNotes.members[i].playAnim("press", true);
			}
		}

		for (i in 0...released.length)
		{
			if (released[i])
			{
				strumNotes.members[i].playAnim("static", true);
			}
		}
	}

	function generateNotes()
	{
		// no swagger yet..
	}
}
