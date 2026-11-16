import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "icon", "label"]

  connect() {
    let dark = false
    try {
      const saved = localStorage.getItem("jornaldm_theme")
      dark = saved ? saved === "dark" : window.matchMedia("(prefers-color-scheme: dark)").matches
    } catch { dark = window.matchMedia("(prefers-color-scheme: dark)").matches }
    this.apply(dark)
    this.media = window.matchMedia("(prefers-color-scheme: dark)")
    this.onSystemChange = event => {
      let saved
      try { saved = localStorage.getItem("jornaldm_theme") } catch {}
      if (!saved) this.apply(event.matches)
    }
    this.media.addEventListener("change", this.onSystemChange)
  }

  disconnect() { this.media?.removeEventListener("change", this.onSystemChange) }

  toggle() {
    const dark = !document.documentElement.classList.contains("dark")
    this.apply(dark)
    try { localStorage.setItem("jornaldm_theme", dark ? "dark" : "light") } catch {}
  }

  apply(dark) {
    document.documentElement.classList.toggle("dark", dark)
    this.iconTargets.forEach((icon) => { icon.textContent = dark ? "☀" : "☾" })
    this.labelTargets.forEach((label) => { label.textContent = dark ? "Modo claro" : "Modo noturno" })
    this.toggleTargets.forEach((button) => {
      if (!button.querySelector('[data-theme-target~="icon"]')) {
        button.textContent = dark ? "☀" : "☾"
      }
      button.setAttribute("aria-pressed", String(dark))
      button.setAttribute("aria-label", dark ? "Ativar tema claro" : "Ativar tema escuro")
    })
  }
}
