import { getTitle } from "/m17n.mjs"

export function createCard(meta) {
  const card = document.createElement("div")
  card.className = "video_card"
  const card_img = document.createElement("img")
  card_img.src = `/media/${meta.user}/${meta.media_id}/thumbnail.webp`
  card_img.loading = "lazy"
  const player_link = document.createElement("a")
  player_link.href = `/play.html/${meta.user}/${meta.media_id}`
  player_link.className = "video_card_link"
  player_link.appendChild(card_img)
  const card_title = document.createElement("div")
  card_title.className = "video_card_title"
  const title = getTitle(meta)
  card_title.appendChild(document.createTextNode(title))
  const card_meta = document.createElement("div")
  card_meta.className = "video_card_meta"
  const card_meta_user = document.createElement("span")
  card_meta_user.className = "video_card_user"
  card_meta_user.appendChild(document.createTextNode(meta.username))
  const user_link = document.createElement("a")
  user_link.href = `/user.html/${meta.user}`
  user_link.className = "user_link"
  user_link.appendChild(card_meta_user)
  const card_meta_date = document.createElement("span")
  card_meta_date.className = "video_card_date"
  const card_meta_date_time = document.createElement("time")
  const date = new Date(meta.created_at * 1000)
  card_meta_date_time.datetime = date.toISOString()
  card_meta_date_time.appendChild(document.createTextNode(date.toLocaleDateString()))
  card_meta_date.appendChild(card_meta_date_time)

  card_meta.appendChild(user_link)
  card_meta.appendChild(card_meta_date)

  card.appendChild(player_link)
  card.appendChild(card_title)
  card.appendChild(card_meta)

  return card
}