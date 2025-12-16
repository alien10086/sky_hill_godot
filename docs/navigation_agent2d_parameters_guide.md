# NavigationAgent2D 参数配置指南

## 核心参数详解

### 1. 路径跟随参数

#### path_desired_distance (路径期望距离)
- **作用**: 角色与路径点之间的期望距离
- **单位**: 像素
- **推荐值**: 10.0 - 50.0
- **效果**: 
  - 值越大：角色会更早转向下一个路径点，移动更平滑但可能偏离路径
  - 值越小：角色更精确地沿着路径移动，但可能看起来比较僵硬

#### target_desired_distance (目标期望距离)
- **作用**: 角色与最终目标之间的期望距离
- **单位**: 像素
- **推荐值**: 5.0 - 20.0
- **效果**:
  - 值越大：角色会在距离目标较远时就停止
  - 值越小：角色会更精确地到达目标位置

### 2. 物理参数

#### radius (半径)
- **作用**: 角色的碰撞半径，用于避障计算
- **单位**: 像素
- **推荐值**: 角色精灵宽度的一半
- **注意**: 必须与角色的实际大小匹配，否则避障会不准确

#### max_speed (最大速度)
- **作用**: 限制角色的最大移动速度
- **单位**: 像素/秒
- **推荐值**: 与角色的 move_speed 保持一致

### 3. 避障参数（可选）

#### avoidance_enabled (启用避障)
- **作用**: 是否启用动态避障功能
- **默认值**: false
- **注意**: 启用后会消耗更多CPU资源

#### avoidance_layers (避障层)
- **作用**: 定义角色所在的避障层
- **范围**: 1-32 的位掩码
- **用法**: 使用 `avoidance_layers = 1` 设置第1层

#### avoidance_mask (避障掩码)
- **作用**: 定义角色需要避开的其他代理所在的层
- **范围**: 1-32 的位掩码
- **用法**: 使用 `avoidance_mask = 1` 避开第1层的代理

### 4. 高级参数

#### time_horizon (时间范围)
- **作用**: 预测碰撞的时间范围
- **单位**: 秒
- **推荐值**: 3.0 - 10.0
- **效果**: 值越大，角色会更早地开始避障

#### max_neighbors (最大邻居数)
- **作用**: 同时考虑避障的最大邻居数量
- **推荐值**: 5 - 20
- **注意**: 值越大，避障计算越精确但性能消耗越大

## 调试建议

### 1. 参数调优步骤
1. 先设置基本参数（path_desired_distance、target_desired_distance、radius、max_speed）
2. 测试基本移动功能
3. 根据需要启用避障功能
4. 逐步调整避障参数

### 2. 常见问题
- **角色移动不流畅**: 增大 path_desired_distance
- **角色无法精确到达目标**: 减小 target_desired_distance
- **角色穿模或碰撞**: 调整 radius 参数
- **避障行为异常**: 检查 avoidance_layers 和 avoidance_mask 设置

### 3. 性能优化
- 避免同时启用大量代理的避障功能
- 合理设置 max_neighbors 参数
- 使用简化的碰撞形状

## 示例配置

```gdscript
# 基础配置
navigation_agent.path_desired_distance = 20.0
navigation_agent.target_desired_distance = 10.0
navigation_agent.radius = 16.0
navigation_agent.max_speed = 100.0

# 高级配置（可选）
navigation_agent.avoidance_enabled = true
navigation_agent.avoidance_layers = 1
navigation_agent.avoidance_mask = 1
navigation_agent.time_horizon = 5.0
navigation_agent.max_neighbors = 10
```

## 相关资源
- [Godot官方导航文档](https://docs.godotengine.org/en/stable/tutorials/navigation/index.html)
- [NavigationAgent2D API参考](https://docs.godotengine.org/en/stable/classes/class_navigationagent2d.html)