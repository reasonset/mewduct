#!/bin/zsh
setopt EXTENDED_GLOB

_dir=${0:a:h}

usage() {
  print "mewduct-import.zsh <webroot> <user_id> <video_directory>" >&2
  exit 1
}

webroot="$1"; shift
user="$1"; shift
videodir="$1"; shift

if ! [[
  -d "$webroot" &&
  "$user" == [a-zA-Z0-9_]# &&
  -e "$webroot/user/$user" &&
  -d "$videodir" &&
  -f "$videodir/titlemeta.yaml"
]]
then
  usage
fi

typeset media_id=${$(uuidgen):l}
while [[ -e "$webroot/media/$user/$media_id" ]]
do
  media_id=${$(uuidgen):l}
done

video_imported="$webroot/media/$user/$media_id"
mv -v "$videodir" "$video_imported"

$_dir/mewduct-update.rb "${webroot:a}" "$user" "$media_id"
$_dir/mewduct-user.rb update "${webroot:a}" "$user"
$_dir/mewduct-home.rb "${webroot:a}"

print "New video ID"
print "$user/$media_id"