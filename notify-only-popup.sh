#!/bin/bash
# macOS 桌面通知脚本（Codex / Claude Code 共用）
# 仅在运行 agent 的终端窗口不在前台时才发送通知

LOG="/tmp/codex-notify-debug.log"
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$LOG"; }

# ============================================================
# 1. 前台检测：判断当前终端窗口是否在前台
# ============================================================

is_terminal_in_foreground() {
    # 获取前台 App 名称
    local front_app
    front_app=$(lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')

    log "前台 App: ${front_app}"

    case "$front_app" in
        Terminal)
            # Terminal.app: 比较前台 Tab TTY 和自身 TTY
            local front_tty
            front_tty=$(osascript -e 'tell application "Terminal" to tty of selected tab of front window' 2>/dev/null)
            [ -n "$front_tty" ] && [ "$front_tty" = "/dev/$my_tty" ]
            ;;
        iTerm2)
            # iTerm2: 比较前台 Session TTY 和自身 TTY
            local front_tty
            front_tty=$(osascript -e 'tell application "iTerm2" to tty of current session of current window' 2>/dev/null)
            [ -n "$front_tty" ] && [ "$front_tty" = "/dev/$my_tty" ]
            ;;
        Warp)
            # Warp: 无法获取 TTY，退化为窗口标题匹配
            local front_title
            front_title=$(osascript -e 'tell application "System Events" to name of window 1 of process "stable"' 2>/dev/null)
            log "Warp 窗口标题: ${front_title}"
            [[ "$front_title" == *Claude* ]] || [[ "$front_title" == *Codex* ]] || [[ "$front_title" == *codex* ]]
            ;;
        *)
            # 不是终端 App
            return 1
            ;;
    esac
}

# 沿父进程链向上查找自身 TTY
my_tty=""
pid=$$
while [ "$pid" -gt 1 ]; do
    t=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
    if [ -n "$t" ] && [ "$t" != "??" ]; then
        my_tty="$t"
        break
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
done
log "自身 TTY: ${my_tty:-未找到}"

# 检测前台
if is_terminal_in_foreground; then
    log "终端窗口在前台，跳过通知"
    exit 0
fi

# ============================================================
# 2. 发送通知
# ============================================================

payload="${1:-}"

if [ -n "$payload" ]; then
    # --- Codex 模式：$1 是 JSON payload ---
    if [[ "$payload" == *'"type":"agent-turn-complete"'* ]]; then
        message=$(echo "$payload" | grep -o '"last-assistant-message":"[^"]*"' | cut -d'"' -f4 | sed 's/\\n/ /g' || echo "")
        message="${message:-Codex 任务已完成！}"
        safe_message="${message//\"/\\\"}"

        terminal-notifier -title "Codex 完成" -message "${safe_message}" -sound default 2>> "$LOG"
        log "已发送 Codex 通知: ${message:0:100}"
    else
        log "Codex: 非 agent-turn-complete 事件，跳过"
    fi
else
    # --- Claude Code 模式：通过 hook 调用，无参数 ---
    # hook 类型通过环境变量 CLAUDE_HOOK_EVENT 区分（如有）
    hook_event="${CLAUDE_HOOK_EVENT:-stop}"

    case "$hook_event" in
        notification)
            terminal-notifier -title "Claude 需要审批" -message "有工具调用需要你批准" -sound Ping 2>> "$LOG"
            log "已发送 Claude 审批通知"
            ;;
        *)
            terminal-notifier -title "Claude 完成" -message "Claude 已完成回答，等待你的输入" -sound default 2>> "$LOG"
            log "已发送 Claude 完成通知"
            ;;
    esac
fi
