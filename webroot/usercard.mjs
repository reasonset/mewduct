const createUserCard = function(user_meta) {
  const card = document.createElement("div")
  card.className = "user_card"
  const wrap_a = document.createElement("a")
  wrap_a.href = `/user.html/${user_meta.user_id}`
  const wrapped_div = document.createElement("div")
  wrapped_div.className = "user_card_wrapper"

  const img = document.createElement("img")
  img.src = `/user/${user_meta.user_id}/icon.webp`
  img.className = ".usericon"
  const username = document.createElement("span")
  username.appendChild(document.createTextNode(user_meta.username))
  username.className = "user_card_username"

  wrapped_div.appendChild(img)
  wrapped_div.appendChild(username)
  wrap_a.appendChild(wrapped_div)
  card.appendChild(wrap_a)

  return card
}

export {createUserCard}