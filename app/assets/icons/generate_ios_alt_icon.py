import os
import json
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../ios/Runner/Assets.xcassets"))
SRC = os.path.abspath(os.path.join(os.path.dirname(__file__), "Icon-iOS-Dark-1024x1024@1x.png"))
DEST_SET = os.path.join(ROOT, "AppIconDark.appiconset")

SPECS = [
    {"idiom": "iphone", "size": 20, "scale": 2},
    {"idiom": "iphone", "size": 20, "scale": 3},
    {"idiom": "iphone", "size": 29, "scale": 2},
    {"idiom": "iphone", "size": 29, "scale": 3},
    {"idiom": "iphone", "size": 40, "scale": 2},
    {"idiom": "iphone", "size": 40, "scale": 3},
    {"idiom": "iphone", "size": 57, "scale": 1},
    {"idiom": "iphone", "size": 57, "scale": 2},
    {"idiom": "iphone", "size": 60, "scale": 2},
    {"idiom": "iphone", "size": 60, "scale": 3},
    {"idiom": "ipad", "size": 20, "scale": 1},
    {"idiom": "ipad", "size": 20, "scale": 2},
    {"idiom": "ipad", "size": 29, "scale": 1},
    {"idiom": "ipad", "size": 29, "scale": 2},
    {"idiom": "ipad", "size": 40, "scale": 1},
    {"idiom": "ipad", "size": 40, "scale": 2},
    {"idiom": "ipad", "size": 50, "scale": 1},
    {"idiom": "ipad", "size": 50, "scale": 2},
    {"idiom": "ipad", "size": 72, "scale": 1},
    {"idiom": "ipad", "size": 72, "scale": 2},
    {"idiom": "ipad", "size": 76, "scale": 1},
    {"idiom": "ipad", "size": 76, "scale": 2},
    {"idiom": "ipad", "size": 83.5, "scale": 2},
    {"idiom": "ios-marketing", "size": 1024, "scale": 1},
]

def main():
    os.makedirs(DEST_SET, exist_ok=True)
    src = Image.open(SRC).convert("RGBA")
    images_json = []
    for spec in SPECS:
        if spec["idiom"] == "ios-marketing":
            filename = "AppIconDark-1024x1024@1x.png"
            out = src.resize((1024, 1024), Image.LANCZOS)
        else:
            px = int(round(spec["size"] * spec["scale"]))
            filename = f'AppIconDark-{int(spec["size"])}x{int(spec["size"])}@{spec["scale"]}x.png'
            out = src.resize((px, px), Image.LANCZOS)
        out.save(os.path.join(DEST_SET, filename), "PNG")
        entry = {
            "idiom": spec["idiom"],
            "size": f'{spec["size"]}x{spec["size"]}',
            "scale": f'{spec["scale"]}x',
            "filename": filename,
        }
        images_json.append(entry)

    contents = {
        "images": images_json,
        "info": {"author": "trae", "version": 1},
    }
    with open(os.path.join(DEST_SET, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
    print(f"Generated {len(images_json)} dark app icon images in {DEST_SET}")

if __name__ == "__main__":
    main()
