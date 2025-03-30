import { Controller } from "@hotwired/stimulus";

export default class LogController extends Controller {
  static targets = ["logContainer"];

  refreshLogs() {
    const url = new URL(window.location.href);
    fetch(`${url.pathname}${url.search}`, {
      headers: { Accept: "text/vnd.turbo-stream.html" },
    })
      .then((response) => response.text())
      .then((html) => {
        Turbo.renderStreamMessage(html);
      });
  }
}
