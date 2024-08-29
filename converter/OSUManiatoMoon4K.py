import sys
import os
import json
import re

class OsuToMoonConverter:
    def __init__(self):
        self.osu_data = {}
        self.moon_data = {
            "keyCount": 4,
            "sectionLengths": [],
            "timescale": [4, 4],
            "notes": [],
            "song": "",
            "sections": 0,
            "speed": 1,
            "bpm": 0
        }

    def load_osu_file(self, file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        sections = re.split(r'\[([^\]]+)\]', content)[1:]
        self.osu_data = dict(zip(sections[0::2], sections[1::2]))

    def convert(self):
        self.convert_metadata()
        self.convert_difficulty()
        self.convert_timing_points()
        self.convert_hit_objects()

    def convert_metadata(self):
        metadata = self.parse_section(self.osu_data['Metadata'])
        self.moon_data['song'] = metadata.get('Title', 'Unknown')

    def convert_difficulty(self):
        difficulty = self.parse_section(self.osu_data['Difficulty'])
        self.moon_data['keyCount'] = int(difficulty.get('CircleSize', 4))

    def convert_timing_points(self):
        timing_points = self.parse_timing_points(self.osu_data['TimingPoints'])
        if timing_points:
            self.moon_data['bpm'] = round(60000 / timing_points[0]['beatLength'])

    def convert_hit_objects(self):
        hit_objects = self.parse_hit_objects(self.osu_data['HitObjects'])
        current_section = {
            "sectionNotes": [],
            "changeTimeScale": False,
            "timeScale": [4, 4],
            "changeBPM": False,
            "bpm": self.moon_data['bpm']
        }
        
        for hit_object in hit_objects:
            note = {
                "noteStrum": hit_object['time'],
                "noteData": hit_object['column'],
                "noteSus": hit_object['duration']
            }
            current_section["sectionNotes"].append(note)
            
            if len(current_section["sectionNotes"]) >= 16:
                self.moon_data['notes'].append(current_section)
                self.moon_data['sectionLengths'].append(16)
                current_section = {
                    "sectionNotes": [],
                    "changeTimeScale": False,
                    "timeScale": [4, 4],
                    "changeBPM": False,
                    "bpm": self.moon_data['bpm']
                }
        
        if current_section["sectionNotes"]:
            self.moon_data['notes'].append(current_section)
            self.moon_data['sectionLengths'].append(len(current_section["sectionNotes"]))

        self.moon_data['sections'] = len(self.moon_data['notes'])

    def parse_section(self, section_content):
        return dict(line.split(':', 1) for line in section_content.strip().split('\n') if ':' in line)

    def parse_timing_points(self, timing_points_content):
        timing_points = []
        for line in timing_points_content.strip().split('\n'):
            values = line.split(',')
            if len(values) >= 2:
                timing_points.append({
                    'time': int(values[0]),
                    'beatLength': float(values[1])
                })
        return timing_points

    def parse_hit_objects(self, hit_objects_content):
        hit_objects = []
        key_count = self.moon_data['keyCount']
        column_width = 512 // key_count
        
        for line in hit_objects_content.strip().split('\n'):
            values = line.split(',')
            if len(values) >= 5:
                x = int(values[0])
                time = int(values[2])
                duration = int(values[5].split(':')[0]) - time if len(values) > 5 and ':' in values[5] else 0
                column = min(x // column_width, key_count - 1)
                hit_objects.append({
                    'time': time,
                    'column': column,
                    'duration': duration
                })
        return hit_objects

    def save_moon_file(self, file_path):
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(self.moon_data, f, indent=4)

def main():
    if len(sys.argv) < 2:
        print("Please drag and drop an .osu file onto this script.")
        return

    osu_file_path = sys.argv[1]
    if not os.path.exists(osu_file_path) or not osu_file_path.lower().endswith('.osu'):
        print("Invalid .osu file. Please provide a valid .osu file.")
        return

    converter = OsuToMoonConverter()
    converter.load_osu_file(osu_file_path)
    converter.convert()

    output_file_path = os.path.splitext(osu_file_path)[0] + '.moon'
    converter.save_moon_file(output_file_path)
    print(f"Conversion complete. Moon JSON file saved as: {output_file_path}")

if __name__ == "__main__":
    main()