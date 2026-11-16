import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { interval: { type: Number, default: 20000 } }

  connect() {
    this.active = true
    this.snapshots = new Map()
    this.dirtyForms = new WeakSet()
    this.regions().forEach(region => this.snapshots.set(region.id, this.snapshot(region)))
    this.onEdit = event => { if (event.target.form) this.dirtyForms.add(event.target.form) }
    this.onVisibility = () => { if (document.hidden) this.cancel(); else this.refresh() }
    this.onOnline = () => this.refresh()
    this.element.addEventListener("input", this.onEdit)
    this.element.addEventListener("change", this.onEdit)
    document.addEventListener("visibilitychange", this.onVisibility)
    window.addEventListener("online", this.onOnline)
    this.schedule()
  }

  disconnect() {
    this.active = false
    this.cancel()
    this.element.removeEventListener("input", this.onEdit)
    this.element.removeEventListener("change", this.onEdit)
    document.removeEventListener("visibilitychange", this.onVisibility)
    window.removeEventListener("online", this.onOnline)
  }

  intervalValueChanged() { if (this.snapshots) this.schedule() }
  regions(root = document) {
    return Array.from(root.querySelectorAll("[data-live-region][id]")).filter(region => !region.parentElement.closest("[data-live-region]"))
  }
  snapshot(region) {
    if (region.matches("[data-live-ticker]")) {
      return JSON.stringify(Array.from(region.querySelectorAll('.ticker-group:first-child a:not([aria-hidden="true"])'), link => [link.getAttribute("href"), link.textContent.trim()]))
    }
    const copy = region.cloneNode(true)
    copy.querySelectorAll('input[name="authenticity_token"]').forEach(input => input.remove())
    return copy.innerHTML
  }
  protected(region) {
    return region.contains(document.activeElement) || region.querySelector('dialog[open], [aria-busy="true"], button:disabled, input[type="submit"]:disabled') || Array.from(region.querySelectorAll("form")).some(form => this.dirtyForms.has(form))
  }
  schedule() {
    clearTimeout(this.timer)
    if (this.active && !document.hidden && this.regions().length) this.timer = setTimeout(() => this.refresh(), Math.max(500, this.intervalValue))
  }
  cancel() { clearTimeout(this.timer); clearTimeout(this.timeout); this.request?.abort() }

  async refresh() {
    if (!this.active) return
    if (this.loading || document.hidden || !navigator.onLine) { this.schedule(); return }
    this.loading = true
    const url = location.href
    this.request = new AbortController()
    this.timeout = setTimeout(() => this.request?.abort(), 10000)
    try {
      const response = await fetch(url, { headers: { "Accept": "text/html", "X-Live-Update": "true" }, credentials: "same-origin", cache: "no-store", signal: this.request.signal })
      if (!response.ok || response.redirected || location.href !== url) return
      const html = new DOMParser().parseFromString(await response.text(), "text/html")
      if (!html.querySelector("main#main-content")) return
      const changed = []
      for (const region of this.regions()) {
        const fresh = html.getElementById(region.id)
        if (!fresh?.matches("[data-live-region]") || this.protected(region)) continue
        const signature = this.snapshot(fresh)
        if (signature === this.snapshots.get(region.id)) continue
        fresh.querySelectorAll("script").forEach(script => script.remove())
        if (region.matches("[data-live-ticker]") && region.querySelectorAll(".ticker-group").length === 2 && fresh.querySelectorAll(".ticker-group").length === 2) {
          region.dispatchEvent(new CustomEvent("ticker:update", { detail: { element: fresh } }))
        } else {
          region.replaceWith(fresh)
        }
        this.snapshots.set(region.id, signature)
        changed.push(region.id)
      }
      if (changed.length) this.element.dispatchEvent(new CustomEvent("live-updates:refreshed", { bubbles: true, detail: { regions: changed } }))
    } catch (error) {
      // Network failures keep the current page intact; retry on the next cycle.
      if (error.name !== "AbortError") this.element.dispatchEvent(new CustomEvent("live-updates:retry"))
    } finally {
      clearTimeout(this.timeout)
      this.loading = false
      this.request = null
      this.schedule()
    }
  }
}
