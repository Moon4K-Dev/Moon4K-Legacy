package util.stepmania;

import util.stepmania.SMFile;
import util.stepmania.SMChart;
import util.stepmania.SMUtils;

class SMConverter {
    public static function convertToMoonFormat(smFile:SMFile, chartIndex:Int = 0):Dynamic {
        var smChart = smFile.charts[chartIndex];
        var moonJson = smFile.makeM4KChart(chartIndex);
        
        var songName = smFile.title != null && smFile.title != "" ? smFile.title : "Unnamed";
        
        var convertedChart:Dynamic = {
            song: songName,
            notes: [],
            bpm: moonJson.song.bpm,
            speed: moonJson.song.speed,
            keyCount: 4, // set to 4 cuz no controls for extra keys go brr. ORIGINAL VER: keyCount: smChart.n_keys,
            sections: 0,
            sectionLengths: [],
            timescale: [4, 4]
        };

        for (section in moonJson.song.notes) {
            var convertedSection:Dynamic = {
                sectionNotes: [],
                bpm: section.bpm,
                changeBPM: section.changeBPM
            };

            for (note in section.sectionNotes) {
                convertedSection.sectionNotes.push({
                    noteStrum: note.noteStrum,
                    noteData: note.noteData,
                    noteSus: note.noteSus
                });
            }

            convertedChart.notes.push(convertedSection);
        }

        convertedChart.sections = convertedChart.notes.length;
        convertedChart.sectionLengths = [for (i in 0...convertedChart.sections) 16]; // Assuming each section has 16 beats

        return convertedChart;
    }
}
