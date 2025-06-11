import { Controller } from "@hotwired/stimulus";

export class StepActiveController extends Controller {
  static targets = ["step"];

  connect() {}

  changeStep(event) {
    this.stepTargets.forEach((step) => {
      step.classList.remove("border-primary");
      step.classList.add("border-[#A6A6A6]");
    });
    event.currentTarget.classList.remove("border-[#A6A6A6]");
    event.currentTarget.classList.add("border-primary");
  }
}
