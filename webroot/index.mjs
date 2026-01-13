import { createCard } from "/cardbuilder.mjs"
import { createUserCard } from "/usercard.mjs"
import { get } from "/http.mjs"

const box = document.getElementById("CardBox")
const index_meta = await get("/meta/index.json")

for (const meta of index_meta) {
  box.appendChild(createCard(meta))
}

const user_box = document.getElementById("UsersBox")
const users_meta = await get("/meta/users.json")

for (const meta of users_meta) {
  user_box.appendChild(createUserCard(meta))
}