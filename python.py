#!/usr/bin/env python3

from PIL import Image, ImageDraw, ImageFont

WIDTH = 25
HEIGHT = 8

# Create 25x8 black canvas
image = Image.new("RGB", (WIDTH, HEIGHT), "black")

# Render at a larger size first, then scale down.
# This uses an actual font rather than a manually defined bitmap.
font = ImageFont.truetype(
    "/usr/share/fonts/truetype/liberation2/LiberationMono-Bold.ttf",
    100
)

# Render text to a large temporary image
temp = Image.new("L", (1000, 200), 0)
draw = ImageDraw.Draw(temp)

# Get text bounding box
bbox = draw.textbbox((0, 0), "2027", font=font)

# Draw white text
draw.text(
    (-bbox[0] + 5, -bbox[1] + 5),
    "2O27",
    font=font,
    fill=255
)

# Crop to actual rendered content
bbox = temp.getbbox()
temp = temp.crop(bbox)

# Scale to exactly 23x8:
# 1 pixel buffer on left
# 23 pixels available for text
# 1 pixel buffer on right
temp = temp.resize(
    (23, 8),
    Image.Resampling.LANCZOS
)

# Paste into image
image.paste(
    (191, 162, 0),
    (1, 0),
    temp
)

# Save
image.save("2027.png")

print("Created 25x8 image: 2027.png")
