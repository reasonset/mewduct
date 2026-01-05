const PLYR_SCRIPT_CDN = "https://cdn.plyr.io/3.8.3/plyr.js"
const PLYR_CSS_CDN = "https://cdn.plyr.io/3.8.3/plyr.css"

const plyr_css = document.createElement("link")
plyr_css.rel = "stylesheet"
plyr_css.href = MEWDUCT_CONFIG.plyr_css_path || PLYR_CSS_CDN

document.head.appendChild(plyr_css)

const plyr_script = document.createElement("script")
plyr_script.src = MEWDUCT_CONFIG.plyr_script_path || PLYR_SCRIPT_CDN

plyr_script.addEventListener("load", mewduct)

document.head.appendChild(plyr_script)