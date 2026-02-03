# Sky Hill Godot 音频系统实现建议

## 1. 项目现状分析

根据对代码仓库的扫描，当前项目（Sky Hill Godot）的开发状态如下：

- **架构模式**：项目采用了清晰的单例管理模式。在 `src/` 目录下存在多个 `Manager` 类（如 `PlayerManager`, `ItemManager`, `WeaponManager`），它们通过静态变量 `instance` 实现全局访问。
- **资源组织**：
    - 资源集中在 `assets/` 目录下。
    - 动画使用 Spine 插件实现，相关资源位于 `assets/enemy/` 和 `assets/fighter_player/`。
    - UI 和道具图片位于 `assets/sprites/game_items/`。
- **缺失部分**：
    - 尚未发现任何音频资源文件（`.wav`, `.mp3`, `.ogg`）。
    - 代码中未发现音频播放逻辑（`AudioStreamPlayer`）或全局音频控制逻辑。
    - `project.godot` 中未配置音频总线（Audio Bus）。

---

## 2. 建议做法

为了保持与现有项目架构的一致性并确保音频系统的可扩展性，建议按照以下步骤实施：

### 2.1 建立音频资源目录
在 `assets/` 下创建统一的音频存放路径：
- `assets/audio/bgm/`：存放长背景音乐。
- `assets/audio/sfx/`：存放短促音效（攻击、点击、受击等）。

### 2.2 实现全局音频管理器 (AudioManager)
建议在 `src/audio/` 目录下创建 `audio_manager.gd`，并将其注册为全局单例（Autoload）或遵循项目中现有的 `Manager` 模式。

#### 核心代码示例：
```gdscript
extends Node

class_name AudioManager

static var instance: AudioManager

# 播放器引用
var bgm_player: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
var pool_size: int = 8

func _init():
    if instance == null:
        instance = self
        _setup_audio_nodes()
    else:
        queue_free()

static func get_instance() -> AudioManager:
    if instance == null:
        instance = AudioManager.new()
    return instance

func _setup_audio_nodes():
    # 配置背景音乐播放器
    bgm_player = AudioStreamPlayer.new()
    bgm_player.bus = "Music"
    add_child(bgm_player)
    
    # 配置音效池
    for i in range(pool_size):
        var p = AudioStreamPlayer.new()
        p.bus = "SFX"
        add_child(p)
        sfx_pool.append(p)

# 接口：播放背景音乐
func play_bgm(stream: AudioStream):
    if bgm_player.stream == stream: return
    bgm_player.stream = stream
    bgm_player.play()

# 接口：播放音效
func play_sfx(stream: AudioStream):
    for p in sfx_pool:
        if not p.playing:
            p.stream = stream
            p.play()
            return
```

### 2.3 配置音频总线 (Audio Bus)
在 Godot 编辑器中打开 **Audio** 面板，创建以下结构：
1. **Master**: 默认总线。
2. **Music**: 发送到 Master，用于统一控制背景音乐音量。
3. **SFX**: 发送到 Master，用于统一控制音效音量。

### 2.4 集成建议
- **Spine 动画音效**：
  在 Spine 动画中添加 Event（如 `footstep`, `attack`）。在 `spine_player.gd` 中监听 `animation_event` 信号：
  ```gdscript
  func _on_spine_sprite_animation_event(player, animation_state, track_index, event):
      if event.data.name == "attack":
          AudioManager.get_instance().play_sfx(load("res://assets/audio/sfx/hit.wav"))
  ```
- **UI 音效**：
  在通用按钮或 `main_ui_canvas_layer.gd` 中，统一为按钮点击绑定音效。
- **场景 BGM**：
  在 `main_world.gd` 的 `_ready` 或切换楼层逻辑中调用 `play_bgm`。

---

## 3. 后续扩展
- **音频淡入淡出**：在切换 BGM 时增加 `Tween` 动画。
- **音量设置持久化**：将音量值保存到配置文件，启动时通过 `AudioServer` 恢复设置。
