#!/usr/bin/env python3
import os
from PIL import Image, ImageDraw, ImageFont
import sys

def create_app_icon():
    # 创建图标目录
    icon_dir = "AppIcon.appiconset"
    if not os.path.exists(icon_dir):
        os.makedirs(icon_dir)
    
    # 定义需要的图标尺寸
    icon_sizes = [
        (20, 1, "20x20"),      # iPhone Notification iOS 7-14
        (20, 2, "20x20@2x"),   # iPhone Notification iOS 7-14
        (20, 3, "20x20@3x"),   # iPhone Notification iOS 7-14
        (29, 1, "29x29"),      # iPhone Settings iOS 5-14
        (29, 2, "29x29@2x"),   # iPhone Settings iOS 5-14
        (29, 3, "29x29@3x"),   # iPhone Settings iOS 5-14
        (40, 1, "40x40"),      # iPhone Spotlight iOS 7-14
        (40, 2, "40x40@2x"),   # iPhone Spotlight iOS 7-14
        (40, 3, "40x40@3x"),   # iPhone Spotlight iOS 7-14
        (60, 2, "60x60@2x"),   # iPhone App iOS 7-14
        (60, 3, "60x60@3x"),   # iPhone App iOS 7-14
        (76, 1, "76x76"),      # iPad App iOS 7-14
        (76, 2, "76x76@2x"),   # iPad App iOS 7-14
        (83.5, 2, "83.5x83.5@2x"), # iPad Pro App iOS 9-14
        (1024, 1, "1024x1024") # App Store iOS
    ]
    
    # 为每个尺寸创建图标
    for base_size, scale, filename in icon_sizes:
        size = int(base_size * scale)
        create_single_icon(size, os.path.join(icon_dir, f"{filename}.png"))
    
    # 创建Contents.json文件
    create_contents_json(icon_dir)
    
    print(f"图标已创建在 {icon_dir} 目录中")

def create_single_icon(size, filename):
    # 创建圆角方形背景
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # 计算圆角半径（苹果建议约为尺寸的22.37%）
    corner_radius = int(size * 0.2237)
    
    # 绘制渐变背景（模拟棋盘颜色）
    # 从深棕色到浅棕色的渐变
    for y in range(size):
        progress = y / size
        # 深棕色 (139, 69, 19) 到 浅棕色 (205, 133, 63)
        r = int(139 + (205 - 139) * progress)
        g = int(69 + (133 - 69) * progress)
        b = int(19 + (63 - 19) * progress)
        
        # 绘制带圆角的矩形
        if y < corner_radius:
            # 顶部圆角
            for x in range(size):
                if is_in_rounded_rect(x, y, size, corner_radius):
                    draw.point((x, y), fill=(r, g, b, 255))
        elif y >= size - corner_radius:
            # 底部圆角
            for x in range(size):
                if is_in_rounded_rect(x, y, size, corner_radius):
                    draw.point((x, y), fill=(r, g, b, 255))
        else:
            # 中间部分
            draw.line([(0, y), (size-1, y)], fill=(r, g, b, 255))
    
    # 添加棋盘网格效果
    grid_color = (160, 82, 45, 128)  # 半透明的棕色
    grid_lines = 6  # 网格线数量
    for i in range(1, grid_lines):
        pos = int(size * i / grid_lines)
        # 水平线
        draw.line([(size//8, pos), (size-size//8, pos)], fill=grid_color, width=max(1, size//100))
        # 垂直线
        draw.line([(pos, size//8), (pos, size-size//8)], fill=grid_color, width=max(1, size//100))
    
    # 添加"技"字
    try:
        # 尝试使用系统字体
        font_size = int(size * 0.6)  # 字体大小为图标的60%
        
        # 尝试不同的字体
        font_paths = [
            "/System/Library/Fonts/Helvetica.ttc",
            "/System/Library/Fonts/Arial.ttf",
            "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
            "/System/Library/Fonts/Times.ttc"
        ]
        
        font = None
        for font_path in font_paths:
            try:
                if os.path.exists(font_path):
                    font = ImageFont.truetype(font_path, font_size)
                    break
            except:
                continue
        
        if font is None:
            font = ImageFont.load_default()
        
        # 绘制"技"字
        text = "技"
        
        # 获取文字尺寸
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        # 计算居中位置
        x = (size - text_width) // 2
        y = (size - text_height) // 2
        
        # 绘制文字阴影
        shadow_offset = max(1, size // 80)
        draw.text((x + shadow_offset, y + shadow_offset), text, font=font, fill=(0, 0, 0, 128))
        
        # 绘制主要文字
        draw.text((x, y), text, font=font, fill=(255, 255, 255, 255))
        
    except Exception as e:
        print(f"字体加载失败: {e}")
        # 如果字体加载失败，绘制一个简单的圆圈
        circle_size = size // 3
        circle_pos = (size - circle_size) // 2
        draw.ellipse([circle_pos, circle_pos, circle_pos + circle_size, circle_pos + circle_size], 
                    fill=(255, 255, 255, 255), outline=(0, 0, 0, 255), width=max(1, size//50))
    
    # 保存图像
    image.save(filename, "PNG")

def is_in_rounded_rect(x, y, size, corner_radius):
    """检查点是否在圆角矩形内"""
    # 检查四个角
    if x < corner_radius and y < corner_radius:
        # 左上角
        return (x - corner_radius)**2 + (y - corner_radius)**2 <= corner_radius**2
    elif x >= size - corner_radius and y < corner_radius:
        # 右上角
        return (x - (size - corner_radius))**2 + (y - corner_radius)**2 <= corner_radius**2
    elif x < corner_radius and y >= size - corner_radius:
        # 左下角
        return (x - corner_radius)**2 + (y - (size - corner_radius))**2 <= corner_radius**2
    elif x >= size - corner_radius and y >= size - corner_radius:
        # 右下角
        return (x - (size - corner_radius))**2 + (y - (size - corner_radius))**2 <= corner_radius**2
    else:
        # 不在角落，肯定在矩形内
        return True

def create_contents_json(icon_dir):
    """创建Contents.json文件"""
    contents = {
        "images": [
            {"idiom": "iphone", "scale": "2x", "size": "20x20", "filename": "20x20@2x.png"},
            {"idiom": "iphone", "scale": "3x", "size": "20x20", "filename": "20x20@3x.png"},
            {"idiom": "iphone", "scale": "1x", "size": "29x29", "filename": "29x29.png"},
            {"idiom": "iphone", "scale": "2x", "size": "29x29", "filename": "29x29@2x.png"},
            {"idiom": "iphone", "scale": "3x", "size": "29x29", "filename": "29x29@3x.png"},
            {"idiom": "iphone", "scale": "2x", "size": "40x40", "filename": "40x40@2x.png"},
            {"idiom": "iphone", "scale": "3x", "size": "40x40", "filename": "40x40@3x.png"},
            {"idiom": "iphone", "scale": "2x", "size": "60x60", "filename": "60x60@2x.png"},
            {"idiom": "iphone", "scale": "3x", "size": "60x60", "filename": "60x60@3x.png"},
            {"idiom": "ipad", "scale": "1x", "size": "20x20", "filename": "20x20.png"},
            {"idiom": "ipad", "scale": "2x", "size": "20x20", "filename": "20x20@2x.png"},
            {"idiom": "ipad", "scale": "1x", "size": "29x29", "filename": "29x29.png"},
            {"idiom": "ipad", "scale": "2x", "size": "29x29", "filename": "29x29@2x.png"},
            {"idiom": "ipad", "scale": "1x", "size": "40x40", "filename": "40x40.png"},
            {"idiom": "ipad", "scale": "2x", "size": "40x40", "filename": "40x40@2x.png"},
            {"idiom": "ipad", "scale": "1x", "size": "76x76", "filename": "76x76.png"},
            {"idiom": "ipad", "scale": "2x", "size": "76x76", "filename": "76x76@2x.png"},
            {"idiom": "ipad", "scale": "2x", "size": "83.5x83.5", "filename": "83.5x83.5@2x.png"},
            {"idiom": "ios-marketing", "scale": "1x", "size": "1024x1024", "filename": "1024x1024.png"}
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    import json
    with open(os.path.join(icon_dir, "Contents.json"), 'w') as f:
        json.dump(contents, f, indent=2)

if __name__ == "__main__":
    create_app_icon()