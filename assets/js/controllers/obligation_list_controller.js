import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["obligation"];

  connect() {
    window.addEventListener("click", this.onOutsideClick);
  }

  unselectAll() {
    this.obligationTargets.forEach(obligation => {
      obligation.classList.remove("obligation-selected");
    });
  }

  onOutsideClick = ({ target }) => {
    if (!this.obligationTargets.every(el => el.contains(target))) {
      this.unselectAll();
    }
  };

  select(event) {
    this.unselectAll();

    event.path
      .find(e => e.nodeName === "LI")
      .classList.add("obligation-selected");
  }
}
