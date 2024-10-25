package api.gamejolt;

#if desktop
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.ui.FlxBar;
import flixel.FlxG;
import lime.system.System;
import api.gamejolt.GameJoltAPI;
import api.gamejolt.GJInfo;
import flixel.addons.display.FlxBackdrop;
import states.SwagState;
import flixel.util.FlxAxes;

using StringTools;

class GameJoltLogin extends SwagState {
	var loginTexts:FlxTypedGroup<FlxText>;
	var loginBoxes:FlxTypedGroup<FlxUIInputText>;
	var loginButtons:FlxTypedGroup<FlxButton>;
	var usernameText:FlxText;
	var tokenText:FlxText;
	var usernameBox:FlxUIInputText;
	var tokenBox:FlxUIInputText;
	var signInBox:FlxButton;
	var helpBox:FlxButton;
	var logOutBox:FlxButton;
	var cancelBox:FlxButton;
	var username1:FlxText;
	var username2:FlxText;
	var baseX:Int = -190;
	var versionText:FlxText;
	var funnyText:FlxText;

	var bgred:Int = 50;
	var bggreen:Int = 50;
	var bgblue:Int = 50;

	var bg:FlxSprite;

	public static var login:Bool = false;

	override function create() {
		FlxG.stage.window.title = "YA4KRG - GameJolt Login!";
		#if desktop
		Discord.changePresence("Logging into GameJolt!", null);
		#end
		trace(FlxGameJolt.initialized);
		FlxG.mouse.visible = true;

		var coolBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/menubglol'), XY, 0.2, 0);
		coolBackdrop.velocity.set(50, 30);
		coolBackdrop.alpha = 0.7;
		add(coolBackdrop);

		funnyText = new FlxText(5, FlxG.height - 40, 0, GJInfo.textArray[FlxG.random.int(0, GJInfo.textArray.length - 1)] + " -Phlox", 12);
		add(funnyText);

		versionText = new FlxText(5, FlxG.height - 22, 0, "Game ID: " + GJInfo.id + " API: " + GJInfo.version, 12);
		add(versionText);

		loginTexts = new FlxTypedGroup<FlxText>(2);
		add(loginTexts);

		usernameText = new FlxText(0, 125, 300, "Username:", 20);

		tokenText = new FlxText(0, 225, 300, "Token: (Not PW)", 20);

		loginTexts.add(usernameText);
		loginTexts.add(tokenText);
		loginTexts.forEach(function(item:FlxText) {
			item.screenCenter(X);
			item.x += baseX;
			item.font = GJInfo.font;
		});

		loginBoxes = new FlxTypedGroup<FlxUIInputText>(2);
		add(loginBoxes);

		usernameBox = new FlxUIInputText(0, 175, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);

		tokenBox = new FlxUIInputText(0, 275, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);

		loginBoxes.add(usernameBox);
		loginBoxes.add(tokenBox);
		loginBoxes.forEach(function(item:FlxUIInputText) {
			item.screenCenter(X);
			item.x += baseX;
			item.font = GJInfo.font;
		});

		if (GameJoltAPI.getStatus()) {
			remove(loginTexts);
			remove(loginBoxes);
		}

		loginButtons = new FlxTypedGroup<FlxButton>(3);
		add(loginButtons);

		signInBox = new FlxButton(0, 475, "Sign In", function() {
			trace(usernameBox.text);
			trace(tokenBox.text);
			GameJoltAPI.authDaUser(usernameBox.text, tokenBox.text, true);
			GameJoltAPI.getTrophy(173515);
		});

		helpBox = new FlxButton(0, 550, "GameJolt Token", function() {
			if (!GameJoltAPI.getStatus())
				openLink('https://www.youtube.com/watch?v=T5-x7kAGGnE');
			else {
				GameJoltAPI.leaderboardToggle = !GameJoltAPI.leaderboardToggle;
				trace(GameJoltAPI.leaderboardToggle);
				FlxG.save.data.lbToggle = GameJoltAPI.leaderboardToggle;
				Main.gjToastManager.createToast(GJInfo.imagePath, "Score Submitting",
					"Score submitting is now " + (GameJoltAPI.leaderboardToggle ? "Enabled" : "Disabled"), false);
			}
		});
		helpBox.color = FlxColor.fromRGB(84, 155, 149);

		logOutBox = new FlxButton(0, 625, "Log Out & Close", function() {
			GameJoltAPI.deAuthDaUser();
		});
		logOutBox.color = FlxColor.RED /*FlxColor.fromRGB(255,134,61)*/;

		cancelBox = new FlxButton(0, 625, "Not Right Now", function() {
			FlxG.save.flush();
			FlxG.sound.music.stop();
			transitionState(new states.OptionSelectState());
		});

		if (!GameJoltAPI.getStatus()) {
			loginButtons.add(signInBox);
		}
		loginButtons.add(helpBox);
		loginButtons.add(cancelBox);

		loginButtons.forEach(function(item:FlxButton) {
			item.screenCenter(X);
			item.setGraphicSize(Std.int(item.width) * 3);
			item.x += baseX;
		});

		if (GameJoltAPI.getStatus()) {
			username1 = new FlxText(0, 95, 0, "Signed in as:", 40);
			username1.alignment = CENTER;
			username1.screenCenter(X);
			username1.x += baseX;
			add(username1);

			username2 = new FlxText(0, 145, 0, "" + GameJoltAPI.getUserInfo(true) + "", 40);
			username2.alignment = CENTER;
			username2.screenCenter(X);
			username2.x += baseX;
			add(username2);
		}

		if (GJInfo.font != null) {
			funnyText.font = GJInfo.font;
			versionText.font = GJInfo.font;
			username1.font = GJInfo.font;
			username2.font = GJInfo.font;
			loginBoxes.forEach(function(item:FlxUIInputText) {
				item.font = GJInfo.font;
			});
			loginTexts.forEach(function(item:FlxText) {
				item.font = GJInfo.font;
			});
		}
	}

	override function update(elapsed:Float) {
		var colorDir:Int = 0;

		if (bgred == 255) {
			colorDir = 1;
		} else if (bgred == 0) {
			colorDir = 0;
		}

		if (colorDir == 0) {
			bgred += 2;
			bggreen += 3;
			bgblue += 1;
		} else if (colorDir == 1) {
			bgred -= 2;
			bggreen -= 3;
			bgblue -= 1;
		}

		if (GameJoltAPI.getStatus()) {
			helpBox.text = "Leaderboards:\n" + (GameJoltAPI.leaderboardToggle ? "Enabled" : "Disabled");
			helpBox.color = (GameJoltAPI.leaderboardToggle ? FlxColor.GREEN : FlxColor.RED);
		}

		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.save.flush();
			FlxG.mouse.visible = false;
			transitionState(new states.OptionSelectState());
		}

		super.update(elapsed);
	}

	function openLink(url:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}
}
#end
