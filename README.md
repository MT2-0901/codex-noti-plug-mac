# AI Coding Agent macOS 桌面通知

macOS 上为 AI 编程助手（Codex、Claude Code）添加桌面通知。**仅在终端窗口不在前台时通知**，避免你正在看终端时被打扰。

支持终端：Warp / Terminal.app / iTerm2

依赖：[terminal-notifier](https://github.com/julien-gauthier/terminal-notifier)

```bash
brew install terminal-notifier
```

---

## 智能前台检测

脚本在发送通知前会判断运行 agent 的终端窗口是否在前台：

| 终端 | 检测方式 |
|------|---------|
| Terminal.app | 比较前台 Tab TTY 与自身 TTY |
| iTerm2 | 比较前台 Session TTY 与自身 TTY |
| Warp | 匹配前台窗口标题（含 `Claude` 或 `Codex`） |

- 终端窗口在前台 → 不通知
- 终端窗口不在前台（切到其他 App、或同一终端的其他窗口/Tab） → 通知

---

## 1. Codex

### 1.1 放置通知脚本

```bash
cp notify-only-popup.sh ~/.codex/notify-only-popup.sh
chmod +x ~/.codex/notify-only-popup.sh
```

### 1.2 配置 Codex

编辑 `~/.codex/config.toml`（没有就新建），在文件**最顶部**添加：

```toml
notify = ["/bin/bash", "/Users/你的用户名/.codex/notify-only-popup.sh"]
```

### 1.3 测试

```bash
# 在当前终端窗口运行 — 不应弹通知
~/.codex/notify-only-popup.sh '{"type":"agent-turn-complete","last-assistant-message":"测试通知"}'

# 切到其他 App 后 5 秒触发 — 应弹通知
sleep 5 && ~/.codex/notify-only-popup.sh '{"type":"agent-turn-complete","last-assistant-message":"测试通知"}'
```

---

## 2. Claude Code

Codex 和 Claude Code 共用同一个 `notify-only-popup.sh` 脚本。

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
            "command": "bash /Users/你的用户名/.codex/notify-only-popup.sh"
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
            "command": "CLAUDE_HOOK_EVENT=notification bash /Users/你的用户名/.codex/notify-only-popup.sh"
          }
        ]
      }
    ]
  }
}
```

### 2.2 通知效果

| 事件 | 通知 |
|------|------|
| 回答完成（`Stop`） | "Claude 完成" 弹窗 + default 提示音 |
| 需要审批（`Notification`） | "Claude 需要审批" 弹窗 + Ping 提示音 |

### 2.3 测试

```bash
# 在当前终端窗口运行 — 不应弹通知
bash ~/.codex/notify-only-popup.sh

# 切到其他 App 后 5 秒触发 — 应弹通知
sleep 5 && bash ~/.codex/notify-only-popup.sh
```

---

## 调试

日志文件：`/tmp/codex-notify-debug.log`

```bash
tail -f /tmp/codex-notify-debug.log
```
