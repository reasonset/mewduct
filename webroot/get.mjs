const get = async function(url) {
  const res = await fetch(url)
  if (!res.ok) { throw(`fetch returns HTTP ${res.status}`) }
  return res.json()
}

const post = async function(url, body) {
  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  })
  if (!res.ok) { throw(`fetch returns HTTP ${res.status}`) }
  return res.json()
}

export {get, post}