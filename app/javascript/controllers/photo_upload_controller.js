import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
export default class extends Controller {
  static targets = ["camera", "gallery", "preview", "progress", "message", "submit"]
  connect() { this.files = []; this.urls = [] }
  disconnect() { this.urls.forEach(URL.revokeObjectURL) }
  camera() { this.cameraTarget.click() }
  gallery() { this.galleryTarget.click() }
  select(event) {
    for (const file of event.target.files) {
      if (this.files.length >= 8) { this.messageTarget.textContent = "Selecione até 8 imagens."; break }
      if (!['image/jpeg', 'image/png', 'image/webp'].includes(file.type) || file.size > 10 * 1024 * 1024) { this.messageTarget.textContent = "Use JPEG, PNG ou WebP de até 10 MB."; continue }
      this.files.push(file)
    }
    event.target.value = ""
    this.render()
  }
  render() {
    this.urls.forEach(URL.revokeObjectURL); this.urls = []
    this.previewTarget.replaceChildren()
    this.files.forEach((file, index) => {
      const figure = document.createElement("figure"), img = document.createElement("img"), button = document.createElement("button")
      const url = URL.createObjectURL(file); this.urls.push(url); img.src = url; img.alt = file.name
      button.type = "button"; button.textContent = "Remover"; button.className = "dm-link"; button.setAttribute("aria-label", `Remover ${file.name}`)
      button.addEventListener("click", () => {this.files.splice(index, 1); this.render()})
      figure.append(img, button); this.previewTarget.append(figure)
    })
  }
  submit(event) {
    event.preventDefault(); event.stopImmediatePropagation()
    if (!this.files.length) { this.messageTarget.textContent = "Selecione ao menos uma fotografia."; return }
    const data = new FormData(event.target)
    this.files.forEach(file => data.append("images[]", file))
    this.submitTarget.disabled = true; this.progressTarget.hidden = false
    const xhr = new XMLHttpRequest()
    xhr.open("POST", event.target.action)
    xhr.setRequestHeader("Accept", "application/json")
    xhr.setRequestHeader("X-CSRF-Token", document.querySelector('meta[name="csrf-token"]')?.content || "")
    xhr.upload.onprogress = e => { if (e.lengthComputable) this.progressTarget.value = e.loaded / e.total * 100 }
    const failed = () => { this.submitTarget.disabled = false; this.messageTarget.textContent = "Não foi possível enviar. Confira os arquivos e a conexão e tente novamente." }
    xhr.onerror = failed
    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 300) { this.files = []; Turbo.visit(JSON.parse(xhr.responseText).redirect) }
      else {
        failed()
        try { this.messageTarget.textContent = JSON.parse(xhr.responseText).error || this.messageTarget.textContent } catch {}
      }
    }
    xhr.send(data)
  }
}
