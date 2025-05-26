import { Controller } from "@hotwired/stimulus";

export class ModalController extends Controller {
  connect() {
    console.log(this.element);
    document.body.style.overflow = "hidden";
  }

  disconnect() {
    document.body.style.overflow = "auto";
  }

  onClose() {
    this.element.remove();  
  }
}
