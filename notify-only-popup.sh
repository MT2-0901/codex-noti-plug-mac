#!/bin/bash
# Codex 纯弹窗通知（macOS 原生 osascript）

payload="${1}"
echo "$(date '+%Y-%m-%d %H:%M:%S') | 收到 payload: ${payload:0:200}..." >> /tmp/codex-notify-debug.log

if [[ "$payload" == *'"type":"agent-turn-complete"'* ]]; then
    # 安全提取消息（兼容官方字段）
    message=$(echo "$payload" | grep -o '"last-assistant-message":"[^"]*"' | cut -d'"' -f4 | sed 's/\\n/ /g' || echo "")
    message="${message:-Codex 任务已完成！}"

    # 安全转义双引号，避免 osascript 报错
    safe_message="${message//\"/\\\"}"

    terminal-notifier -title "✅ Codex 完成" -message "${safe_message}" -sound default 2>> /tmp/codex-notify-debug.log
    echo "$(date '+%Y-%m-%d %H:%M:%S') | ✅ 已发送通知: ${message:0:100}" >> /tmp/codex-notify-debug.log
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') | 非 agent-turn-complete 事件，跳过" >> /tmp/codex-notify-debug.log
fi