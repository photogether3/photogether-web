import { Controller } from "@hotwired/stimulus";

export class DropdownController extends Controller {
  static targets = ["dropdown"];

  connect() {
    this.element.addEventListener("click", this.toggleDropdown.bind(this));
  }

  toggleDropdown() {
    this.dropdownTargets.forEach((dropdown) => {
      dropdown.removeAttribute("open");
    });
  }
}
