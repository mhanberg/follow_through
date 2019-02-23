import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["message"];

  connect() {
    this.messageTargets.forEach(m => {
      setTimeout(() => m.classList.add("slide-away"), 5000);
      setTimeout(() => m.parentNode.removeChild(m), 6000);
    });
  }
}
