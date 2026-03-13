# AI Coding Agent macOS 桌面通知

macOS 上为 AI 编程助手（Codex、Claude Code）添加桌面通知，让你在后台工作时不错过任何回答完成或审批请求。

依赖：[terminal-notifier](https://github.com/julien-gauthier/terminal-notifier)

```bash
brew install terminal-notifier
```

---

## 1. Codex

### 1.1 放置通知脚本

将 `notify-only-popup.sh` 复制到 `~/.codex/` 目录下，并赋予执行权限：

```bash
cp notify-only-popup.sh ~/.codex/notify-only-popup.sh
chmod +x ~/.codex/notify-only-popup.sh
```

### 1.2 配置 Codex

编辑 `~/.codex/config.toml`（没有就新建），在文件**最顶部**（任何 `[tui]` 或其他 `[section]` 之前）添加：

```toml
notify = ["/bin/bash", "/Users/你的用户名/.codex/notify-only-popup.sh"]
```

### 1.3 通知效果

| 事件 | 通知 |
|------|------|
| 任务完成（`agent-turn-complete`） | 弹窗 + 提示音 |

### 1.4 测试

```bash
~/.codex/notify-only-popup.sh '{"type":"agent-turn-complete","last-assistant-message":"测试通知"}'
```

---

## 2. Claude Code

Claude Code 通过官方 hooks 机制支持通知，无需额外脚本。

### 2.1 配置

编辑 `~/.claude/settings.json`，添加 `hooks` 字段：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "terminal-notifier -title '✅ Claude 完成' -message 'Claude 已完成回答，等待你的输入' -sound default"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "terminal-notifier -title '🔐 Claude 需要审批' -message '有工具调用需要你批准' -sound Ping"
          }
        ]
      }
    ]
  }
}
```

### 2.2 通知效果

| 事件 | Hook | 通知 |
|------|------|------|
| 回答完成 | `Stop` | 弹窗 + default 提示音 |
| 需要审批工具调用 | `Notification`（`permission_prompt`） | 弹窗 + Ping 提示音 |

### 2.3 说明

- `Stop` hook：Claude 完成回答时触发
- `Notification` hook + `permission_prompt` matcher：Claude 需要用户批准工具调用时触发
- 配置修改后需要**重启 Claude Code 会话**才能生效
