import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["heart", "count", "message"]
  async like(event) {
    const button = event.currentTarget
    button.disabled = true
    try {
      const response = await fetch(button.dataset.url, {method: "POST", headers: {"X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "", "Accept": "application/json"}})
      if (!response.ok) throw new Error()
      const data = await response.json()
      this.countTarget.textContent = data.count
      this.heartTarget.textContent = data.liked ? "♥" : "♡"
      button.setAttribute("aria-pressed", String(data.liked))
      this.messageTarget.textContent = data.liked ? "Você curtiu esta notícia." : "Curtida retirada."
    } catch { this.messageTarget.textContent = "Não foi possível salvar. Aguarde e tente novamente." }
    finally { button.disabled = false }
  }
  async share() {
    try {
      if (navigator.share) await navigator.share({title: document.title, url: location.href})
      else { await navigator.clipboard.writeText(location.href); this.messageTarget.textContent = "Link copiado!" }
    } catch { this.messageTarget.textContent = "Compartilhe copiando o endereço desta página." }
  }
}
