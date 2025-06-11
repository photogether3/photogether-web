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
    this.element.classList.add("motion-opacity-out-0");

    this.element.addEventListener('animationend', () => {
      this.element.remove();
    }, { once: true });
  }

  // 오버레이 클릭 처리
  onOverlayClick(event) {
    if (event.target === this.element) {
      this.onClose();
    }
  }

  // 모달 클릭 시 이벤트 전파 방지
  onModalClick(event) {
    event.stopPropagation();
  }
}