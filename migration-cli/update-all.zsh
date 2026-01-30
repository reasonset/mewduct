_dir=${0:a:h}
webroot="$1"

cmddir=${_dir}/../cli
cmddir=${cmddir:a}
tigerdir=${cmddir}/../tigerroad/cli
tigerdir=${tigerdir:a}

if [[ -e "${cmddir}/mewduct-zsh-config.local.zsh" ]]
then
  source "${cmddir}/mewduct-zsh-config.local.zsh"
else
  source "${cmddir}/mewduct-zsh-config.zsh"
fi

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
    (( TIGERROAD_MODE > 0 )) && "$tigerdir/tigerroad-update.rb" "$webroot/media/$user_id/${media_media:t}/meta.json"
  done
  "$cmddir/mewduct-user.rb" update "$webroot" "$user_id"
  (( TIGERROAD_MODE > 0 )) && "$tigerdir/tigerroad-user.rb" "$webroot/user/$user_id"
done
"$cmddir/mewduct-home.rb" "$webroot"
(( TIGERROAD_MODE > 0 )) && "$tigerdir/tigerroad-home.rb" "$webroot"

true
