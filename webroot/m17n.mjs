import { settings } from "/settings.mjs"

export function localizeMeta(meta) {
  let user_prefer = navigator.languages.map(i => i.split("-")[0])
  const settings_prefer = settings.prefer_language

  if (settings_prefer) {
    user_prefer = settings_prefer.concat(user_prefer)
  }

  const original = {
      title: meta.title,
      description: meta.description
  }

  if (user_prefer.includes(meta.lang) || !meta.translations) {
    // If the user can read the original language, prioritize it.
    return original
  } else {
    for (const i of user_prefer) {
      if (meta.translations[i]) {
        return {
          title: (meta.translations[i].title || original.title),
          description: (meta.translations[i].description || original.description)
        }
      }
    }

    return original
  }
}

export function getTitle(meta) {
  return localizeMeta(meta).title
}