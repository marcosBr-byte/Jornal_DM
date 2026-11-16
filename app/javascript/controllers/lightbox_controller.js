import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["dialog", "image", "caption"]
  open(event) { this.imageTarget.src = event.currentTarget.dataset.src; this.imageTarget.alt = event.currentTarget.dataset.caption || "Fotografia da galeria"; this.captionTarget.textContent = event.currentTarget.dataset.caption || ""; this.dialogTarget.showModal() }
  close() { this.dialogTarget.close() }
}
