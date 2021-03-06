import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["checkbox"];

  connect() {
    this.obligationId = this.data.get("id");
    this.isOwner = this.data.get("isOwner");
    this.checked = false;
    this.fadeTimeoutId = null;

    if (this.isOwner === "true") {
      this.channel = window.socket.channel(
        `obligation:${this.obligationId}`,
        {}
      );
      this.channel.join();

      this.channel.on("check_event", ({ image }) => {
        this.checkboxTarget.innerHTML = image;
      });
    }
  }

  toggle() {
    if (this.isOwner === "true") {
      this.checked = !this.checked;
      this.channel.push(`check:obligation:${this.obligationId}`, {
        checked: this.checked
      });

      if (this.checked === true) {
        this.element.classList.add("faded", "line-through");
        this.fadeTimeoutId = setTimeout(() => {
          this.element.parentNode.removeChild(this.element);
        }, 2000);
      } else {
        clearTimeout(this.fadeTimeoutId);
        this.fadeTimeoutId = null;
        this.element.classList.remove("faded", "line-through");
      }
    }
  }
}
