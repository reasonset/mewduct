const createCard = function(meta) {
  const card = document.createElement("div")
  card.className = "video_card"
  const card_img = document.createElement("img")
  card_img.src = `/media/${meta.user}/${meta.media_id}/thumbnail.webp`
  const card_title = document.createElement("div")
  card_title.className = "video_card_title"
  card_title.appendChild(document.createTextNode(meta.title))
  const card_meta = document.createElement("div")
  card_meta.className = "video_card_meta"
  const card_meta_user = document.createElement("span")
  card_meta_user.className = "video_card_user"
  card_meta_user.appendChild(document.createTextNode(meta.username))
  const card_meta_date = document.createElement("span")
  card_meta_date.className = "video_card_date"
  const card_meta_date_time = document.createElement("time")
  card_meta_date_time.datetime = meta.date.toISOString()
  card_meta_date_time.appendChild(document.createTextNode(meta.date.toLocaleDateString()))
  card_meta_date.appendChild(card_meta_date_time)

  card_meta.appendChild(card_meta_user)
  card_meta.appendChild(card_meta_date)

  card.appendChild(card_img)
  card.appendChild(card_title)
  card.appendChild(card_meta)

  return card
}

export {createCard}