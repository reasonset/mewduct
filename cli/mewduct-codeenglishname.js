const data = JSON.parse(require('fs').readFileSync(0, "utf8"))

const result = []
for (const i of data) {
  result.push({
    kind: "captions",
    label: new Intl.DisplayNames([i.code], {type: "language"}).of(i.code),
    srclang: i.code,
    src: i.srcpath
  })
}

console.log(JSON.stringify(result))