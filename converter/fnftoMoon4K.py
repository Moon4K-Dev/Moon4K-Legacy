import json
import sys
import os

def transform_json(input_data):
    output_data = {
        "keyCount": input_data["song"].get("keyCount", 4), # 4 keys only lol
        "sectionLengths": [],
        "timescale": input_data["song"].get("timescale", [4, 4]),
        "notes": [],
        "song": input_data["song"]["song"],
        "sections": input_data["song"].get("sections", 0),
        "speed": input_data["song"].get("speed", 1),
        "bpm": input_data["song"]["bpm"]
    }

    first_section_data = {
        "sectionNotes": [],
        "changeTimeScale": False,
        "timeScale": [4, 4],
        "changeBPM": False,
        "bpm": input_data["song"]["bpm"]
    }

    output_data["notes"].append(first_section_data)

    for section in input_data["song"]["notes"]:
        output_data["sectionLengths"].append(section.get("lengthInSteps", 0))
        
        section_data = {
            "sectionNotes": [],
            "changeTimeScale": section.get("changeTimeScale", False),
            "timeScale": section.get("timeScale", [4, 4]),
            "changeBPM": section.get("changeBPM", False),
            "bpm": section.get("bpm", input_data["song"]["bpm"])
        }
        
        for note in section.get("sectionNotes", []):
            note_data = {
                "noteStrum": note[0],
                "noteData": note[1],
                "noteSus": note[2]
            }
            section_data["sectionNotes"].append(note_data)
        
        output_data["notes"].append(section_data)

    return output_data

def main():
    if len(sys.argv) != 2:
        print("Usage: python fnftoMoon4K.py fnfchart.json")
        return
    
    input_file_path = sys.argv[1]

    if not os.path.exists(input_file_path):
        print(f"File not found: {input_file_path}")
        return

    with open(input_file_path, 'r') as file:
        input_data = json.load(file)

    transformed_data = transform_json(input_data)

    output_file_path = os.path.splitext(input_file_path)[0] + '_converted.json'
    with open(output_file_path, 'w') as file:
        json.dump(transformed_data, file, indent=4)

    print(f"Converted JSON saved to: {output_file_path}")

if __name__ == "__main__":
    main()
