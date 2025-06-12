import { Controller } from "@hotwired/stimulus";

export class FlashController extends Controller {
  connect() {
    setTimeout(() => {
      this.element.remove();
    }, 3000);
  }
}
