import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]
  connect() {
    let enabled = true
    try { enabled = localStorage.getItem("jornaldm_motion") !== "paused" } catch {}
    this.apply(enabled)
  }
  toggle() {
    const enabled = document.documentElement.dataset.siteMotion !== "on"
    try { localStorage.setItem("jornaldm_motion", enabled ? "on" : "paused") } catch {}
    this.apply(enabled)
  }
  apply(enabled) {
    document.documentElement.dataset.siteMotion = enabled ? "on" : "paused"
    this.toggleTargets.forEach(button => {
      button.textContent = enabled ? "Ⅱ" : "▶"
      button.setAttribute("aria-pressed", String(!enabled))
      button.setAttribute("aria-label", enabled ? "Pausar animações" : "Ativar animações")
      button.title = enabled ? "Pausar animações" : "Ativar animações"
    })
    document.dispatchEvent(new CustomEvent("site-motion:change", {detail: {enabled}}))
  }
}
