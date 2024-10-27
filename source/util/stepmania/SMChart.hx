package util.stepmania;

import haxe.ds.Map;
import util.stepmania.SMUtils.SwagSection;
import util.stepmania.SMUtils.SwagNote;
using StringTools;

class SMChart
{
    public var chartType:String;
    public var author:String;
    public var difficulty:String;
    public var numericalMeter:String;
    public var grooveRadarVal:String;

    public var measures:Array<String>;
    public var n_keys:Int;

    public function new(chartstr:String)
    {
        chartstr = SMUtils.cleanChart(chartstr.trim());

        var chartdatasections = chartstr.split(':');
        chartType = _cleanMetadata(chartdatasections[0]);
        author = _cleanMetadata(chartdatasections[1]);
        difficulty = _cleanMetadata(chartdatasections[2]);
        numericalMeter = _cleanMetadata(chartdatasections[3]);
        grooveRadarVal = _cleanMetadata(chartdatasections[4]); // no idea what to do with this `\_(.-.)_/`

        var note_data = chartdatasections[chartdatasections.length-1];
        measures = [ for(x in note_data.split(',')) x.trim() ];
        n_keys = measures[0].trim().split('\n')[0].length;
    }

    public function toM4K(bpmmap:Array<Array<Float>>, offset=0.0, flipChart=false):Array<SwagSection>
    {
        var sections:Array<SwagSection> = [];
        var holdtracker = new Map<Int, SwagNote>();

        var strumtime = 0.0;
        var beatnum = 0.0;
        var curbpm = SMUtils.bpmFromMap(bpmmap, beatnum);
        var change_bpm = false;
        sections.push(SMUtils.makeSwagSection(curbpm, change_bpm, flipChart));

        for(measure in measures)
        {
            var measure_rows = measure.trim().split('\n');

            for(row in measure_rows)
            {
                var latestSection = sections[sections.length - 1];
                latestSection.bpm = curbpm;

                for(columnIndex in 0...row.length)
                {
                    var notevalue = row.charAt(columnIndex);
                    switch (notevalue)
                    {
                        case SMUtils.NOTE_STEP:
                            latestSection.sectionNotes.push({
                                noteStrum: (strumtime - offset) * 1000,
                                noteData: columnIndex,
                                noteSus: 0
                            });
                        case SMUtils.NOTE_HOLD_HEAD, SMUtils.NOTE_ROLL_HEAD:
                            // treating holds and rolls the same
                            var newNote:SwagNote = {
                                noteStrum: (strumtime - offset) * 1000,
                                noteData: columnIndex,
                                noteSus: 0 // We'll update this when we find the tail
                            };
                            latestSection.sectionNotes.push(newNote);
                            holdtracker.set(columnIndex, newNote);
                        case SMUtils.NOTE_TAIL:
                            var holdhead = holdtracker.get(columnIndex);
                            if(holdhead != null)
                            {
                                holdhead.noteSus = (strumtime - offset) * 1000 - holdhead.noteStrum;
                                holdtracker.remove(columnIndex);
                            }
                            else
                            {
                                trace('[ERROR] Encountered tail $notevalue with no head!');
                            }
                    }
                }

                var beatsperrow = SMUtils.getBeatsPerRow(measure);
                beatnum += beatsperrow;
                var nextbpm = SMUtils.bpmFromMap(bpmmap, beatnum);
                if(nextbpm != curbpm)
                {
                    // trace('BPM change from $curbpm to $nextbpm at measure: $measure_num , row: $rownum , beat: $beatnum , strumtime: $strumtime');
                    change_bpm = true;
                    sections.push(SMUtils.makeSwagSection(nextbpm, change_bpm, flipChart));
                }
                else
                {
                    change_bpm = false;
                    // if(latestSection.sectionNotes.length >= 16)
                    // {
                    //     sections.push(SMUtils.makeSwagSection(nextbpm, change_bpm, flipChart));
                    // }
                }

                // [BUG] changing bpms cause the chart to get de-synced (Fixed I think? maybe)
                // strumtime += (60/curbpm) * beatsperrow; // (Looks like it was this line that was causing the bug)
                strumtime = beatnum * 60/curbpm;
                curbpm = nextbpm;
            }
        }

        return sections;
    }

    inline static function _cleanMetadata(str:String)
    {
        var arr = str.trim().split('\n'); // i forgor why i did this but alright
        return arr[arr.length - 1];
    }

    public function toString()
    {
        return '$chartType - $difficulty - $numericalMeter by $author (${n_keys}k chart)';
    }
}
