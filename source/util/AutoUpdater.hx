/*	  
 * MIT License
 *
 * Copyright (c) 2024 YoPhlox
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package util;

import haxe.Http;
import haxe.io.Bytes;
import sys.FileSystem;
import sys.io.File;
import haxe.zip.Reader;
import lime.app.Application;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import sys.ssl.Socket;
import haxe.io.BytesOutput;

using StringTools;

class AutoUpdater {
	private static inline var VERSION_URL = "https://raw.githubusercontent.com/yophlox/VersionShit/refs/heads/main/Moon4KVer.txt"; // Replace with your repo and txt file
	private static inline var DOWNLOAD_URL =
		#if windows
		"https://github.com/yophlox/Moon4K/releases/latest/download/Moon4K-Win-Release.zip"
		#elseif macos
		"https://github.com/yophlox/Moon4K/releases/latest/download/Moon4K-Mac-Release.zip"
		#elseif linux
		"https://github.com/yophlox/Moon4K/releases/latest/download/Moon4K-Linux-Release.zip"
		#end; // Replace with your repo and zip file
	public static var CURRENT_VERSION = Utils.VERSION;

	public static var latestVersion:String = "";

	public static function checkForUpdates():Void {
		var http = new Http(VERSION_URL);

		http.onData = function(data:String) {
			latestVersion = StringTools.trim(data);
			if (isNewerVersion(latestVersion, CURRENT_VERSION)) {
				showUpdatePrompt(latestVersion);
			}
		}

		http.onError = function(error) {
			trace("Error checking for updates: " + error);
		}

		trace("Checking for updates...");
		trace("Latest version: " + latestVersion);
		trace("Current version: " + CURRENT_VERSION);

		http.request();
	}

	public static function isNewerVersion(latest:String, current:String):Bool {
		var latestParts = latest.split(".");
		var currentParts = current.split(".");

		for (i in 0...3) {
			var latestNum = Std.parseInt(latestParts[i]);
			var currentNum = Std.parseInt(currentParts[i]);

			if (latestNum > currentNum)
				return true;
			if (latestNum < currentNum)
				return false;
		}

		return false;
	}

	private static function showUpdatePrompt(newVersion:String):Void {
		var yesButton:FlxButton;
		var noButton:FlxButton;
		var promptText:FlxText;

		promptText = new FlxText(0, 0, FlxG.width, 'A new version ($newVersion) is available. Do you want to update?');
		promptText.setFormat(null, 16, FlxColor.WHITE, CENTER);
		promptText.screenCenter(Y);
		promptText.y -= 50;

		noButton = new FlxButton(FlxG.width / 2 + 20, promptText.y + 100, "No", function() {
			removePrompt(promptText, yesButton, noButton);
		});

		yesButton = new FlxButton(FlxG.width / 2 - 100, promptText.y + 100, "Yes", function() {
			downloadUpdate();
			removePrompt(promptText, yesButton, noButton);
		});

		FlxG.state.add(promptText);
		FlxG.state.add(yesButton);
		FlxG.state.add(noButton);
	}

	private static function removePrompt(promptText:FlxText, yesButton:FlxButton, noButton:FlxButton):Void {
		FlxG.state.remove(promptText);
		FlxG.state.remove(yesButton);
		FlxG.state.remove(noButton);
	}

	public static function downloadUpdate():Void {
		trace("Attempting to download from: " + DOWNLOAD_URL);
		var data = downloadWithRedirects(DOWNLOAD_URL);
		if (data != null && data.length > 0) {
			handleDownloadedData(data);
		} else {
			trace("Download failed");
			var errorText = new FlxText(0, 0, FlxG.width,
				"Download failed. Please check your internet connection and try again.\n"
				+ "Error details: Unable to connect to update server.\n"
				+ "URL: "
				+ DOWNLOAD_URL);
			errorText.alignment = CENTER;
			errorText.screenCenter();
			FlxG.state.add(errorText);
		}
	}

	private static function downloadWithRedirects(url:String, redirectCount:Int = 0):Bytes {
		if (redirectCount > 5) {
			trace("Too many redirects");
			return null;
		}

		try {
			var http = new Http(url);
			var output = new BytesOutput();
			var result:Bytes = null;

			http.onStatus = function(status:Int) {
				trace("HTTP Status: " + status);
				if (status >= 300 && status < 400) {
					var newUrl = http.responseHeaders.get("Location");
					if (newUrl != null) {
						trace("Redirecting to: " + newUrl);
						result = downloadWithRedirects(newUrl, redirectCount + 1);
					}
				}
			}

			http.onError = function(error:String) {
				trace("HTTP Error: " + error);
			}

			http.customRequest(false, output);

			if (result == null) {
				result = output.getBytes();
			}

			return result;
		} catch (e:Dynamic) {
			trace("Error downloading update: " + e);
			return null;
		}
	}

	private static function handleDownloadedData(data:Bytes):Void {
		try {
			if (data == null || data.length == 0) {
				throw "Downloaded data is empty";
			}
			var tempPath = "temp_update.zip";
			trace("Downloading update, size: " + data.length + " bytes");
			File.saveBytes(tempPath, data);
			trace("Update downloaded successfully");

			if (!FileSystem.exists(tempPath) || FileSystem.stat(tempPath).size == 0) {
				throw "Downloaded file is empty or doesn't exist";
			}

			extractUpdate(tempPath);
		} catch (e:Dynamic) {
			trace("Error saving update: " + e);
			FlxG.state.add(new FlxText(0, 0, FlxG.width, "Update save failed: " + e));
		}
	}

	private static function extractUpdate(zipPath:String):Void {
		try {
			var zipFile = File.read(zipPath, true);
			var entries = Reader.readZip(zipFile);
			zipFile.close();

			trace("Zip file opened, entries count: " + entries.length);

			for (entry in entries) {
				var fileName = entry.fileName;
				trace("Extracting: " + fileName);

				if (fileName == "lime.ndll" || fileName == "Moon4K.exe" || fileName == "libvlc.dll") { // replace with your executable's name.
					var content = Reader.unzip(entry);
					File.saveBytes(fileName + ".new", content);
					trace("Saved new version of: " + fileName);
				} else {
					var content = Reader.unzip(entry);
					var path = haxe.io.Path.directory(fileName);
					if (path != "" && !FileSystem.exists(path)) {
						FileSystem.createDirectory(path);
					}
					File.saveBytes(fileName, content);
					trace("Extracted: " + fileName);
				}
			}

			FileSystem.deleteFile(zipPath);
			trace("Temporary zip file deleted");
			finishUpdate();
		} catch (e:Dynamic) {
			trace("Error during extraction: " + e);
			FlxG.state.add(new FlxText(0, 0, FlxG.width, "Extraction failed: " + e));
		}
	}

	private static function finishUpdate():Void {
		var batchContent = '@echo off\n'
			+ 'timeout /t 1 /nobreak > NUL\n'
			+ 'move /y Moon4K.exe.new Moon4K.exe\n'
			+ // replace with your executable's name.
			'move /y lime.ndll.new lime.ndll\n'
			+ 'move /y libvlc.dll.new libvlc.dll\n'
			+ 'start "" Moon4K.exe\n'
			+ // replace with your executable's name.
			'del "%~f0"';

		File.saveContent("finish_update.bat", batchContent);

		Sys.command("start finish_update.bat");
		Application.current.window.close();
	}
}
