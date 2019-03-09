import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["window", "icon", "form", "formContainer"];

  connect() {
    this.open = false;
    fetch(this.data.get("url"))
      .then(r => r.text())
      .then(html => {
        this.element.innerHTML = html;
      });
  }

  submit(event) {
    event.preventDefault();

    const data = new FormData(this.formTarget);

    fetch(this.formTarget.action, {
      method: this.formTarget.method,
      body: data
    })
      .then(r => r.text())
      .then(html => {
        this.formContainerTarget.innerHTML = html;
      });
  }

  toggleWindow() {
    this.windowTarget.classList.toggle("hidden");
    this.open = !this.open;

    if (this.open) {
      this.iconTarget.innerHTML = `<svg class="h-10 w-10 fill-blue-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z"/></svg>`;
    } else {
      this.iconTarget.innerHTML = `<svg class="h-12 w-12 bg-white rounded-full fill-blue-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M10 20a10 10 0 1 1 0-20 10 10 0 0 1 0 20zm2-13c0 .28-.21.8-.42 1L10 9.58c-.57.58-1 1.6-1 2.42v1h2v-1c0-.29.21-.8.42-1L13 9.42c.57-.58 1-1.6 1-2.42a4 4 0 1 0-8 0h2a2 2 0 1 1 4 0zm-3 8v2h2v-2H9z"/></svg>`;
    }
  }
}
