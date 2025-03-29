import { Controller } from "@hotwired/stimulus";

export default class ModalController extends Controller {
  static values = {
    refreshUrl: String,
  }
  connect() {
    console.log(this.refreshUrlValue);
  }

  async submit(e) {
    const method =
      e.target.querySelector('input[name="_method"]')?.value?.toUpperCase() ||
      e.target.method?.toUpperCase();
    if (!e.detail.success) return;
    await this.close();

    // if (method !== 'POST') return;
    Turbo.visit(this.refreshUrlValue);
  }

  async close() {
    this.element.classList.add("motion-custom-fade-out");
    return new Promise((resolve) => {
      this.element.addEventListener(
        "animationend",
        () => {
          this.element.remove();
          resolve();
        },
        { once: true }
      );
    });
  }
}
