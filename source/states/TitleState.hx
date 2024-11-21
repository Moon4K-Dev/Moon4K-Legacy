package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import states.OutdatedState;
class TitleState extends SwagState {
	var titlesprite:FlxSprite;
	var titleMusic:Array<String> = ['Lofi Music 1', 'Lofi Music 2', 'Trojan Virus v3 - VS Ron'];
	var songText:FlxText;

	override public function create():Void {
		var selectedMusic = titleMusic[FlxG.random.int(0, titleMusic.length - 1)];
		FlxG.sound.playMusic(Paths.music('title/' + selectedMusic), 1);

		var audio:AudioDisplay = new AudioDisplay(FlxG.sound.music, 0, FlxG.height, FlxG.width, FlxG.height, 200, FlxColor.WHITE);
		add(audio);
		// I LOVE TROJAN VIRUS FNF VS RON GRAHHH!!
		titlesprite = new FlxSprite(0, -50).loadGraphic(Paths.image('sexylogobyhiro'));
		titlesprite.scale.set(0.45, 0.45);
		titlesprite.updateHitbox();
		titlesprite.screenCenter(); // dunno if i wanna do it wit x or without... maybe i'll use y lol
		add(titlesprite);

		songText = new FlxText(10, 10, 0, "Now Playing: " + selectedMusic, 16);
		songText.setFormat(null, 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(songText);

		FlxG.stage.window.title = "Moon4K - TitleState";
		#if desktop
		Discord.changePresence("Listening to music in the TitleState", "Now playing: " + selectedMusic, null);
		#end

		super.create();
	}

	override public function update(elapsed:Float):Void {
		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
			#if SKIP_UPDATES
			transitionState(new MainMenuState());
			#else
			AutoUpdater.checkForUpdates();
			if (AutoUpdater.isNewerVersion(AutoUpdater.latestVersion, AutoUpdater.CURRENT_VERSION) && !OutdatedState.leftState)
			{
				trace('OLD VERSION!');
				transitionState(new OutdatedState());
			}
			else
			{
				transitionState(new MainMenuState());
			}
			#end
		}
		super.update(elapsed);
	}
}
