package states;

import states.SwagState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;
import haxe.Http;
import sys.io.File;
import sys.FileSystem;
import sys.io.FileOutput;
import sys.io.FileInput;
import haxe.io.Bytes;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;

using StringTools;

class OnlineDLState extends SwagState {
    var files:Array<String>;
    var curSelected:Int = 0;
    var selectedFile:String;
    var fileTexts:Array<FlxText>;
    private var gridLines:FlxTypedGroup<FlxSprite>;
    private var titleText:FlxText;
    private var infoText:FlxText;
    private var downloadProgress:FlxSprite;

    override public function create() {
        FlxG.stage.window.title = "YA4KRG - OnlineDLState";
        Discord.changePresence("Browsing Online Levels", null);

        gridLines = new FlxTypedGroup<FlxSprite>();
        for (i in 0...20) {
            var hLine = new FlxSprite(0, i * 40);
            hLine.makeGraphic(FlxG.width, 1, 0x33FFFFFF);
            gridLines.add(hLine);

            var vLine = new FlxSprite(i * 40, 0);
            vLine.makeGraphic(1, FlxG.height, 0x33FFFFFF);
            gridLines.add(vLine);
        }
        add(gridLines);

        titleText = new FlxText(0, 20, FlxG.width, "ONLINE LEVELS");
        titleText.setFormat(Paths.font('vcr.ttf'), 48, FlxColor.CYAN, CENTER);
        titleText.setBorderStyle(OUTLINE, FlxColor.BLUE, 2);
        add(titleText);

        infoText = new FlxText(10, FlxG.height - 30, FlxG.width - 20, "↑↓: SELECT   ENTER: DOWNLOAD   ESC: BACK");
        infoText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.CYAN, RIGHT);
        infoText.setBorderStyle(OUTLINE, FlxColor.BLUE, 1);
        add(infoText);

        downloadProgress = new FlxSprite(20, FlxG.height - 50).makeGraphic(FlxG.width - 40, 10, FlxColor.BLUE);
        downloadProgress.scale.x = 0;
        add(downloadProgress);

        fetchDirectoryListing("https://raw.githubusercontent.com/yophlox/YA4kRG-OnlineMaps/main/maps.json");

        super.create();
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        for (line in gridLines) {
            line.alpha = 0.2 + 0.1 * Math.sin(line.x + line.y + FlxG.game.ticks * 0.01);
        }

        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN) {
            changeSelection(FlxG.keys.justPressed.UP ? -1 : 1);
        }

        if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE) {
            transitionState(new states.MainMenuState());
        }

        if (FlxG.keys.justPressed.ENTER && selectedFile != null) {
            downloadFile(selectedFile);
        }
    }

    function fetchDirectoryListing(url:String):Void {
        var http = new Http(url);
        http.onData = function(data:String) {
            trace("Data received: " + data);
            parseDirectoryListing(data);
        };
        http.onError = function(error:String) {
            trace("Failed to fetch directory listing: " + error);
        };
        http.request(false);
    }

    function parseDirectoryListing(data:String):Void {
        var maps:Array<Dynamic> = Json.parse(data);
        var yPosition = 100;

        files = [];
        fileTexts = [];

        for (map in maps) {
            var name = map.name;
            var downloadUrl = map.download;

            files.push(downloadUrl); 

            var fileText = new FlxText(50, yPosition, FlxG.width - 100, name);
            fileText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, "left");
            fileText.setBorderStyle(OUTLINE, FlxColor.BLUE, 1);
            add(fileText);
            fileTexts.push(fileText);

            yPosition += 40;
        }

        if (files.length > 0) {
            selectedFile = files[0];
            changeSelection(0);
        }
    }

    function changeSelection(change:Int = 0) {
        curSelected += change;

        if (curSelected < 0) curSelected = 0;
        if (curSelected >= files.length) curSelected = files.length - 1;

        for (i in 0...fileTexts.length) {
            if (i == curSelected) {
                fileTexts[i].color = FlxColor.YELLOW;
                fileTexts[i].scale.set(1.1, 1.1);
                FlxTween.color(fileTexts[i], 0.1, FlxColor.YELLOW, FlxColor.WHITE, {type: PINGPONG});
            } else {
                fileTexts[i].color = FlxColor.WHITE;
                fileTexts[i].scale.set(1, 1);
            }
            fileTexts[i].updateHitbox();
        }

        selectedFile = files[curSelected];
    }

    function downloadFile(fileUrl:String):Void {
        // Simulate download progress
        FlxTween.tween(downloadProgress.scale, {x: 1}, 2, {
            ease: FlxEase.linear,
            onComplete: function(_) {
                showSuccessMessage("File downloaded successfully!");
                downloadProgress.scale.x = 0;
            }
        });

        var http = new Http(fileUrl);
        
        http.setHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3");
        http.setHeader("Accept", "*/*");
        http.setHeader("Accept-Language", "en-US,en;q=0.5");
        http.setHeader("Connection", "keep-alive");

        http.onBytes = function(data:Bytes) {
            trace("Download complete: " + fileUrl);
            saveFile(fileUrl, data);
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

    function saveFile(fileUrl:String, data:Bytes):Void {
        var fileName = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
        var directoryPath = "assets/downloads/";

        if (!FileSystem.exists(directoryPath)) {
            FileSystem.createDirectory(directoryPath);
        }

        var filePath = directoryPath + fileName;

        try {
            File.saveBytes(filePath, data);
            trace("File saved to: " + filePath);
            showSuccessMessage("File downloaded successfully: " + fileName);
        } catch (e:Dynamic) {
            trace("Failed to save file: " + filePath + " - " + e);
            showErrorMessage("Failed to save file: " + fileName);
        }
    }

    function showErrorMessage(message:String):Void {
        var errorText = new FlxText(0, 0, FlxG.width, message);
        errorText.setFormat(null, 16, FlxColor.RED, "center");
        errorText.screenCenter();
        add(errorText);

        FlxTween.tween(errorText, {alpha: 0}, 1, {startDelay: 2, onComplete: function(_) {
            remove(errorText);
            errorText.destroy();
        }});
    }

    function showSuccessMessage(message:String):Void {
        var successText = new FlxText(0, 0, FlxG.width, message);
        successText.setFormat(null, 16, FlxColor.GREEN, "center");
        successText.screenCenter();
        add(successText);

        FlxTween.tween(successText, {alpha: 0}, 1, {startDelay: 2, onComplete: function(_) {
            remove(successText);
            successText.destroy();
        }});
    }
}