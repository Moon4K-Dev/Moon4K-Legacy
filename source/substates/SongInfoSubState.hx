package substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import openfl.net.URLRequest;
import openfl.Lib;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.display.Bitmap;
import flixel.addons.display.FlxBackdrop;
import haxe.Http;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Bytes;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import haxe.zip.Reader;
import haxe.zip.Entry;
import haxe.zip.Writer;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.zip.Uncompress;

using StringTools;

class SongInfoSubState extends SwagSubState {
	private var thumbnail:FlxSprite;
	private var downloadProgress:FlxSprite;
	private var downloadUrl:String;
	private var songName:String;

	public function new(songName:String, downloadUrl:String, description:String, author:String, imageUrl:String) {
		super();

		this.downloadUrl = downloadUrl;
		this.songName = songName;

		var overlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x88000000);
		add(overlay);

		thumbnail = new FlxSprite(0, 80);
		thumbnail.makeGraphic(500, 300, FlxColor.BLACK);
		thumbnail.screenCenter(X);
		loadThumbnail(imageUrl);
		add(thumbnail);

		var infoText = new FlxText(0, thumbnail.y + thumbnail.height + 20, FlxG.width, 'Song: $songName\nAuthor: $author\n\nDescription: $description');
		infoText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		add(infoText);

		downloadProgress = new FlxSprite(20, FlxG.height - 90).makeGraphic(FlxG.width - 40, 10, FlxColor.BLUE);
		downloadProgress.scale.x = 0;
		add(downloadProgress);

		var instructionText = new FlxText(0, FlxG.height - 80, FlxG.width, "Press Enter to download \nPress ESC to close");
		instructionText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		add(instructionText);
	}

	private function loadThumbnail(imageUrl:String):Void {
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onThumbnailLoaded);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onThumbnailError);
		loader.load(new URLRequest(imageUrl));
	}

	private function onThumbnailLoaded(e:Event):Void {
		var loader:Loader = cast(e.target.loader, Loader);
		var bitmapData = cast(loader.content, Bitmap).bitmapData;
		thumbnail.loadGraphic(bitmapData);
		thumbnail.setGraphicSize(500, 300);
		thumbnail.updateHitbox();
		thumbnail.screenCenter(X);
	}

	private function onThumbnailError(e:IOErrorEvent):Void {
		trace('Failed to load thumbnail: ${e.text}');
	}

	private function downloadFile():Void {
		FlxTween.tween(downloadProgress.scale, {x: 1}, 2, {
			ease: FlxEase.linear,
			onComplete: function(_) {
				showSuccessMessage("File downloaded successfully!");
				downloadProgress.scale.x = 0;
			}
		});

		var http = new Http(downloadUrl);

		http.setHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3");
		http.setHeader("Accept", "*/*");
		http.setHeader("Accept-Language", "en-US,en;q=0.5");
		http.setHeader("Connection", "keep-alive");

		http.onBytes = function(data:Bytes) {
			trace("Download complete: " + downloadUrl);
			saveAndExtractFile(downloadUrl, data);
		};

		http.onError = function(error:String) {
			trace("Failed to download file: " + error);
			showErrorMessage("Download failed: " + error);
		};

		http.onStatus = function(status:Int) {
			trace("HTTP Status: " + status);
			if (status == 403) {
				trace("Access forbidden. Please check if you have permission to access this file.");
				showErrorMessage("Access forbidden (403). Please check if you have permission to access this file.");
			}
		};

		http.cnxTimeout = 10;
		http.request(false);
	}

	private function saveAndExtractFile(fileUrl:String, data:Bytes):Void {
		var fileName = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
		var tempPath = "data/downloads/" + fileName;
		var extractPath = "data/charts/";

		if (!FileSystem.exists("data/downloads/")) {
			FileSystem.createDirectory("data/downloads/");
		}
		if (!FileSystem.exists(extractPath)) {
			FileSystem.createDirectory(extractPath);
		}

		try {
			File.saveBytes(tempPath, data);
			trace("File saved to: " + tempPath);

			var zipFile = File.read(tempPath);
			var entries = Reader.readZip(zipFile);
			for (entry in entries) {
				var fileName = entry.fileName;
				if (fileName.charAt(0) != "." && !fileName.split("/").contains("__MACOSX")) {
					try {
						var data = unzip(entry);
						var path = extractPath + fileName;
						var dir = haxe.io.Path.directory(path);
						if (!FileSystem.exists(dir)) {
							FileSystem.createDirectory(dir);
						}
						if (FileSystem.isDirectory(dir)) {
							File.saveBytes(path, data);
						}
					} catch (e:Dynamic) {
						trace("Failed to extract file " + fileName + ": " + e);
						continue;
					}
				}
			}
			zipFile.close();

			FileSystem.deleteFile(tempPath);

			showSuccessMessage("Chart extracted successfully: " + fileName);
		} catch (e:Dynamic) {
			trace("Failed to save or extract file: " + e);
			showErrorMessage("Failed to save or extract file: " + fileName + "\nError: " + e);
		}
	}

	private function unzip(entry:Entry):Bytes {
		if (!entry.compressed)
			return entry.data;

		try {
			var c = new haxe.zip.Uncompress(-15);
			var s = haxe.io.Bytes.alloc(entry.fileSize);
			var r = c.execute(entry.data, 0, s, 0);
			c.close();
			if (!r.done || r.read != entry.data.length || r.write != entry.fileSize)
				throw "Invalid compressed data for " + entry.fileName;
			return s;
		} catch (e:Dynamic) {
			trace("Uncompression error: " + e);
			throw "Failed to uncompress " + entry.fileName + ": " + e;
		}
	}

	private function showErrorMessage(message:String):Void {
		var errorText = new FlxText(0, 0, FlxG.width, message);
		errorText.setFormat(null, 16, FlxColor.RED, "center");
		errorText.screenCenter();
		add(errorText);

		FlxTween.tween(errorText, {alpha: 0}, 1, {
			startDelay: 2,
			onComplete: function(_) {
				remove(errorText);
				errorText.destroy();
			}
		});
	}

	private function showSuccessMessage(message:String):Void {
		var successText = new FlxText(0, 0, FlxG.width, message);
		successText.setFormat(null, 16, FlxColor.GREEN, "center");
		successText.screenCenter();
		add(successText);

		FlxTween.tween(successText, {alpha: 0}, 1, {
			startDelay: 2,
			onComplete: function(_) {
				remove(successText);
				successText.destroy();
			}
		});
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) {
			close();
		}
		if (FlxG.keys.justPressed.ENTER) {
			downloadFile();
		}
	}
}
