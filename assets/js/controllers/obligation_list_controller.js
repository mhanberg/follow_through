import { Controller } from "stimulus";
import Cond from "../utils/conditional-expressions";

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
    Cond.unless(this.obligationTargets.some(el => el.contains(target)), () =>
      this.unselectAll()
    );
  };

  select(event) {
    this.unselectAll();

    event.path
      .find(e => e.nodeName === "LI")
      .classList.add("obligation-selected");
  }
}
