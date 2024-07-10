package game;

import flixel.FlxG;
import flixel.FlxSprite;
import lime.utils.Assets;
import states.PlayState;
import game.Conductor;

using StringTools;

class Note extends FlxSprite
{
	public var noteskin:String = 'default';
	public var direction:Int = 0;

	public var strum:Float = 0.0;
	public var isSustainNote:Bool = false;
	public var isEndNote:Bool = false;
	public var shouldHit:Bool = true;
	public var sustainLength:Float = 0;

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;

	public var keyCount:Int = 4;

	public static var swagWidth:Float = 160 * 0.7;

	public var scaleX:Float = 0;
	public var scaleY:Float = 0;

	public var lastNote:Note;

	public var origPos:Array<Float> = [0, 0];

	public var json:Dynamic = null;

	public function new(x, y, direction:Int = 0, ?strum:Float, ?noteskin:String = 'default', ?isSustainNote:Bool = false, ?isEndNote:Bool = false,
			?keyCount:Int = 4)
	{
		super(x, y);

		this.noteskin = noteskin;
		this.direction = direction;
		this.strum = strum;
		this.isSustainNote = isSustainNote;
		this.isEndNote = isEndNote;
		this.keyCount = keyCount;

		loadNoteSkin(noteskin);
		setOrigPos();
	}

	public function setOrigPos()
	{
		origPos = [x, y];
	}

	public function loadNoteSkin(?noteskin:String = 'default')
	{
        json = Paths.json('notes/config');
		frames = Paths.getSparrowAtlas('notes');

		if (!isSustainNote)
		{
			switch (keyCount)
			{
				case 1:
					switch (direction % keyCount)
					{
						case 0:
							animation.addByPrefix("note", json.animations[4][3], 24);
					}
			}
		}

		scale.set(json.size, json.size);
		updateHitbox();

		playAnim('note', true);
	}

	public function playAnim(anim:String, ?force:Bool = false)
	{
		animation.play(anim, force);

		centerOffsets();
		centerOrigin();
	}

	override public function update(elapsed:Float)
	{
		scaleX = scale.x;
		scaleY = scale.y;

		super.update(elapsed);
	}

	public function calculateCanBeHit()
	{
		if (this != null)
		{
			if (isSustainNote)
			{
				if (shouldHit)
				{
					if (strum > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
						&& strum < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
						canBeHit = true;
					else
						canBeHit = false;
				}
				else
				{
					if (strum > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
						&& strum < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
						canBeHit = true;
					else
						canBeHit = false;
				}
			}
			else
			{
				if (shouldHit)
				{
					if (strum > Conductor.songPosition - Conductor.safeZoneOffset
						&& strum < Conductor.songPosition + Conductor.safeZoneOffset)
						canBeHit = true;
					else
						canBeHit = false;
				}
				else
				{
					if (strum > Conductor.songPosition - Conductor.safeZoneOffset * 0.3
						&& strum < Conductor.songPosition + Conductor.safeZoneOffset * 0.2)
						canBeHit = true;
					else
						canBeHit = false;
				}
			}

			if (strum < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
	}
}