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
import flixel.ui.FlxButton;
import flixel.FlxSubState;
using StringTools;
import substates.SongInfoSubState;
import openfl.net.URLRequest;
import openfl.display.Loader;
import openfl.events.Event;
import openfl.events.IOErrorEvent;

class OnlineDLState extends SwagState {
    private var files:Array<Dynamic>;
    private var beatmapGrid:FlxTypedGroup<BeatmapItem>;
    private var pageSize:Int = 12;
    private var currentPage:Int = 0;
    private var totalPages:Int = 0;
    private var pageText:FlxText;
    private var gridLines:FlxTypedGroup<FlxSprite>;

    override public function create() {
        FlxG.stage.window.title = "Moon4K - OnlineDLState";
		#if desktop
		Discord.changePresence("Downloading Songs...", null);
		#end
        super.create();

        FlxG.mouse.visible = true;

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

        beatmapGrid = new FlxTypedGroup<BeatmapItem>();
        add(beatmapGrid);

        pageText = new FlxText(0, FlxG.height - 40, FlxG.width, "Page 1 / 1");
        pageText.setFormat(null, 16, FlxColor.WHITE, CENTER);
        add(pageText);

        fetchDirectoryListing("https://raw.githubusercontent.com/yophlox/Moon4K-OnlineMaps/main/maps.json");
    }

    override public function update(elapsed:Float) {
        for (line in gridLines) {
            line.alpha = 0.2 + 0.1 * Math.sin(line.x + line.y + FlxG.game.ticks * 0.01);
        }

        super.update(elapsed);

        if (FlxG.keys.justPressed.LEFT) prevPage();
        if (FlxG.keys.justPressed.RIGHT) nextPage();

        if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
            transitionState(new states.MainMenuState());

        if (FlxG.mouse.justPressed) {
            for (item in beatmapGrid.members) {
                if (item.overlapsPoint(FlxG.mouse.getWorldPosition())) {
                    var mapInfo = files[item.index];
                    openSubState(new SongInfoSubState(
                        mapInfo.name,
                        mapInfo.download,
                        mapInfo.desc,
                        mapInfo.author,
                        mapInfo.image
                    ));
                    break;
                }
            }
        }
    }

    function fetchDirectoryListing(url:String):Void {
        var http = new Http(url);
        http.onData = function(data:String) {
            try {
                parseDirectoryListing(data);
            } catch (e:Dynamic) {
                trace("Error parsing data: " + e);
                showErrorMessage("Failed to load map list. Please try again later.");
            }
        };
        http.onError = function(error:String) {
            trace("Failed to fetch directory listing: " + error);
            showErrorMessage("Failed to fetch map list: " + error);
        };
        http.request(false);
    }

    function parseDirectoryListing(data:String):Void {
        var maps:Array<Dynamic> = Json.parse(data);
        files = maps;
        totalPages = Math.ceil(files.length / pageSize);
        updatePage();
    }

    function updatePage():Void {
        beatmapGrid.clear();

        var startIndex = currentPage * pageSize;
        var endIndex = Std.int(Math.min(startIndex + pageSize, files.length));

        for (i in startIndex...endIndex) {
            var map = files[i];
            var item = new BeatmapItem(
                Std.int((i % 3) * 210 + 20),
                Std.int(Math.floor((i % pageSize) / 3) * 160 + 80),
                map.name,
                map.download,
                map.image,
                i
            );
            beatmapGrid.add(item);
        }

        pageText.text = 'Page ${currentPage + 1} / $totalPages';
    }

    function prevPage():Void {
        if (currentPage > 0) {
            currentPage--;
            updatePage();
        }
    }

    function nextPage():Void {
        if (currentPage < totalPages - 1) {
            currentPage++;
            updatePage();
        }
    }

    function showErrorMessage(message:String):Void {
        var errorText = new FlxText(0, 0, FlxG.width, message);
        errorText.setFormat(null, 16, FlxColor.RED, "center");
        errorText.screenCenter();
        add(errorText);
    }
}

class BeatmapItem extends FlxSprite {
    public var downloadUrl:String;
    public var mapName:String;
    public var index:Int;
    private var nameText:FlxText;
    private var thumbnail:FlxSprite;

    public function new(x:Int, y:Int, mapName:String, downloadUrl:String, imageUrl:String, index:Int) {
        super(x, y);
        this.downloadUrl = downloadUrl;
        this.mapName = mapName;
        this.index = index;

        makeGraphic(200, 150, FlxColor.BLACK);

        thumbnail = new FlxSprite(x, y);
        loadThumbnail(imageUrl);

        nameText = new FlxText(x, y + 110, 200, mapName);
        nameText.setFormat(null, 12, FlxColor.WHITE, CENTER);
    }

    private function loadThumbnail(imageUrl:String):Void {
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onThumbnailLoaded);
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onThumbnailError);
        loader.load(new URLRequest(imageUrl));
    }

    private function onThumbnailLoaded(e:Event):Void {
        var loader:Loader = cast(e.target.loader, Loader);
        var bitmapData = cast(loader.content, openfl.display.Bitmap).bitmapData;
        thumbnail.loadGraphic(bitmapData);
        thumbnail.setGraphicSize(200, 110);
        thumbnail.updateHitbox();
    }

    private function onThumbnailError(e:IOErrorEvent):Void {
        trace('Failed to load thumbnail: ${e.text}');
    }

    override public function draw():Void {
        super.draw();
        thumbnail.draw();
        nameText.draw();
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        thumbnail.update(elapsed);
        nameText.update(elapsed);
    }
}