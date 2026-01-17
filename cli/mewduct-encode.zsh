#!/bin/zsh

_dir=${0:a:h}

typeset RESERVE_INDEX_SPACE_SIZE=96k
typeset -A map_bv=(
  320 300k
  360 300k
  426 500k
  480 500k
  576 700k
  640 800k
  720 1100k
  1080 1600k
)

source_file="$1"
outdir="$2"

usage() {
  print "mewduct-encode.zsh <source> [<outdir>]" >&2
  exit 1
}

[[ -f "$source_file" ]] || usage

video_geo=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$source_file")
video_geo=(${(ps:,:)video_geo})

typeset video_layout=landscape
if (( video_geo[1] < video_geo[2] ))
then
  video_layout=portrait
fi

typeset -i longer_index shorter_index video_longer video_shorter

if [[ "$video_layout" == "landscape" ]]
then
  longer_index=1
  shorter_index=2
  video_longer=${video_geo[1]}
  video_shorter=${video_geo[2]}
else
  longer_index=2
  shorter_index=1
  video_longer=${video_geo[2]}
  video_shorter=${video_geo[1]}
fi

typeset -a valid_size=()
for i in 320 360 426 480 576 640 720 1080
do
  if (( video_shorter < i ))
  then
    continue
  fi

  typeset -F divr=$(( video_shorter * 1.0 / i  ))

  typeset -F longer_processed=$(( video_longer / divr ))
  typeset -F longer_processed_rem=$(( longer_processed % 1 ))
  if (( longer_processed_rem != 0 ))
  then
    continue
  fi
  valid_size+=($i)
done

if [[ -z "$outdir" ]]
then
  outdir=./videoout
fi

[[ -e $outdir ]] || mkdir -v $outdir

typeset video_duration_display=$($_dir/mewduct-duration.zsh "$source_file")

cat > "$outdir"/titlemeta.yaml <<EOF
---
title: ""
description: ""
unlisted: false
lang: en
duration: "${video_duration_display}"
translations: {}
EOF

typeset ext vcodec scale acodec samesize=no
typeset -a voopts=()
if (( video_shorter <= 360 || ${#valid_size} == 0 ))
then
  ffmpeg -i "$source_file" -c:v libx264 -crf 27 -profile:v baseline "$outdir/default.mp4"
else
  for short in ${valid_size}
  do
    if (( short < 640 ))
    then
      ext=mp4
      vcodec=libx264
      acodec=aac
    else
      ext=webm
      vcodec=libvpx-vp9
      acodec=libopus
    fi

    case "$ext" in
      mp4)
        voopts+=(-movflags +faststart)
        ;;
      webm)
        voopts+=(-reserve_index_space ${RESERVE_INDEX_SPACE_SIZE}})
        ;;
    esac

    if [[ $video_layout == landscape ]]
    then
      scale="-1:$short"
    else
      scale="$short:-1"
    fi

    if (( short == video_shorter ))
    then
      samesize=yes
    fi

    (
      source_file=${source_file:a}
      outdir=${outdir:a}
      workdir=$(mktemp -d)
      crd="$PWD"

      cd "$workdir"

      typeset scale_params=()
      if [[ $samesize != yes ]]
      then
        scale_params=("-vf" "scale=$scale")
      fi

      if ! {
        ffmpeg -i "$source_file" -c:v "$vcodec" -b:v "${map_bv[$short]}" $scale_params -pass 1 -an -f null /dev/null &&
        ffmpeg -i "$source_file" -c:v "$vcodec" -b:v "${map_bv[$short]}" $scale_params -pass 2 -c:a $acodec $voopts "$outdir/$short.$ext"
      }
      then
        rm -v "$outdir/$short.$ext"
      fi
      cd "$crd"
      rm -rv "$workdir"
    )
  done
fi

# Creating thumbnail
ffmpeg -i "$source_file" -vf "thumbnail=1800" -frames:v 1 "$outdir/thumbnail.webp"

