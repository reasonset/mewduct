const form = document.getElementById("SettingsForm")
const gear = document.getElementById("SettingsGear")
const box = document.getElementById("SettingsScreen")
export let settings = {}

function initialize_settings() {
  const saved = localStorage.getItem("settings")
  if (saved) {
    settings = JSON.parse(saved)
  } else {
    settings = {}
  }
}

function update_form() {
  form.prefer_language.value = (settings.prefer_language || []).join(",")
}

function save_settings() {
  const new_settings = {}
  const lang_val = form.prefer_language.value
  if ((/^\s*$/).test(lang_val)) {
    new_settings.prefer_language = []
  } else {
    new_settings.prefer_language = Array.from(new Set((lang_val || "").split(/\s*,\s*/).map(i => i.toLowerCase().split("-")[0])))
  }

  localStorage.setItem("settings", JSON.stringify(new_settings))
  initialize_settings()
  hide_settings_modal()
}

form.addEventListener("submit", e => {
  e.preventDefault()
  save_settings()
  e.stopPropagation()
})

window.addEventListener("storage", e => {
  initialize_settings()
  update_form()
})

function show_settings_modal() {
  box.style.display = "block"
}

function hide_settings_modal() {
  box.style.display = ""
}

document.getElementById("SettingsBtnCancel").addEventListener("click", e => {
  hide_settings_modal()
  e.preventDefault()
})

gear.addEventListener("click", show_settings_modal)

initialize_settings()
update_form()