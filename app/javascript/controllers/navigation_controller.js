import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["menu", "button"]
  toggle() {
    const open = this.menuTarget.classList.toggle("is-open")
    this.buttonTarget.setAttribute("aria-expanded", String(open))
    this.buttonTarget.textContent = open ? "× Fechar" : "☰ Menu"
  }
}
