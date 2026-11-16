import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["status"]
  start() { this.statusTarget.hidden = false }
  finish() { this.statusTarget.hidden = true }
}
