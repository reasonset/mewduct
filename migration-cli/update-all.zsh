_dir=${0:a:h}
webroot="$1"

cmddir=${_dir}/../cli
cmddir=${cmddir:a}

if [[ ! -d "$webroot" ]]
then
  print update-all.zsh "<webroot>" >&2
  exit 1
fi

for media_user in "$webroot/media"/*
do
  user_id=${media_user:t}
  for media_media in "$media_user"/*
  do
    "$cmddir/mewduct-update.rb" "$webroot" "$user_id" "${media_media:t}"
  done
  "$cmddir/mewduct-user.rb" update "$webroot" "$user_id"
done
"$cmddir/mewduct-home.rb" "$webroot"
