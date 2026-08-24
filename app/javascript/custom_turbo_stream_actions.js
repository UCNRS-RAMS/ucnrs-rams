import { Turbo } from "@hotwired/turbo-rails"

Turbo.StreamActions.set_value = function () {
  const value = this.getAttribute("value") || ""

  this.targetElements.forEach((element) => {
    element.value = value
  })
}
