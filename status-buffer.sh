#!/usr/bin/env bash
# 状态栏：当前窗格历史缓冲进度条 + 字节 + tmux 进程内存
# 由 oh-my-tmux 的 status-right 通过 #(...) 每 status-interval 调一次
# 自查活动窗格（#() 内部不展开 #{}，必须脚本自己向 tmux 要数据）

read -r size limit bytes < <(tmux display -p '#{history_size} #{history_limit} #{history_bytes}' 2>/dev/null)
size=${size:-0}; limit=${limit:-1}; bytes=${bytes:-0}
[ "$limit" -le 0 ] 2>/dev/null && limit=1

width=8
filled=$(( size * width / limit ))
[ "$filled" -gt "$width" ] && filled=$width
[ "$filled" -lt 0 ] && filled=0
# 只要有历史就至少点亮 1 格，方便看出颜色
[ "$size" -gt 0 ] && [ "$filled" -lt 1 ] && filled=1
pct=$(( size * 100 / limit ))

# 进度条按使用率变色：绿(<60) / 黄(60-85) / 红(>=85)
if [ "$pct" -ge 85 ]; then barcol='#ff5f5f'
elif [ "$pct" -ge 60 ]; then barcol='#ffff5f'
else barcol='#87ff5f'; fi
emptycol='#4a8bb0'
textcol='#e4e4e4'

fill=''; empt=''
i=0
while [ "$i" -lt "$width" ]; do
  if [ "$i" -lt "$filled" ]; then fill="${fill}█"; else empt="${empt}░"; fi
  i=$(( i + 1 ))
done

human() {
  local b=$1
  if [ "$b" -ge 1048576 ]; then
    printf '%d.%dM' $(( b / 1048576 )) $(( (b % 1048576) * 10 / 1048576 ))
  elif [ "$b" -ge 1024 ]; then
    printf '%dK' $(( b / 1024 ))
  else
    printf '%dB' "$b"
  fi
}
hb=$(human "$bytes")

pid=$(tmux display -p '#{pid}' 2>/dev/null)
rss=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ')
rss=${rss:-0}
rssM=$(( rss / 1024 ))

# 进度条：填充段用 barcol、空段用 emptycol，之后恢复 textcol 显示数字
printf 'buf[#[fg=%s]%s#[fg=%s]%s#[fg=%s]]%d%% %s · tmux %dM' \
  "$barcol" "$fill" "$emptycol" "$empt" "$textcol" "$pct" "$hb" "$rssM"
