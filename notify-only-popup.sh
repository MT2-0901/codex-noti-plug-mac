#!/bin/bash
# Codex 纯弹窗 + 常驻通知（macOS terminal-notifier 版）
# 无声音、无依赖、任务结束立刻弹出并常驻

payload="${1}"
echo "$(date '+%Y-%m-%d %H:%M:%S') | 收到 payload: ${payload:0:200}..." >> /tmp/codex-notify-debug.log

if [[ "$payload" == *'"type":"agent-turn-complete"'* ]]; then
    message=$(echo "$payload" | grep -o '"last-assistant-message":"[^"]*"' | cut -d'"' -f4 | sed 's/\\n/ /g' || echo "Codex 任务已完成！")
    
    # 安全处理消息
    safe_message="${message//\"/\\\"}"
    
    # 发送常驻通知（无声音）
    terminal-notifier \
        -title "✅ Codex 完成" \
        -message "$safe_message" \
        -timeout 0 \
        >> /tmp/codex-notify-debug.log 2>&1
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') | ✅ 已发送常驻通知" >> /tmp/codex-notify-debug.log
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') | 非完成事件，跳过" >> /tmp/codex-notify-debug.log
fi
