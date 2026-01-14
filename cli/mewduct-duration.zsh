#!/bin/zsh

typeset source_file="$1"

typeset -i video_duration_sec=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$source_file")
typeset -i video_duration_h=$(( video_duration_sec / ( 60 * 60 ) ))
typeset -i video_duration_m=$(( ( video_duration_sec % ( 60 * 60 ) ) / 60 ))
typeset -i video_duration_s=$(( video_duration_sec % 60 ))

typeset video_duration_display
if (( video_duration_h > 0 ))
then
  video_duration_display+=$video_duration_h:
fi
if (( video_duration_h > 0 || video_duration_m > 0 ))
then
  video_duration_display+=$(printf "%02d" $video_duration_m):
fi
video_duration_display+=$(printf "%02d" $video_duration_s)

print $video_duration_display