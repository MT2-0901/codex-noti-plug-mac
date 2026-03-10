# codex-noti-plug-mac
用于 codex 运行完后桌面通知通知

## 编辑 ~/.codex/config.toml（没有就新建）：

* 必须放在文件最顶部！（在任何 [tui] 或其他 [section] 之前）

* notify = ["/bin/bash", "/Users/你的用户名/.codex/notify-only-popup.sh"]

* 将notify-only-popup.sh 脚本放在 ~/.codex目录下


## 赋予权限：

chmod +x ~/.codex/notify-only-popup.sh

## 测试：

Bash~/.codex/notify-only-popup.sh '{}'
