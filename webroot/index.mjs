import { createCard } from "/cardbuilder.mjs"
import { get } from "/get.mjs"

//const fake_meta = {
//  user: "test",
//  media_id: "test",
//  username: "fooy",
//  title: "heyhey",
//  date: new Date()
//}

const box = document.getElementById("CardBox")
const index_meta = await get("/meta/index.json")

for (const meta of index_meta) {
  box.appendChild(createCard(meta))
}
