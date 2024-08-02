import psychlua.CustomSubstate;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import haxe.ds.StringMap;
import flixel.text.FlxText;
import Type;
import flixel.math.FlxMath;
import substates.PauseSubState;
import backend.MusicBeatState;
import options.OptionsState;
import backend.DiscordClient;
import backend.Mods;
import states.StoryMenuState;
import states.FreeplayState;
import flixel.sound.FlxSound;
import backend.Difficulty;
import backend.Controls;

function onPause() {
	CustomSubstate.openCustomSubstate('pauseMenu', true);
	return Function_Stop;
}

var settings = {
	bgColour: 'default',

	music: ClientPrefs.data.pauseMusic, // if you want to edit it you have to put it in a string

	backdropSpeedX: 50,
	backdropSpeedY: 50,
	
	optionTweenTime: 0.1,
	selectTweenTime: 0.25,
	
	openMenuTweenTime: 0.25
};

var colours = [
	'default' => 0xFF000000,
	'pink' => 0xFFFA86C4,
	'crimson' => 0xFF870007,
	'turquoise' => 0xFF30D5C8,
	'red' => 0xFFBB0000,
	'green' => 0xFF00AA00,
	'blue' => 0xFF0000BB,
	'purple' => 0xFF592693,
	'yellow' => 0xFFC8B003,
	'brown' => 0xFF664229,
	'orange' => 0xFFFFA500,

	'custom' => 0xFF000000
];

var bg:FlxSprite;
var bgGrid:FlxBackdrop;
var options:Array<String> = ['Resume', 'Restart', 'Options', 'Exit'];
var curSelect:FlxText;
var songTxt:FlxText;
var deathCount:FlxText;
var diff:FlxText;

var optionObjects = new StringMap();
var curSelected:Int = 0;

var overlappingOption:Bool = false;
var optionCooldown:Float = 0;

var state:String = null;
var fadeOutSpr:FlxSprite;
var pauseMusic:FlxSound;

var ableToChangeSelection:Bool = false;

function convertPauseMenuSong(name:String) {
	name = name.toLowerCase();
	name = StringTools.replace(name, ' ', '-');
	return name;
}

if (PlayState.chartingMode) {
	options.insert(2, 'Leave Charting Mode');
	options.insert(3, 'Toggle Botplay');
}

function onCustomSubstateCreate(t) {
	switch(t) {
		case 'pauseMenu':
			if (settings.music == 'Song Inst') {
				settings.backdropSpeedX = Conductor.bpm / 2;
				settings.backdropSpeedY = Conductor.bpm / 2;
			}

			bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, colours[settings.bgColour.toLowerCase()]);
			CustomSubstate.instance.add(bg);
			bg.camera = game.camOther;
			bg.alpha = 0;
	
			bgGrid = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x11FFFFFF, 0x0));
			bgGrid.alpha = 0;
			bgGrid.velocity.set(175, 175);
			CustomSubstate.instance.add(bgGrid);
			bgGrid.camera = game.camOther;

			for (i in 0...options.length) {
				var option = new FlxText(0, ((i + 1) * 80) + 135, 0, options[i], 40);
				option.font = Paths.font('PhantomMuff.ttf');
				option.borderStyle = Type.resolveEnum('flixel.text.FlxTextBorderStyle').OUTLINE;
				option.borderSize = 2;
				option.alpha = 0;
				CustomSubstate.instance.add(option);
				option.cameras = [game.camOther];
				optionObjects.set('option' + i, option);
			}

			curSelect = new FlxText(((optionObjects.get('option' + curSelected).x + optionObjects.get('option' + curSelected).width) + 10), optionObjects.get('option' + curSelected).y, 0, '<', 40);
			curSelect.font = Paths.font('PhantomMuff.ttf');
			curSelect.borderStyle = Type.resolveEnum('flixel.text.FlxTextBorderStyle').OUTLINE;
			curSelect.borderSize = 2;
			curSelect.alpha = 0;
			CustomSubstate.instance.add(curSelect);
			curSelect.cameras = [game.camOther];

			songTxt = new FlxText(FlxG.width - 520, 15, 500, 'Song: ' + PlayState.SONG.song, 30);
			songTxt.font = Paths.font('PhantomMuff.ttf');
			songTxt.borderStyle = Type.resolveEnum('flixel.text.FlxTextBorderStyle').OUTLINE;
			songTxt.borderSize = 2;
			songTxt.alpha = 0;
			songTxt.alignment = 'right';
			CustomSubstate.instance.add(songTxt);
			songTxt.cameras = [game.camOther];

			diff = new FlxText(songTxt.x + 200, songTxt.y + 40, 300, 'Difficulty: ' + Difficulty.getString(), 30);
			diff.font = Paths.font('PhantomMuff.ttf');
			diff.borderStyle = Type.resolveEnum('flixel.text.FlxTextBorderStyle').OUTLINE;
			diff.borderSize = 2;
			diff.alpha = 0;
			diff.alignment = 'right';
			CustomSubstate.instance.add(diff);
			diff.cameras = [game.camOther];

			deathCount = new FlxText(diff.x, diff.y + 40, 300, 'Blueballed: ' + PlayState.deathCounter, 30);
			deathCount.font = Paths.font('PhantomMuff.ttf');
			deathCount.borderStyle = Type.resolveEnum('flixel.text.FlxTextBorderStyle').OUTLINE;
			deathCount.borderSize = 2;
			deathCount.alpha = 0;
			deathCount.alignment = 'right';
			CustomSubstate.instance.add(deathCount);
			deathCount.cameras = [game.camOther];

			fadeOutSpr = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
			CustomSubstate.instance.add(fadeOutSpr);
			fadeOutSpr.alpha = 0;

			FlxG.mouse.visible = true;

			pauseMusic = new FlxSound();

			if (settings.music != 'Song Inst') pauseMusic.loadEmbedded(Paths.music(convertPauseMenuSong(settings.music)), true);
			else pauseMusic.loadEmbedded(Paths.inst(convertPauseMenuSong(PlayState.SONG.song)), true);

			pauseMusic.volume = 0;
			FlxG.sound.list.add(pauseMusic);
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

			fadeIn();
	}
}

function onCustomSubstateUpdate(t, elapsed) {
	switch(t) {
		case 'pauseMenu':
			if (ableToChangeSelection) {
				if (Controls.instance.UI_UP_P || Controls.instance.UI_DOWN_P) changeSelection(Controls.instance.UI_UP_P ? -1 : 1);

				if (options.length <= 5) {
					for (i in 0...options.length) {
						overlappingOption = mouseOverlaps(optionObjects.get('option' + i));
						if (!overlappingOption && optionCooldown >= 0) optionCooldown -= elapsed;
						if (overlappingOption && optionCooldown <= 0 && curSelected != i) {
							optionCooldown = 0.1;
							curSelected = i;
							changeSelection();
							break;
						}
					}
				} else if (FlxG.mouse.wheel != 0) changeSelection(-FlxG.mouse.wheel);

				if (FlxG.keys.justPressed.ENTER || (mouseOverlaps(optionObjects.get('option' + curSelected)) && FlxG.mouse.justPressed)) {
					switch(optionObjects.get('option' + curSelected).text) {
						case 'Resume': fadeOut();
						case 'Restart':
							state = 'restart';
							fadeOut();
						case 'Options':
							state = 'options';
							fadeOut();
						case 'Exit':
						state = 'exit';
						fadeOut();
						case 'Leave Charting Mode':
							state = 'restart';
							PlayState.chartingMode = false;
							game.paused = true;
							FlxG.sound.music.volume = 0;
							game.vocals.volume = 0;
							fadeOut();
						case 'Toggle Botplay':
							game.cpuControlled = !game.cpuControlled;
							PlayState.changedDifficulty = true;
							game.botplayTxt.visible = game.cpuControlled;
							game.botplayTxt.alpha = 1;
							game.botplaySine = 0;
					}
				}
			}

			if (pauseMusic.volume < 0.5 && ClientPrefs.data.pauseMusic != 'None') pauseMusic.volume += elapsed;
	}
}

function changeSelection(?dir:Int) {
	dir ??= 0; // fix for sscript taking `?` in arguments as a null argument
	
	curSelected = FlxMath.wrap(curSelected + dir, 0, options.length - 1);

	FlxTween.tween(curSelect, {x: (optionObjects.get('option' + curSelected).x + optionObjects.get('option' + curSelected).width) + 10}, settings.optionTweenTime, {ease: FlxEase.quadOut});
	if (options.length <= 5) FlxTween.tween(curSelect, {y: optionObjects.get('option' + curSelected).y}, settings.optionTweenTime, {ease: FlxEase.quadOut});
	else for (i in 0...options.length) FlxTween.tween(optionObjects.get('option' + i), {y: ((i - (curSelected - 1)) * 80) + 135}, settings.optionTweenTime, {ease: FlxEase.quadOut});

	FlxG.sound.play(Paths.sound('scrollMenu'));
}

function fadeIn() {
	FlxTween.tween(bg, {alpha: 0.6}, settings.openMenuTweenTime, {ease: FlxEase.quadOut});
	FlxTween.tween(bgGrid, {alpha: 1}, settings.openMenuTweenTime, {ease: FlxEase.quadOut});
	FlxTween.tween(bgGrid.velocity, {x: settings.backdropSpeedX, y: settings.backdropSpeedY}, settings.openMenuTweenTime + 0.25, {ease: FlxEase.quadOut});
	for (i in 0...options.length) FlxTween.tween(optionObjects.get('option' + i), {alpha: 1, x: 60}, settings.openMenuTweenTime + (i / 20), {ease: FlxEase.quadOut, onComplete: function() {
		ableToChangeSelection = true;
	}});
	FlxTween.tween(curSelect, {alpha: 1, x: (60 + optionObjects.get('option' + curSelected).width) + 10}, settings.openMenuTweenTime, {ease: FlxEase.quadOut});
	FlxTween.tween(songTxt, {alpha: 1}, settings.openMenuTweenTime, {ease: FlxEase.quadOut});
	FlxTween.tween(diff, {alpha: 1}, settings.openMenuTweenTime, {ease: FlxEase.quadOut});
	FlxTween.tween(deathCount, {alpha: 1}, settings.openMenuTweenTime, {ease: FlxEase.quadOut});
}

function fadeOut() {
	if (state != 'options') FlxTween.tween(pauseMusic, {volume: 0}, 0.25, {ease: FlxEase.quadOut});
	FlxG.mouse.visible = false;
	ableToChangeSelection = false;

	if (state == null) {
		FlxTween.tween(bg, {alpha: 0}, 0.25, {ease: FlxEase.quadOut});
		FlxTween.tween(bgGrid.velocity, {x: 175, y: 175}, 0.05, {ease: FlxEase.quadIn});
		for (i in 0...options.length) FlxTween.tween(optionObjects.get('option' + i), {alpha: 0}, 0.25, {ease: FlxEase.quadOut});
		FlxTween.tween(curSelect, {alpha: 0}, 0.25, {ease: FlxEase.quadOut});
		FlxTween.tween(songTxt, {alpha: 0}, 0.25, {ease: FlxEase.quadOut});
		FlxTween.tween(diff, {alpha: 0}, 0.25, {ease: FlxEase.quadOut});
		FlxTween.tween(deathCount, {alpha: 0}, 0.25, {ease: FlxEase.quadOut});
		FlxTween.tween(bgGrid, {alpha: 0}, 0.25, {ease: FlxEase.quadOut, onComplete: function() CustomSubstate.closeCustomSubstate()});
	} else {
		FlxTween.tween(fadeOutSpr, {alpha: 1}, 0.25, {ease: FlxEase.quadOut, onComplete: function() {
			game.camGame.visible = false;
			game.camHUD.visible = false;
			game.camOther.visible = false;

			switch(state) {
				case 'restart':
					game.persistentUpdate = false;
					FlxG.camera.followLerp = 0;
					PauseSubState.restartSong();
				case 'options':
					game.paused = true; // For lua
					game.vocals.volume = 0;
					MusicBeatState.switchState(new OptionsState());
					if(ClientPrefs.data.pauseMusic != 'None') {
						FlxG.sound.playMusic(Paths.music(convertPauseMenuSong(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
						FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
						FlxG.sound.music.time = pauseMusic.time;
					}
					OptionsState.onPlayState = true;
				case 'exit':
					DiscordClient.resetClientID();
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					Mods.loadTopMod();
					if(PlayState.isStoryMode) MusicBeatState.switchState(new StoryMenuState());
					else MusicBeatState.switchState(new FreeplayState());
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
			}
		}});
	}
}

function mouseOverlaps(object, ?offsetX:Float, ?offsetY:Float) {
	offsetX ??= 0;
	offsetY ??= 0;

	var overlapX:Bool = (FlxG.mouse.getScreenPosition(game.camOther).x + offsetX) >= object.x && (FlxG.mouse.getScreenPosition(game.camOther).x + offsetX) <= object.x + object.width;
	var overlapY:Bool = (FlxG.mouse.getScreenPosition(game.camOther).y + offsetY) >= object.y && (FlxG.mouse.getScreenPosition(game.camOther).y + offsetY) <= object.y + object.height;

	return overlapX && overlapY;
}