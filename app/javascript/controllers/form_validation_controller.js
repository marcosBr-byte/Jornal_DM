import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  connect() {
    this.invalid = event => {
      const field = event.target
      if (!field.validity || field.validity.customError) return
      let message = "Confira o valor informado."
      if (field.validity.valueMissing) message = field.type === "checkbox" ? "Confirme esta opção para continuar." : "Preencha este campo."
      else if (field.validity.typeMismatch) message = field.type === "email" ? "Informe um e-mail válido." : "Informe um endereço válido."
      else if (field.validity.tooShort) message = `Use pelo menos ${field.minLength} caracteres.`
      else if (field.validity.tooLong) message = `Use no máximo ${field.maxLength} caracteres.`
      field.setCustomValidity(message)
    }
    this.clear = event => event.target.setCustomValidity?.("")
    this.element.addEventListener("invalid", this.invalid, true)
    this.element.addEventListener("input", this.clear)
    this.element.addEventListener("change", this.clear)
  }
  disconnect() { this.element.removeEventListener("invalid", this.invalid, true); this.element.removeEventListener("input", this.clear); this.element.removeEventListener("change", this.clear) }
}
