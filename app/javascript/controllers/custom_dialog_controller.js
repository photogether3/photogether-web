import { Controller } from "@hotwired/stimulus";

/**
 * # 다이얼로그 컨트롤러 🧀
 * - 동적으로 다이얼로그를 열고 닫는 컨트롤러입니다.
 * - 백드롭, 다이얼로그 박스를 직접 생성합니다.
 * - 내부 랜더링 되는 컨텐츠는 서버에서 html/text로 받아옵니다.
 */
export default class extends Controller {
  static targets = [
    "dialogPortal", // 다이얼로그가 랜더링 되는 부모 엘리먼트
  ];

  static values = {
    url: String,
  };

  connect() {
    console.debug("CustomDialogController connected 🧀");
  }

  async open(event) {
    const url = event.target.dataset.url;
    if (!url) throw new Error("URL is required to open a dialog");

    const res = await fetch(url);
    if (!res.ok) throw new Error("Failed to fetch the content");

    const html = await res.text();

    this.dialogPortalTarget.innerHTML = html;
  }

  close() {
    const dialogEl = this.dialogPortalTarget;
    const dialogBackdrop = dialogEl.querySelector(".dialog");
    dialogBackdrop.classList.add("fade-out");

    dialogBackdrop.addEventListener(
      "animationend",
      () => {
        dialogEl.innerHTML = "";
      },
      { once: true }
    );
  }
}
