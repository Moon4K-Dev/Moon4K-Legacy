package util.stepmania;

import haxe.ds.StringMap;
import util.stepmania.SMUtils.SwagSection;


typedef MoonJson = {
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var sections:Int;
	var sectionLengths:Array<Dynamic>;
	var speed:Float;
	var keyCount:Null<Int>;
	var timescale:Array<Int>;
}

typedef SongConfig = {
    ?song:String,
    ?speed:Float,
};

class SMFile
{
    public var extraHeaderTags:StringMap<String>;
    public var bpms:Array<Array<Float>>;
    public var charts:Array<SMChart>;
    public var title:String;
    
    public var chartOffset:Float;

    public function new(filecontent:String)
    {
        bpms = [];
        charts = [];
        extraHeaderTags = new StringMap();
        _parseChart(filecontent);
    }

    function _parseChart(chartstr:String)
    {
        var currHeaderEntry = '';
        var parsingTag = false;
        for(i in 0...chartstr.length)
        {
            var ch = chartstr.charAt(i);
            switch (ch)
            {
                case SMUtils.TAG_START:
                    parsingTag = true;
                case SMUtils.TAG_END:
                    parsingTag = false;
                    var parsedentry = SMUtils.parseEntry(currHeaderEntry);
                    if(!parsedentry.shouldParse)
                    {
                        currHeaderEntry = '';
                        continue;
                    }

                    switch (parsedentry.tag)
                    {
                        case 'BPMS':
                            bpms = SMUtils.parseBPMStr(parsedentry.value);
                        case 'NOTES':
                            charts.push(new SMChart(parsedentry.value));
                        case 'OFFSET':
                            chartOffset = Std.parseFloat(parsedentry.value);
                        case 'TITLE':
                            title = parsedentry.value;
                        default:
                            extraHeaderTags.set(parsedentry.tag, parsedentry.value);
                    }
                    currHeaderEntry = '';
                default:
                    if(parsingTag)
                        currHeaderEntry += ch;
            }
        }
    }

    public static inline function getOrDefault<T>(val:Null<T>, defaultVal:T)
    {
        if(val == null)
            return defaultVal;

        return val;
    }

    public function makeFNFChart(chartIndex=0, song_config:SongConfig=null, flipchart=false)
    {
        if(song_config == null)
            song_config = {};

        var MoonJson:MoonJson = {
            song: getOrDefault(song_config.song, extraHeaderTags.get('TITLE')),
            notes: [],
            bpm: bpms[0][1],
            speed: getOrDefault(song_config.speed, 1.0),
            keyCount: 4,
            sections: 0,
            sectionLengths: [],
            timescale: [4, 4]
        };
        var fnfchart = charts[chartIndex].toFNF(bpms, chartOffset, flipchart);
        MoonJson.notes = MoonJson.notes.concat(fnfchart);
        return { song: MoonJson };
    }
}