import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  check() {
    const email = this.element.value.trim();
    document.getElementById("email-check-result").textContent = "로딩 중..";

    if (email.length < 5) {
      document.getElementById("email-check-result").textContent = "";
      return;
    }

    fetch(`/users/check_email?email=${encodeURIComponent(email)}`, {
      headers: { Accept: "text/vnd.turbo-stream.html" }
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html));
  }
}
