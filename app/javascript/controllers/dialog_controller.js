import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "dialogContainer"
  ]

  connect() {
    console.log("Dialog controller connected");
  }

  async open(event) {
    console.log("Dialog controller open");
    console.log(this.element);
    const url = event.target.dataset.url;
    console.log(url);
    console.log(this.dialogContainerTarget);

    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
      },
    })
      .then((response) => response.text())
      .then((html) => {
        console.log(html);
        this.dialogContainerTarget.innerHTML = html;
      });
  }
}
