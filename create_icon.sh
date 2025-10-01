#!/bin/bash

# 创建图标目录
mkdir -p AppIcon.appiconset

# 使用 sips 命令创建基础图标 (需要先有一个基础图片)
# 创建一个简单的SVG文件
cat > base_icon.svg << 'EOF'
<svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#8B4513;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#CD853F;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- 圆角矩形背景 -->
  <rect x="0" y="0" width="1024" height="1024" rx="229" ry="229" fill="url(#bg)"/>
  
  <!-- 棋盘网格 -->
  <g stroke="#A0522D" stroke-width="8" stroke-opacity="0.5">
    <line x1="128" y1="200" x2="896" y2="200"/>
    <line x1="128" y1="350" x2="896" y2="350"/>
    <line x1="128" y1="500" x2="896" y2="500"/>
    <line x1="128" y1="650" x2="896" y2="650"/>
    <line x1="128" y1="800" x2="896" y2="800"/>
    
    <line x1="200" y1="128" x2="200" y2="896"/>
    <line x1="350" y1="128" x2="350" y2="896"/>
    <line x1="500" y1="128" x2="500" y2="896"/>
    <line x1="650" y1="128" x2="650" y2="896"/>
    <line x1="800" y1="128" x2="800" y2="896"/>
  </g>
  
  <!-- 技字 -->
  <text x="512" y="600" font-family="PingFang SC, Arial, sans-serif" font-size="400" font-weight="bold" 
        text-anchor="middle" fill="white" stroke="black" stroke-width="4">技</text>
</svg>
EOF

echo "SVG图标已创建: base_icon.svg"

# 检查是否有 rsvg-convert (用于将SVG转换为PNG)
if command -v rsvg-convert &> /dev/null; then
    echo "使用 rsvg-convert 转换图标..."
    
    # 定义图标尺寸
    declare -a sizes=(
        "20:20x20.png"
        "40:20x20@2x.png"
        "60:20x20@3x.png"
        "29:29x29.png"
        "58:29x29@2x.png"
        "87:29x29@3x.png"
        "40:40x40.png"
        "80:40x40@2x.png"
        "120:40x40@3x.png"
        "120:60x60@2x.png"
        "180:60x60@3x.png"
        "76:76x76.png"
        "152:76x76@2x.png"
        "167:83.5x83.5@2x.png"
        "1024:1024x1024.png"
    )
    
    # 生成各种尺寸的图标
    for size_info in "${sizes[@]}"; do
        IFS=':' read -r size filename <<< "$size_info"
        rsvg-convert -w $size -h $size base_icon.svg -o "AppIcon.appiconset/$filename"
        echo "创建: AppIcon.appiconset/$filename (${size}x${size})"
    done
    
elif command -v qlmanage &> /dev/null; then
    echo "使用 qlmanage 生成预览图..."
    qlmanage -t -s 1024 -o . base_icon.svg
    if [ -f "base_icon.svg.png" ]; then
        mv "base_icon.svg.png" "AppIcon.appiconset/1024x1024.png"
        echo "已创建 1024x1024.png"
    fi
else
    echo "需要安装 librsvg 或使用其他工具来转换SVG"
    echo "可以使用以下命令安装: brew install librsvg"
fi

# 创建 Contents.json
cat > AppIcon.appiconset/Contents.json << 'EOF'
{
  "images" : [
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20",
      "filename" : "20x20@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20",
      "filename" : "20x20@3x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "29x29",
      "filename" : "29x29.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29",
      "filename" : "29x29@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29",
      "filename" : "29x29@3x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40",
      "filename" : "40x40@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40",
      "filename" : "40x40@3x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60",
      "filename" : "60x60@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60",
      "filename" : "60x60@3x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20",
      "filename" : "20x20.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20",
      "filename" : "20x20@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29",
      "filename" : "29x29.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29",
      "filename" : "29x29@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40",
      "filename" : "40x40.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40",
      "filename" : "40x40@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76",
      "filename" : "76x76.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76",
      "filename" : "76x76@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5",
      "filename" : "83.5x83.5@2x.png"
    },
    {
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024",
      "filename" : "1024x1024.png"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "Contents.json 已创建"
echo "图标生成完成! 请检查 AppIcon.appiconset 目录"
echo "注意: 如果需要转换SVG为PNG，请安装 librsvg: brew install librsvg"