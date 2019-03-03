import { Controller } from "stimulus";
import Cond from "../utils/conditional-expressions";

export default class extends Controller {
  static targets = ["obligation"];

  connect() {
    window.addEventListener("click", this.onOutsideClick);
    const emptyState = document.createElement("div");
    emptyState.classList.add("text-grey-400", "pl-4");
    emptyState.appendChild(document.createTextNode("No current obligations"));

    this.observer = new MutationObserver(() => {
      if (this.element.children.length === 0) {
        this.element.parentNode.appendChild(emptyState);
        this.element.parentNode.removeChild(this.element);
      }
    });

    this.observer.observe(this.element, { childList: true });
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

    event.currentTarget.classList.add("obligation-selected");
  }

  disconnect() {
    window.removeEventListener("click", this.onOutsideClick);
    this.observer.disconnect();
  }
}
