package util.fnf;

class FNFConverter {
	public static function convertToMoonFormat(fnfData:Dynamic):Dynamic {
		var convertedChart:Dynamic = {
			song: fnfData.song.song,
			notes: [],
			bpm: fnfData.song.bpm,
			speed: fnfData.song.speed != null ? fnfData.song.speed : 1,
			keyCount: 4,
			sections: 0,
			sectionLengths: [],
			timescale: fnfData.song.timescale != null ? fnfData.song.timescale : [4, 4]
		};

		var firstSection:Dynamic = {
			sectionNotes: [],
			changeTimeScale: false,
			timeScale: [4, 4],
			changeBPM: false,
			bpm: fnfData.song.bpm
		};
		convertedChart.notes.push(firstSection);

		var fnfSections:Array<Dynamic> = cast(fnfData.song.notes, Array<Dynamic>);
		for (section in fnfSections) {
			var convertedSection:Dynamic = {
				sectionNotes: [],
				changeTimeScale: section.changeTimeScale != null ? section.changeTimeScale : false,
				timeScale: section.timeScale != null ? section.timeScale : [4, 4],
				changeBPM: section.changeBPM != null ? section.changeBPM : false,
				bpm: section.bpm != null ? section.bpm : fnfData.song.bpm
			};

			var mustHitSection:Bool = section.mustHitSection;
			var sectionNotes:Array<Dynamic> = cast(section.sectionNotes, Array<Dynamic>);

			for (note in sectionNotes) {
				var noteData:Int = cast(note[1], Int);
				var isBFNote:Bool = false;
				if (mustHitSection) {
					isBFNote = (noteData >= 0 && noteData <= 3);
				} else {
					isBFNote = (noteData >= 4 && noteData <= 7);
				}

				if (isBFNote) {
					convertedSection.sectionNotes.push({
						noteStrum: note[0],
						noteData: mustHitSection ? noteData : (noteData - 4),
						noteSus: note[2]
					});
				}
			}

			convertedChart.sectionLengths.push(section.lengthInSteps != null ? section.lengthInSteps : 16);
			convertedChart.notes.push(convertedSection);
		}

		convertedChart.sections = convertedChart.notes.length;
		return convertedChart;
	}
}
