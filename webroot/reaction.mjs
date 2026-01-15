import { get, post } from "/http.mjs"

async function reaction_setup() {
  if (MEWDUCT_CONFIG.reaction_post_to) {
    const reactions = document.getElementsByClassName("reaction_button")
    const reaction_box = document.getElementById("VideoReaction")
    const reaction_count = document.getElementById("LikeCount")
    reaction_box.style.display = "block"

    const split_path = location.pathname.split("/")
    const user_id = split_path[2]
    const media_id = split_path[3]

    let reaction_sent = false

    const send_reaction = async function(body) {
      if (reaction_sent) { return }
      reaction_sent = true

      try {
        await post(MEWDUCT_CONFIG.reaction_post_to, body)
      } catch(e) {
        console.error("POST reaction failed.")
        console.error(e)
      }

      const lovebox = document.createElement("div")
      lovebox.className = "lovebox"
      lovebox.appendChild(document.createTextNode("✨️💖"))

      reaction_box.innerHTML=""
      reaction_box.appendChild(lovebox)
      reaction_box.appendChild(reaction_count)
    }

    for (const i of reactions) {
      const react_data = {
        user_id: user_id,
        media_id: media_id,
        reaction: i.dataset.reactiontype,
        negative: (i.dataset.negative == "yes")
      }

      i.addEventListener("click", e => {
        send_reaction(react_data)
      })
    }

    if (MEWDUCT_CONFIG.reaction_get_from) {
      reaction_count.style.display = "inline-block"
      const params = new URLSearchParams()
      params.append("user_id", user_id)
      params.append("media_id", media_id)
      const res = await get(MEWDUCT_CONFIG.reaction_get_from + "?" + params)

      if (res.count || res.count === 0) {
        reaction_count.appendChild(document.createTextNode(res.count))
      }
    }

    if (MEWDUCT_CONFIG.enable_negative_reaction) {
      const nr = document.getElementById("NegativeReaction")
      nr.style.display = "inline-block"
    }
  }
}

reaction_setup()