package profile.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;
import game.Highscore;
import game.HighScoreManager;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.FileListEvent;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.display.Shape;
import openfl.display.BitmapDataChannel;
import openfl.geom.Point;
import openfl.display.PNGEncoderOptions;

class ProfileState extends SwagState {
	private var nameInput:FlxInputText;
	private var profilePicture:FlxSprite;
	private var statsText:FlxText;
	private var saveButton:FlxButton;
	private var changePfpButton:FlxButton;
	private var fileRef:FileReference;

	private var availableImages:Array<String> = ["default"];
	private var currentImageIndex:Int = 0;

	private var cardShadow:FlxSprite;
	private var headerBanner:FlxSprite;
	private var backButton:FlxButton;

	override public function create():Void {
		FlxG.mouse.visible = true;
		FlxG.stage.window.title = "Moon4K - ProfileState";
		#if desktop
		Discord.changePresence("Viewing their profile!", null);
		#end

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF1A1A1A);
		add(bg);

		var containerWidth = 800;
		var containerHeight = 500;
		var centerX = (FlxG.width - containerWidth) / 2;
		var centerY = (FlxG.height - containerHeight) / 2;

		var container = new FlxSprite(centerX, centerY);
		var gradientBitmap = new BitmapData(containerWidth, containerHeight, true, 0xFF2A2A2A);
		var gradient = new Shape();
		var matrix = new Matrix();
		matrix.createGradientBox(containerWidth, containerHeight, Math.PI / 2);
		gradient.graphics.beginGradientFill(LINEAR, [0xFF2A2A2A, 0xFF222222], [1, 1], [0, 255], matrix);
		gradient.graphics.drawRect(0, 0, containerWidth, containerHeight);
		gradientBitmap.draw(gradient);
		container.loadGraphic(gradientBitmap);
		add(container);

		var pfpSize = 150;
		profilePicture = new FlxSprite(centerX + (containerWidth - pfpSize) / 2, centerY - pfpSize / 2);
		var defaultBitmap = new BitmapData(pfpSize, pfpSize, true, 0x00000000);

		var circle = new Shape();
		var gradientMatrix = new Matrix();
		gradientMatrix.createGradientBox(pfpSize, pfpSize, Math.PI / 4);
		circle.graphics.beginGradientFill(LINEAR, [0xFF3498db, 0xFF2980b9], [1, 1], [0, 255], gradientMatrix);
		circle.graphics.drawCircle(pfpSize / 2, pfpSize / 2, pfpSize / 2);
		defaultBitmap.draw(circle);

		profilePicture.loadGraphic(defaultBitmap);
		loadProfilePicture();
		add(profilePicture);

		var borderSize = 4;
		var border = new FlxSprite(profilePicture.x - borderSize, profilePicture.y - borderSize);
		var borderBitmap = new BitmapData(pfpSize + borderSize * 2, pfpSize + borderSize * 2, true, 0x00000000);
		var borderShape = new Shape();
		borderShape.graphics.lineStyle(borderSize, 0xFF3498db, 1);
		borderShape.graphics.drawCircle((pfpSize + borderSize * 2) / 2, (pfpSize + borderSize * 2) / 2, pfpSize / 2 + borderSize / 2);
		borderBitmap.draw(borderShape);
		border.loadGraphic(borderBitmap);
		add(border);
		add(profilePicture);

		var inputWidth = 300;
		nameInput = new FlxInputText(centerX + (containerWidth - inputWidth) / 2, profilePicture.y + pfpSize + 20, inputWidth,
			FlxG.save.data.playerName ?? "Player", 24);
		nameInput.backgroundColor = 0xFF333333;
		nameInput.textField.textColor = 0xFFFFFFFF;
		add(nameInput);

		statsText = new FlxText(centerX + 50, nameInput.y + 80, containerWidth - 100, "", 18);
		statsText.alignment = CENTER;
		statsText.color = 0xFFFFFFFF;
		updateStats();
		add(statsText);

		var buttonY = container.y + containerHeight - 60;

		changePfpButton = createStyledButton(centerX + containerWidth / 2 - 220, buttonY, "Change Picture", onChangePicture);
		add(changePfpButton);

		saveButton = createStyledButton(centerX + containerWidth / 2 - 50, buttonY, "Save Profile", saveProfile);
		add(saveButton);

		backButton = createStyledButton(20, 20, "Back", function() {
			FlxG.switchState(new states.MainMenuState());
		});
		add(backButton);

		super.create();
	}

	private function createStyledButton(x:Float, y:Float, label:String, callback:Void->Void):FlxButton {
		var button = new FlxButton(x, y, label, callback);

		var width = 160;
		var height = 40;
		var buttonBitmap = new BitmapData(width, height, true, 0xFF3498db);

		var buttonShape = new Shape();
		var matrix = new Matrix();
		matrix.createGradientBox(width, height, Math.PI / 2);
		buttonShape.graphics.beginGradientFill(LINEAR, [0xFF3498db, 0xFF2980b9], [1, 1], [0, 255], matrix);
		buttonShape.graphics.drawRoundRect(0, 0, width, height, 10, 10);
		buttonBitmap.draw(buttonShape);

		button.loadGraphic(buttonBitmap);
		button.label.setFormat(null, 16, 0xFFFFFFFF, CENTER);
		return button;
	}

	private function updateStats():Void {
		var totalScore:Int = 0;
		var totalMisses:Int = 0;
		var highScores = HighScoreManager.getHighScores();

		for (score in highScores) {
			totalScore += score.score;
			totalMisses += score.misses;
		}

		statsText.text = 'CAREER STATS\n\n';
		statsText.text += '${formatNumber(totalScore)} Score  •  ${formatNumber(totalMisses)} Misses\n\n';
		statsText.text += 'TOP PERFORMANCES\n';

		for (i in 0...Math.floor(Math.min(3, highScores.length))) {
			var score = highScores[i];
			statsText.text += '${score.song} - ${formatNumber(score.score)}\n';
		}
	}

	private function formatNumber(n:Int):String {
		if (n >= 1000000)
			return Std.string(Math.floor(n / 100000) / 10) + "M";
		if (n >= 1000)
			return Std.string(Math.floor(n / 100) / 10) + "K";
		return Std.string(n);
	}

	private function createCircularImage(sourceBitmap:BitmapData, size:Int):BitmapData {
		var finalBitmap = new BitmapData(size, size, true, 0x00000000);

		var mask = new BitmapData(size, size, true, 0x00000000);
		var maskShape = new Shape();
		maskShape.graphics.beginFill(0xFFFFFF);
		maskShape.graphics.drawCircle(size / 2, size / 2, size / 2);
		maskShape.graphics.endFill();
		mask.draw(maskShape);

		var scaledBitmap = new BitmapData(size, size, true, 0x00000000);

		var scale = Math.max(size / sourceBitmap.width, size / sourceBitmap.height);

		var matrix = new Matrix();
		var scaledWidth = sourceBitmap.width * scale;
		var scaledHeight = sourceBitmap.height * scale;
		var xOffset = (size - scaledWidth) / 2;
		var yOffset = (size - scaledHeight) / 2;

		matrix.scale(scale, scale);
		matrix.translate(xOffset, yOffset);

		scaledBitmap.draw(sourceBitmap, matrix, null, null, null, true);

		finalBitmap.copyPixels(scaledBitmap, scaledBitmap.rect, new Point(0, 0), mask, new Point(0, 0), true);

		return finalBitmap;
	}

	private function loadProfilePicture():Void {
		var size = 150;

		if (FlxG.save.data.profilePictureBytes != null) {
			try {
				var bitmapData = BitmapData.fromBytes(FlxG.save.data.profilePictureBytes);
				if (bitmapData != null) {
					profilePicture.loadGraphic(createCircularImage(bitmapData, size));
				}
			} catch (e) {
				trace('Error loading saved profile picture: ${e}');
				createDefaultProfilePicture(size);
			}
		} else {
			createDefaultProfilePicture(size);
		}
	}

	private function createDefaultProfilePicture(size:Int):Void {
		var defaultBitmap = new BitmapData(size, size, true, 0x00000000);
		var circle = new Shape();
		var gradientMatrix = new Matrix();
		gradientMatrix.createGradientBox(size, size, Math.PI / 4);

		circle.graphics.beginGradientFill(LINEAR, [0xFF3498db, 0xFF2980b9], [1, 1], [0, 255], gradientMatrix);
		circle.graphics.drawCircle(size / 2, size / 2, size / 2);
		circle.graphics.endFill();
		defaultBitmap.draw(circle);

		profilePicture.loadGraphic(createCircularImage(defaultBitmap, size));
	}

	private function onChangePicture():Void {
		fileRef = new FileReference();
		fileRef.addEventListener(Event.SELECT, onFileSelected);
		fileRef.addEventListener(Event.CANCEL, onFileCancel);

		var imageFilter:openfl.net.FileFilter = new openfl.net.FileFilter("PNG Images", "*.png");
		fileRef.browse([imageFilter]);
	}

	private function onFileSelected(e:Event):Void {
		fileRef.addEventListener(Event.COMPLETE, onFileLoaded);
		fileRef.load();
	}

	private function onFileLoaded(e:Event):Void {
		try {
			var bytes = fileRef.data;
			var originalBitmap = BitmapData.fromBytes(bytes);

			if (originalBitmap != null) {
				var size = 150;
				var finalBitmap = createCircularImage(originalBitmap, size);

				profilePicture.loadGraphic(finalBitmap);

				FlxG.save.data.profilePictureBytes = finalBitmap.encode(finalBitmap.rect, new PNGEncoderOptions());
				FlxG.save.flush();
			}
		} catch (e) {
			trace('Error loading image: ${e}');
			createDefaultProfilePicture(150);
		}
	}

	private function onFileCancel(e:Event):Void {}

	private function saveProfile():Void {
		FlxG.save.data.playerName = nameInput.text;
		FlxG.save.data.profilePicture = availableImages[currentImageIndex];
		FlxG.save.flush();
		FlxG.camera.flash();
	}
}
