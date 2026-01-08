import { get } from "/get.mjs"

async function mewduct() {
  const split_path = location.pathname.split("/")
  const user_id = split_path[2]
  const media_id = split_path[3]

  const sources = await get(`/media/${user_id}/${media_id}/sources.json`)
  const videometa = await get(`/media/${user_id}/${media_id}/meta.json`)
  const usermeta = await get(`/user/${user_id}/usermeta.json`)
  

  const title_elm = document.getElementById("VideoTitle")
  title_elm.appendChild(document.createTextNode(videometa.title))

  const un_elm = document.getElementById("UploadUser")
  const un_elm_a = document.createElement("a")
  un_elm_a.href = `/user.html/${user_id}`
  un_elm_a.appendChild(document.createTextNode(usermeta.username))
  un_elm.appendChild(un_elm_a)

  const ts_elm = document.getElementById("UploadTS")
  const uploaded_at = new Date(videometa.created_at * 1000)
  const time_elm = document.createElement("time")
  time_elm.datetime = uploaded_at.toISOString()
  time_elm.appendChild(document.createTextNode(uploaded_at.toLocaleString()))
  ts_elm.appendChild(document.createTextNode("Uploaded at: "))
  ts_elm.appendChild(time_elm)

  const desc_elm = document.getElementById("VideoDescriptionText")
  desc_elm.value = videometa.description || ""

  const plyr = new Plyr("#PlyrVideo")
  plyr.source = sources

}

mewduct()