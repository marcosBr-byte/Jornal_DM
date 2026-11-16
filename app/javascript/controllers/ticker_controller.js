import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track"]

  connect() {
    this.groups = Array.from(this.trackTarget.querySelectorAll(".ticker-group"))
    if (this.groups.length !== 2) return
    this.originals = Array.from(this.groups[0].children).filter(link => !link.hasAttribute("aria-hidden")).map(link => link.cloneNode(true))
    this.windowElement = this.element.querySelector(".ticker-window")
    this.motion = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.onMotionChange = () => this.layout()
    this.motion.addEventListener("change", this.onMotionChange)
    this.layout()
    this.resizeObserver = new ResizeObserver(() => this.layout())
    this.resizeObserver.observe(this.windowElement)
  }

  disconnect() { this.resizeObserver?.disconnect(); this.motion?.removeEventListener("change", this.onMotionChange) }

  update(event) {
    const next = event.detail.element.querySelector(".ticker-group")
    if (!next) return
    const offset = Math.abs(new DOMMatrix(getComputedStyle(this.trackTarget).transform).m41)
    this.originals = Array.from(next.children, link => link.cloneNode(true))
    this.layout()
    const width = this.groups[0].getBoundingClientRect().width
    const animation = this.trackTarget.getAnimations()[0]
    if (width && animation) {
      const duration = Math.max(12, width / 55) * 1000
      animation.currentTime = (offset % width) / width * duration
    }
  }

  layout() {
    this.groups.forEach((group, groupIndex) => {
      group.replaceChildren()
      const appendSet = duplicate => this.originals.forEach(original => {
        const link = original.cloneNode(true)
        if (duplicate || groupIndex > 0) {
          link.tabIndex = -1
          link.setAttribute("aria-hidden", "true")
        }
        group.append(link)
      })
      appendSet(false)
      const setWidth = group.getBoundingClientRect().width
      if (!setWidth) return
      const copies = Math.max(1, Math.ceil(this.windowElement.clientWidth / setWidth))
      for (let index = 1; index < copies; index++) appendSet(true)
    })
    const width = this.groups[0].getBoundingClientRect().width
    this.trackTarget.style.setProperty("--ticker-duration", `${Math.max(12, width / 55)}s`)
  }

  toggle(event) {
    const paused = this.trackTarget.classList.toggle("is-paused")
    event.currentTarget.textContent = paused ? "▶" : "Ⅱ"
    event.currentTarget.setAttribute("aria-pressed", String(paused))
    event.currentTarget.setAttribute("aria-label", paused ? "Retomar manchetes" : "Pausar manchetes")
  }
}
