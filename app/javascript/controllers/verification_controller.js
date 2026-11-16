import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  connect() { this.timer = setTimeout(() => this.element.remove(), 1400) }
  disconnect() { clearTimeout(this.timer) }
}
