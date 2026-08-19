import json

with open("maps.json", "r") as file:
    mapsfile = json.load(file)
    mapstrings = []
    for map in mapsfile:
        mapstring = f'''
        {{
            "title": "{map['name']}",
            "content": {{
                "type": "map",
                "maps": [
                    "{map['name']}"
                ]
            }}
        }},'''
        mapstrings.append(mapstring)
    with open("mapstrings.txt", "w") as file2:
        for mapstring in mapstrings:
            file2.write(mapstring)