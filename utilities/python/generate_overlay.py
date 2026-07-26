import math
import argparse
from PIL import Image, ImageDraw

def generate_spiral(draw, x_offset, y_offset, size, color):
    center_x, center_y = x_offset + size // 2, y_offset + size // 2
    max_radius = size // 2 - 2
    points = []
    # Archimedean spiral: r = a * theta
    a = max_radius / (3 * math.pi)
    for i in range(0, 300):
        theta = i / 10
        r = a * theta
        if r > max_radius:
            break
        x = center_x + r * math.cos(theta)
        y = center_y + r * math.sin(theta)
        points.append((x, y))
    
    if len(points) > 1:
        draw.line(points, fill=color, width=1)

def generate_sphere(draw, x_offset, y_offset, size, color):
    draw.ellipse([x_offset + 2, y_offset + 2, x_offset + size - 2, y_offset + size - 2], outline=color, width=1)

def generate_star(draw, x_offset, y_offset, size, color):
    center_x, center_y = x_offset + size // 2, y_offset + size // 2
    r_outer = size // 2 - 1
    r_inner = size // 4
    points = []
    for i in range(10):
        angle = math.radians(i * 36 - 90)
        r = r_outer if i % 2 == 0 else r_inner
        points.append((center_x + r * math.cos(angle), center_y + r * math.sin(angle)))
    draw.polygon(points, outline=color)

def generate_ring(draw, x_offset, y_offset, size, color):
    draw.ellipse([x_offset + 2, y_offset + 2, x_offset + size - 2, y_offset + size - 2], outline=color, width=1)
    draw.ellipse([x_offset + 5, y_offset + 5, x_offset + size - 5, y_offset + size - 5], outline=color, width=1)

def generate_burst(draw, x_offset, y_offset, size, color):
    center_x, center_y = x_offset + size // 2, y_offset + size // 2
    for i in range(8):
        angle = math.radians(i * 45)
        draw.line([center_x, center_y, center_x + (size//2-1) * math.cos(angle), center_y + (size//2-1) * math.sin(angle)], fill=color, width=1)

def generate_chaotic(draw, x_offset, y_offset, size, color):
    import random
    random.seed(42)
    center_x, center_y = x_offset + size // 2, y_offset + size // 2
    for i in range(12):
        angle = math.radians(random.uniform(0, 360))
        dist = random.uniform(size // 4, size // 2 - 1)
        x, y = center_x + dist * math.cos(angle), center_y + dist * math.sin(angle)
        # Add a jagged segment
        x2, y2 = x + random.uniform(-2, 2), y + random.uniform(-2, 2)
        draw.line([center_x, center_y, x, y, x2, y2], fill=color, width=1)

def generate_flame(draw, x_offset, y_offset, size, color):
    cx, cy = x_offset + size // 2, y_offset + size // 2
    # Organic flame shape using multiple points
    points = [
        (cx, y_offset + 1), # Tip
        (x_offset + size - 3, y_offset + size // 2 + 2),
        (x_offset + size - 5, y_offset + size - 2),
        (cx, y_offset + size - 4), # Inner flicker
        (x_offset + 5, y_offset + size - 2),
        (x_offset + 3, y_offset + size // 2 + 2),
    ]
    draw.polygon(points, outline=color)
    # Add a small inner flame
    draw.line([cx, cy + 2, cx, y_offset + size - 6], fill=color, width=1)

def generate_snowflake(draw, x_offset, y_offset, size, color):
    center_x, center_y = x_offset + size // 2, y_offset + size // 2
    for i in range(6):
        angle = math.radians(i * 60)
        x, y = center_x + (size//2-1) * math.cos(angle), center_y + (size//2-1) * math.sin(angle)
        draw.line([center_x, center_y, x, y], fill=color, width=1)
        # Add small ticks
        tx, ty = center_x + (size//4) * math.cos(angle), center_y + (size//4) * math.sin(angle)
        t_angle = angle + math.radians(90)
        draw.line([tx - 2*math.cos(t_angle), ty - 2*math.sin(t_angle), tx + 2*math.cos(t_angle), ty + 2*math.sin(t_angle)], fill=color, width=1)

def generate_hour_glass(draw, x_offset, y_offset, size, color):
    points = [
        (x_offset + 2, y_offset + 2),
        (x_offset + size - 2, y_offset + 2),
        (x_offset + 2, y_offset + size - 2),
        (x_offset + size - 2, y_offset + size - 2)
    ]
    draw.line([points[0], points[1]], fill=color)
    draw.line([points[1], points[2]], fill=color)
    draw.line([points[2], points[3]], fill=color)
    draw.line([points[3], points[0]], fill=color)

def main():
    parser = argparse.ArgumentParser(description="Generate firework overlay shapes.")
    parser.add_argument("--shape", choices=["sphere", "star", "ring", "burst", "spiral", "chaotic", "flame", "snowflake", "hour_glass"], default="spiral", help="Shape to generate")
    parser.add_argument("--output", default="fireworks_overlay_icon.png", help="Output filename")
    parser.add_argument("--canvas_size", type=int, default=64, help="Canvas size (default 64x64)")
    parser.add_argument("--icon_size", type=int, default=16, help="Icon size (default 16x16)")
    
    args = parser.parse_args()
    
    img = Image.new("RGBA", (args.canvas_size, args.canvas_size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    generators = {
        "sphere": generate_sphere,
        "star": generate_star,
        "ring": generate_ring,
        "burst": generate_burst,
        "spiral": generate_spiral,
        "chaotic": generate_chaotic,
        "flame": generate_flame,
        "snowflake": generate_snowflake,
        "hour_glass": generate_hour_glass
    }
    
    generators[args.shape](draw, 0, 0, args.icon_size, (255, 255, 255, 255))
    
    img.save(args.output)
    print(f"Generated {args.shape} overlay at {args.output}")

if __name__ == "__main__":
    main()
