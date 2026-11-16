import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["slide", "dot", "pause", "status"]
  static values = {interval: {type: Number, default: 5000}}
  connect() {
    this.index = 0; this.manualPause = false; this.hovered = false; this.focused = false
    this.media = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.onMotion = () => this.start()
    this.onVisibility = () => document.hidden ? this.stop() : this.start()
    this.media.addEventListener("change", this.onMotion); document.addEventListener("visibilitychange", this.onVisibility)
    this.show(); this.start()
  }
  disconnect() { this.stop(); this.media.removeEventListener("change", this.onMotion); document.removeEventListener("visibilitychange", this.onVisibility) }
  start() { this.stop(); if (this.slideTargets.length > 1 && !this.manualPause && !this.hovered && !this.focused && !this.media.matches && !document.hidden) this.timer = setInterval(() => this.advance(1), this.intervalValue) }
  stop() { clearInterval(this.timer) }
  advance(direction) { this.index = (this.index + direction + this.slideTargets.length) % this.slideTargets.length; this.show() }
  show(announce = false) { this.slideTargets.forEach((slide, i) => {slide.hidden = i !== this.index}); this.dotTargets.forEach((dot, i) => dot.setAttribute("aria-current", String(i === this.index))); if (announce && this.hasStatusTarget) this.statusTarget.textContent = `Destaque ${this.index + 1} de ${this.slideTargets.length}` }
  next() { this.advance(1); this.show(true); this.start() }
  previous() { this.advance(-1); this.show(true); this.start() }
  go(event) { this.index = Number(event.currentTarget.dataset.index); this.show(true); this.start() }
  toggle() { this.manualPause = !this.manualPause; this.pauseTarget.textContent = this.manualPause ? "▶" : "Ⅱ"; this.pauseTarget.setAttribute("aria-pressed", String(this.manualPause)); this.pauseTarget.setAttribute("aria-label", this.manualPause ? "Retomar carrossel" : "Pausar carrossel"); this.start() }
  hoverPause() { this.hovered = true; this.stop() }
  hoverResume() { this.hovered = false; this.start() }
  focusPause() { this.focused = true; this.stop() }
  focusResume(event) { if (!this.element.contains(event.relatedTarget)) {this.focused = false; this.start()} }
  keyboard(event) { if (event.key === "ArrowRight") { event.preventDefault(); this.next() } else if (event.key === "ArrowLeft") { event.preventDefault(); this.previous() } }
}
