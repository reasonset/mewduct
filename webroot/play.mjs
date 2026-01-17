import { localizeMeta } from "/m17n.mjs"
import { get } from "/http.mjs"

async function mewduct() {
  const split_path = location.pathname.split("/")
  const user_id = split_path[2]
  const media_id = split_path[3]

  const sources = await get(`/media/${user_id}/${media_id}/sources.json`)
  const videometa = await get(`/media/${user_id}/${media_id}/meta.json`)
  const usermeta = await get(`/user/${user_id}/usermeta.json`)
  
  const local_meta = localizeMeta(videometa)

  const title_elm = document.getElementById("VideoTitle")
  title_elm.appendChild(document.createTextNode(local_meta.title))

  const un_elm = document.getElementById("UploadUser")
  const un_elm_a = document.createElement("a")
  un_elm_a.href = `/user.html/${user_id}`
  un_elm_a.appendChild(document.createTextNode(usermeta.username))
  un_elm.appendChild(un_elm_a)

  const uicon_elm = document.getElementById("UploadUserIcon")
  uicon_elm.src = `/user/${user_id}/icon.webp`

  const ts_elm = document.getElementById("UploadTS")
  const uploaded_at = new Date(videometa.created_at * 1000)
  const time_elm = document.createElement("time")
  time_elm.datetime = uploaded_at.toISOString()
  time_elm.appendChild(document.createTextNode(uploaded_at.toLocaleString()))
  ts_elm.appendChild(document.createTextNode("Uploaded at: "))
  ts_elm.appendChild(time_elm)

  const desc_elm = document.getElementById("VideoDescriptionText")
  desc_elm.value = local_meta.description || ""

  const plyr = new Plyr("#PlyrVideo", {
    mediaMetadata: {
      title: sources.title,
      artist: usermeta.username
    }
  })
  plyr.source = sources

  if (MEWDUCT_CONFIG.player_additional_1) {
    const box = document.getElementById("PlayerAdditionalSection1")
    box.innerHTML = MEWDUCT_CONFIG.player_additional_1
  }

  if (MEWDUCT_CONFIG.player_additional_2) {
    const box = document.getElementById("PlayerAdditionalSection2")
    box.innerHTML = MEWDUCT_CONFIG.player_additional_2
  }
}

mewduct()