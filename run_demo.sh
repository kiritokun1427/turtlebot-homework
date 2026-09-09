#!/bin/bash
export TURTLEBOT3_MODEL=waffle

echo "🚀 启动 Gazebo (无头模式，减少资源占用)..."
ros2 launch turtlebot3_gazebo turtlebot3_world.launch.py headless:=true &
sleep 10   # 给 Gazebo 基本启动时间

echo "🗺️  启动 Navigation2 ..."
ros2 launch turtlebot3_navigation2 navigation2.launch.py use_sim_time:=True map:=$HOME/map.yaml &
echo "⏳ 等待地图话题出现（最长等待 60 秒）..."
timeout 60s bash -c 'while ! ros2 topic list 2>/dev/null | grep -q "/map"; do sleep 1; done'
if [ $? -eq 0 ]; then
    echo "✅ 地图已加载，继续..."
else
    echo "❌ 地图未在 60 秒内加载，请检查 map 文件路径和 Navigation2 是否正常启动。"
    exit 1
fi
sleep 3   # 额外缓冲

echo "🤖 启动自动导航脚本 ..."
ros2 run my_nav_demo nav_sequence

echo "✅ 所有任务完成！"
