# NavigationAgent2D 导航寻路设置指南

## 概述
这个指南帮助您在Godot 4.x中设置2D导航寻路系统，使用NavigationAgent2D实现智能路径规划和避障。

## 核心组件

### 1. NavigationRegion2D（导航区域）
- 定义可行走的区域
- 自动生成导航网格
- 支持动态障碍物

### 2. NavigationAgent2D（导航代理）
- 附加到移动角色上
- 计算最优路径
- 处理避障和碰撞检测

### 3. NavigationObstacle2D（导航障碍物）
- 标记不可行走区域
- 支持动态障碍物
- 可以设置不同的避障成本

## 参数详解

详细的NavigationAgent2D参数配置说明，请参考 [NavigationAgent2D参数配置指南](navigation_agent2d_parameters_guide.md)。

### 快速参数参考

| 参数 | 作用 | 推荐值 | 说明 |
|------|------|--------|------|
| path_desired_distance | 路径点期望距离 | 10.0-50.0 | 控制路径跟随精度 |
| target_desired_distance | 目标期望距离 | 5.0-20.0 | 控制到达目标精度 |
| radius | 代理半径 | 角色宽度/2 | 用于避障计算 |
| max_speed | 最大速度 | 角色移动速度 | 限制移动速度 |
| avoidance_enabled | 启用避障 | true/false | 动态避障开关 |

## 设置步骤

### 步骤1：创建导航区域

1. 在场景中添加 `NavigationRegion2D` 节点
2. 创建 `NavigationPolygon` 资源
3. 定义可行走区域边界

```gdscript
# 代码创建导航区域
var nav_polygon = NavigationPolygon.new()
var outline = PackedVector2Array([
    Vector2(0, 0),      # 左上角
    Vector2(2000, 0),   # 右上角
    Vector2(2000, 800), # 右下角
    Vector2(0, 800)     # 左下角
])
nav_polygon.add_outline(outline)
nav_polygon.make_polygons_from_outlines()
$NavigationRegion2D.navigation_polygon = nav_polygon
```

### 步骤2：设置玩家导航代理

1. 在玩家节点下添加 `NavigationAgent2D` 节点
2. 配置导航参数：
   - `path_desired_distance`: 路径目标距离 (10.0)
   - `target_desired_distance`: 目标距离 (5.0)
   - `radius`: 代理半径 (16.0)
   - `max_speed`: 最大速度 (100.0)

### 步骤3：编写导航脚本

参考 `spine_player.gd` 中的实现：

```gdscript
# 导航相关变量
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
    # 初始化导航代理
    if navigation_agent:
        navigation_agent.path_desired_distance = 10.0
        navigation_agent.target_desired_distance = 5.0
        navigation_agent.radius = 16.0
        navigation_agent.max_speed = move_speed
        
        # 连接导航信号
        navigation_agent.velocity_computed.connect(_on_velocity_computed)

func move_to_position_with_navigation(target_pos):
    if navigation_agent:
        navigation_agent.set_target_position(target_pos)
        # 开始导航移动...

func _physics_process(delta):
    if is_moving and navigation_agent and not navigation_agent.is_navigation_finished():
        var next_pos = navigation_agent.get_next_path_position()
        var direction = (next_pos - global_position).normalized()
        navigation_agent.set_velocity(direction * move_speed)

func _on_velocity_computed(safe_velocity):
    velocity = safe_velocity
    move_and_slide()
```

## 高级功能

### 动态障碍物
```gdscript
# 创建动态障碍物
var obstacle = NavigationObstacle2D.new()
obstacle.radius = 32.0
add_child(obstacle)
```

### 导航层和掩码
- 使用不同的导航层来区分不同类型的地形
- 设置代理的导航层掩码来控制可行走区域

### 避障配置
```gdscript
# 启用避障
navigation_agent.avoidance_enabled = true
navigation_agent.avoidance_layers = 1
navigation_agent.avoidance_mask = 1
navigation_agent.avoidance_priority = 1.0
```

## 调试技巧

### 1. 显示导航路径
```gdscript
func _draw():
    if navigation_agent:
        var path = navigation_agent.get_nav_path()
        for i in range(path.size() - 1):
            draw_line(path[i], path[i + 1], Color.RED, 2.0)
```

### 2. 导航状态监控
```gdscript
func _process(delta):
    if navigation_agent:
        print("导航状态: ", navigation_agent.is_navigation_finished())
        print("路径点数: ", navigation_agent.get_nav_path().size())
```

### 3. 性能优化
- 避免频繁的路径重新计算
- 使用合适的路径目标距离
- 限制同时活跃的导航代理数量

## 常见问题解决

### Q: 角色不移动或移动不自然
A: 检查导航代理的参数设置，确保目标距离和路径距离合适

### Q: 导航路径穿过障碍物
A: 确保障碍物正确添加到导航区域，并设置合适的碰撞层

### Q: 导航计算性能问题
A: 减少导航网格的复杂度，使用更大的单元格大小

### Q: 角色在复杂地形中卡住
A: 增加代理半径，调整避障参数

## 最佳实践

1. **合理设置参数**：根据角色大小和移动速度调整导航参数
2. **分层导航**：使用不同的导航层来处理不同类型的地形
3. **动态更新**：在运行时动态更新导航网格以适应变化的环境
4. **性能监控**：定期检查导航系统的性能表现
5. **用户反馈**：提供视觉反馈显示导航路径和目标位置