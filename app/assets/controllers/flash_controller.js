import { Controller } from "@hotwired/stimulus";

export class FlashController extends Controller {
  connect() {
    console.log(this.element);

    setTimeout(() => {
      this.element.remove();
    }, 3000);
  }
}
