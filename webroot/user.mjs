import { createCard } from "/cardbuilder.mjs"
import { get } from "/get.mjs"

const user = {}
const username = location.pathname.split("/")[2]

async function userpage() {
  try {
    const user_meta = await get(`/user/${username}/usermeta.json`)

    user.meta = user_meta
  } catch(e) {
    if (String(e) == "fetch returns HTTP 404") {
      const nosuch = document.getElementById("NoSuchUserName")
      nosuch.appendChild(document.createTextNode(username))
      document.getElementById("NoSuchUser").style.display = "block"
      return
    } else {
      throw e
    }
  }

  document.getElementById("UserBannerIcon").src = `/user/${username}/icon.webp`
  
  const username_box = document.getElementById("BannerUserName")
  username_box.appendChild(document.createTextNode(user.meta.username))

  if (user.meta.description) {
    const user_description = document.getElementById("UserDescriptionText")
    user_description.value = user.meta.description
  }

  const videos = await get(`/user/${username}/videos.json`)

  const box = document.getElementById("UserVideosBox")
  
  for (const meta of videos) {
    box.appendChild(createCard(meta))
  }
  
}

userpage()