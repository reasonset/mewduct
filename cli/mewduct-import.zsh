#!/bin/zsh
setopt EXTENDED_GLOB

_dir=${0:a:h}
if [[ -e "${_dir}/mewduct-zsh-config.local.zsh" ]]
then
  source "${_dir}/mewduct-zsh-config.local.zsh"
else
  source "${_dir}/mewduct-zsh-config.zsh"
fi

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
  media_id=$(create_media_id)
done

video_imported="$webroot/media/$user/$media_id"
mv -v "$videodir" "$video_imported"

$_dir/mewduct-update.rb "${webroot:a}" "$user" "$media_id"
$_dir/mewduct-user.rb update "${webroot:a}" "$user"
$_dir/mewduct-home.rb "${webroot:a}"

if (( TIGERROAD_MODE >= 2 ))
then
  export TIGERROAD_INDEX_FILENAME="index.html"
fi

if (( TIGERROAD_MODE > 0 ))
then
  ${_dir:h}/tigerroad/cli/tigerroad-update.rb "${webroot:a}/$user/$media_id/meta.json"
  ${_dir:h}/tigerroad/cli/tigerroad-user.rb "${webroot:a}/user/$user"
  ${_dir:h}/tigerroad/cli/tigerroad-home.rb "${webroot:a}"
fi

print "New video ID"
print "$user/$media_id"
