import os, json

# Mapping JSON keys to your specific file names
file_map = {
    "en": "lang/english_localization.dart",
    "sr": "lang/serbian_localization.dart",
}

def update_localization():
    if not os.path.exists('new_localization.json'):
        print("Error: new_localization.json not found!")
        return

    with open('new_localization.json', 'r', encoding='utf-8') as f:
        new_data = json.load(f)

    for lang, translations in new_data.items():
        file_name = file_map.get(lang)
        if not file_name or not os.path.exists(file_name):
            print(f"Skipping {lang}: File {file_name} not found.")
            continue

        with open(file_name, 'r', encoding='utf-8') as f:
            content = f.read()

        # Find the last closing brace of the Map
        last_brace_index = content.rfind('};')
        
        if last_brace_index == -1:
            print(f"Error: Could not find end of Map in {file_name}")
            continue

        # Build the new strings block
        new_entries = ""
        for key, value in translations.items():
            # Basic check to avoid adding the same key twice
            if f"'{key}':" in content:
                print(f"Warning: Key '{key}' already exists in {file_name}. Skipping.")
                continue
            
            new_entries += f"  '{key}': '{value}',\n"

        if new_entries:
            # Insert before the last };
            updated_content = content[:last_brace_index] + new_entries + content[last_brace_index:]
            
            with open(file_name, 'w', encoding='utf-8') as f:
                f.write(updated_content)
            print(f"Successfully updated {file_name}")
        else:
            print(f"No new unique keys to add for {lang}.")

if __name__ == "__main__":
    update_localization()