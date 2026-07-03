#!/usr/bin/env bash
# 复制守卫自愈：把所有复制路径改走 clip-guard.sh（空/纯空白不写剪贴板，防单击/误触清空剪贴板 + 弹「已复制」）。
# 由 client-attached hook 调用。oh-my-tmux 的 _apply_configuration 在 attach 后异步覆盖绑定，
# 这里反复 source copy-guard.conf，直到守卫版最终生效（盖过 oh-my-tmux）。
for i in $(seq 1 25); do
  tmux source-file ~/.tmux/copy-guard.conf 2>/dev/null
  cur=$(tmux list-keys -T copy-mode-vi 2>/dev/null | grep MouseDragEnd1Pane)
  case "$cur" in *clip-guard*) exit 0 ;; esac
  sleep 0.2
done
