import os
import sys
from PIL import Image, ImageDraw, ImageFilter

src_path = "/Users/worracag/.gemini/antigravity-ide/brain/7ec4fc85-244d-49e8-9262-d7a4b0bdfa2c/launchpad_clean_icon_1793159893784.jpg"
out_dir = "/Users/worracag/Desktop/ProJect/Launchpad/Resources"
os.makedirs(out_dir, exist_ok=True)

img = Image.open(src_path).convert("RGBA")
w, h = img.size

# The image has a rounded squircle in the center with white outside.
# Let's crop tight to the icon boundary or create a clean squircle mask.
# Let's inspect the bounding box of non-white pixels:
# A pixel is considered border/background if r>240, g>240, b>240
gray = img.convert("L")
# Find bounding box
bbox = None
for y in range(h):
    for x in range(w):
        r, g, b, a = img.getpixel((x, y))
        if r < 240 or g < 240 or b < 240:
            if bbox is None:
                bbox = [x, y, x, y]
            else:
                bbox[0] = min(bbox[0], x)
                bbox[1] = min(bbox[1], y)
                bbox[2] = max(bbox[2], x)
                bbox[3] = max(bbox[3], y)

print(f"Detected bounding box: {bbox}")

# Crop to bbox with a tiny margin
if bbox:
    cropped = img.crop((bbox[0], bbox[1], bbox[2], bbox[3]))
else:
    cropped = img

# Resize to standard 1024x1024
icon_1024 = cropped.resize((1024, 1024), Image.Resampling.LANCZOS)

# Create a smooth Apple Squircle mask
mask = Image.new("L", (1024, 1024), 0)
draw = ImageDraw.Draw(mask)
# Apple squircle radius is roughly 224px for 1024px size (22.37%)
corner_radius = 224
draw.rounded_rectangle([(0, 0), (1024, 1024)], radius=corner_radius, fill=255)

# Composite
final_icon = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
final_icon.paste(icon_1024, (0, 0), mask)

png_path = os.path.join(out_dir, "AppIcon.png")
final_icon.save(png_path, "PNG")
print(f"Saved {png_path}")

# Now generate iconset sizes for iconutil
iconset_dir = os.path.join(out_dir, "AppIcon.iconset")
os.makedirs(iconset_dir, exist_ok=True)

sizes = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png")
]

for s, filename in sizes:
    resized = final_icon.resize((s, s), Image.Resampling.LANCZOS)
    resized.save(os.path.join(iconset_dir, filename), "PNG")

print("Generated iconset successfully.")
