from PIL import Image, ImageDraw, ImageFont

# 32x32 canvas
img = Image.new("RGB", (32, 32), (0, 0, 0))
draw = ImageDraw.Draw(img)

# Colors
color_B = (240, 180, 100)
color_D = (160, 60, 40)

# Try to load a pixel-ish font (optional)
# If you don't have one, Pillow falls back to default
try:
    font = ImageFont.truetype("DejaVuSans-Bold.ttf", 28)
except:
    font = ImageFont.load_default()

# Draw B
draw.text((0, -4), "B", fill=color_B, font=font)

# Draw D (shifted right slightly)
draw.text((16, -4), "D", fill=color_D, font=font)

img.save("BD.png")
print("Saved BD.png")

