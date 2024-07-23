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

using StringTools;

class OnlineDLState extends SwagState {
    var files:Array<String>;
    var curSelected:Int = 0;
    var selectedFile:String;
    var fileTexts:Array<FlxText>;

    override public function create() {
        FlxG.stage.window.title = "YA4KRG Demo - OnlineDLState";
        Discord.changePresence("Downloading files...", null);

        var coolBackdrop:FlxBackdrop = new FlxBackdrop(Paths.image('mainmenu/menubglol'), 0.2, 0, true, true);
        coolBackdrop.velocity.set(50, 30);
        coolBackdrop.alpha = 0.7;
        add(coolBackdrop);

        fetchDirectoryListing("https://raw.githubusercontent.com/yophlox/YA4kRG-OnlineMaps/main/maps.json");

        super.create();
    }

    override public function update(elapsed:Float) {
        if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN) {
            changeSelection(FlxG.keys.justPressed.UP ? -1 : 1);
        }

        if (FlxG.keys.justPressed.ENTER && selectedFile != null) {
            downloadFile(selectedFile);
        }

        super.update(elapsed);
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
        var yPosition = 50; 

        files = [];
        fileTexts = [];

        for (map in maps) {
            var name = map.name;
            var downloadUrl = map.download;

            files.push(downloadUrl); 

            var fileText = new FlxText(10, yPosition, FlxG.width - 20, name);
            fileText.size = 16;
            fileText.color = FlxColor.WHITE;
            fileText.alignment = "left";
            add(fileText);
            fileTexts.push(fileText);

            yPosition += 20;
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
            fileTexts[i].color = (i == curSelected) ? FlxColor.RED : FlxColor.WHITE;
        }

        selectedFile = files[curSelected];
    }

    function downloadFile(fileUrl:String):Void {
        var http = new Http(fileUrl);
    
        http.onData = function(data:String) {
            trace("Download complete: " + fileUrl);
            saveFile(fileUrl, data);
        };
    
        http.onError = function(error:String) {
            trace("Failed to download file: " + error);
        };
    
        http.onStatus = function(status:Int) {
            trace("HTTP Status: " + status);
        };
    
        http.request(true);
    }    

    function saveFile(fileUrl:String, data:String):Void {
        var fileName = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
        var directoryPath = "assets/downloads/";
    
        if (!FileSystem.exists(directoryPath)) {
            FileSystem.createDirectory(directoryPath);
        }
    
        var filePath = directoryPath + fileName;
        var bytes = Bytes.ofString(data);
    
        try {
            var file = sys.io.File.write(filePath, false);
            file.close(); 
            trace("File saved to: " + filePath);
        } catch (e:Dynamic) {
            trace("Failed to save file: " + filePath + " - " + e);
        }
    }
}
