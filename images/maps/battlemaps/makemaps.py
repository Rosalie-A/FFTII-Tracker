import os

battlemaps = os.listdir(os.getcwd())
mapstrings = []
for battlemap in battlemaps:
    mapstring = f'''\t{{
        "name": "{battlemap[:-4]}",
        "location_size": 12,
        "location_border_thickness": 2,
        "img": "images/maps/battlemaps/{battlemap}"
    }},\n'''
    mapstrings.append(mapstring)
    
with open("maptext.txt", 'w') as file:
    for mapstring in mapstrings:
        file.write(mapstring)