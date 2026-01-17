#!/bin/zsh

usage() {
  print 'set-faststart.zsh <webroot>' >&2
  exit 1
}

RESERVE_INDEX_SPACE_SIZE=96k

if [[ -e videoout_migration ]]
then
  print 'videoout_migration directory already exists.'
  usage
fi

webroot="$1"

if [[ ! -d "$webroot" ]]
then
  usage
fi

mkdir videoout_migration

for video in "$webroot"/media/*/*/*.(mp4|webm)
do
  vpath="${video:a}"
  vext="${video:e}"

  case "$vext" in
    mp4)
      ffmpeg -nostdin -i "$vpath" -c:v copy -c:a copy -movflags +faststart videoout_migration/"${vpath:t}" && mv -v videoout_migration/"${vpath:t}" "${vpath}"
      ;;
    webm)
      ffmpeg -nostdin -i "$vpath" -c:v copy -c:a copy -reserve_index_space ${RESERVE_INDEX_SPACE_SIZE} videoout_migration/"${vpath:t}" && mv -v "videoout_migration/${vpath:t}" "${vpath}"
      ;;
  esac
  if [[ -e "videoout_migration/${vpath:t}" ]]
  then
    print "$video" >>| videoout_migration/fail.log
    rm "videoout_migration/${vpath:t}"
  fi
done