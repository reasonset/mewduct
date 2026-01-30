########## Encoding parameters ##########
# Value of -reserve_index_space in WebM video.
typeset RESERVE_INDEX_SPACE_SIZE=96k

# Bitrate mapping for shorter side pixels to ffmpeg -b:v
# The values defined as keys for this map become candidates for the short-side size.
typeset -A map_bv=(
  320 300k
  360 300k
  426 500k
  480 500k
  576 700k
  640 800k
  720 1100k
  1080 1600k
#  2160 3000k
)

# Logic for generating media_id. By default, uuidgen is used to generate a UUIDv4.
create_media_id() {
  print ${$(uuidgen):l}
}

# Disable/Enable Mewduct Tigerroad
# 0: Disable Mewduct Tigerroad
# 1: Enable Mewduct Tigerroad with "coexistence" mode
# 2: Same as 1, but output the homepage to index.html and overwrite Mewduct.
typeset -i TIGERROAD_MODE=0
