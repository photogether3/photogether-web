import { Controller } from "@hotwired/stimulus";

/**
 * 조회에 관련된 헬퍼 클래스
 */
export default class extends Controller {
  static targets = ["order", "page"];
  static values = {
    debounce: { type: Number, default: 500 },
  };

  connect() {
    console.debug("QueryController connected");
    this.timeout = null;
  }

  search(event) {
    clearTimeout(this.timeout);

    // 디바운스 후 실행
    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, this.debounceValue);
  }

  toggleOrder(event) {
    const button = event.target;
    button.innerText = this.orderTarget.value === "asc" ? "최신순" : "오래된순";
    this.orderTarget.value = this.orderTarget.value === "asc" ? "desc" : "asc";

    this.element.requestSubmit();
  }

  changeOrderBy() {
    this.element.requestSubmit();
  }

  movePage(event) {
    const page = event.target.dataset.page;
    console.log(page);
    console.log(this.pageTarget.value);
    this.pageTarget.value = page;
    this.element.requestSubmit();
  }
}
