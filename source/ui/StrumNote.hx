package ui;

import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import lime.utils.Assets;
import options.Options;
import util.Util;

class StrumNote extends FlxSprite {
	public var json:Dynamic;
	public var noteskin:String = "default";
	public var direction:Int = 0;

	public var offsets = [0, 0];

	override public function new(x:Float, y:Float, ?direction:Int = 0, ?noteskin:String = "default", ?keyCount:Int = 4) {
		super(x, y);

		this.direction = direction;
		loadNoteSkin(noteskin, direction);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false, ?reversed:Bool = false, ?frame:Int = 0) {
		if (animation.getByName(anim) != null) {
			animation.play(anim, force, reversed, frame);
			centerOffsets();
			centerOrigin();

			offset.set(offset.x + offsets[0], offset.y + offsets[1]);
		}
	}

	public function loadNoteSkin(?noteskin:String = "default", ?direction:Null<Int>) {
		// ADD MOD SUPPORT TO THIS CHECK
		if (!Assets.exists('data/images/ui-skins/$noteskin/config.json')) {
			Options.saveData('ui-skin', 0);
			noteskin = Options.getNoteskins()[0];
		}

		this.noteskin = noteskin;

		if (direction == null)
			direction = this.direction;

		frames = Util.getSparrow('ui-skins/$noteskin/notes');
		json = Util.getJson('images/ui-skins/$noteskin/config');

		if (json.offsets != null)
			offsets = json.offsets;
		else
			offsets = [0, 0];

		animation.addByPrefix("static", json.animations[direction][0], json.framerate, false);
		animation.addByPrefix("press", json.animations[direction][1], json.framerate, false);
		animation.addByPrefix("confirm", json.animations[direction][2], json.framerate, false);
		animation.addByPrefix("note", json.animations[direction][3], json.framerate, false);

		if (json.antialiasing == true)
			antialiasing = Options.getData('antialiasing');
		else
			antialiasing = false;

		scale.set(json.size, json.size);
		updateHitbox();

		playAnim("static");
	}
}
