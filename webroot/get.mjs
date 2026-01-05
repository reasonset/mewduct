const get = async function(url) {
  const res = await fetch(url)
  if (!res.ok) { throw(`fetch returns HTTP ${res.status}`) }
  return res.json()
}

export {get}