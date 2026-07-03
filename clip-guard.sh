#!/usr/bin/env bash
# tmux 复制守卫：读入选区内容，仅当含至少一个非空白字符时才写 Windows 剪贴板；
# 空 / 纯空白直接丢弃 —— 避免单击、微拖动、双击空白处等以空选区触发复制，
# 把剪贴板清空 + 弹「已复制」。所有复制路径统一走这里。
data=$(cat)
if [[ "$data" == *[!$' \t\r\n']* ]]; then
  printf '%s' "$data" | clip.exe
fi
