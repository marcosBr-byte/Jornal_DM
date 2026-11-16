import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["image"]
  disconnect() { if (this.url) URL.revokeObjectURL(this.url) }
  show(event) {
    if (this.url) URL.revokeObjectURL(this.url)
    const file = event.target.files[0]
    this.imageTarget.hidden = !file
    if (file) { this.url = URL.createObjectURL(file); this.imageTarget.src = this.url }
  }
}
