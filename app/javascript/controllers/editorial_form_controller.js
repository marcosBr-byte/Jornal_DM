import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["environment", "category"]
  static values = {categories: Object}
  connect() { this.update() }
  update() {
    const selected = this.categoryTarget.value
    const choices = this.categoriesValue[this.environmentTarget.value] || []
    this.categoryTarget.replaceChildren(...choices.map(name => new Option(name, name)))
    if (choices.includes(selected)) this.categoryTarget.value = selected
  }
}
