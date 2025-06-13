import { Controller } from "@hotwired/stimulus";

export class LottieController extends Controller {
  static values = {
    fileName: String,
  };

  connect() {
    if (!this.hasFileNameValue) {
      this.fileNameValue = "onb1";
    }

    lottie.loadAnimation({
      container: this.element, // the dom element that will contain the animation
      renderer: "svg",
      loop: true,
      autoplay: true,
      path: `/lotties/${this.fileNameValue}.json`, // the path to the animation json
    });
  }
}
