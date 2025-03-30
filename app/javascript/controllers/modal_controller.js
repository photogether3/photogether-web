import { Controller } from "@hotwired/stimulus";

export default class ModalController extends Controller {
  static values = {
    refreshUrl: String,
  }

  connect() {
    // 모달이 열릴 때 body 스크롤 비활성화
    document.body.classList.add('overflow-hidden');
    
    // ESC 키로 모달 닫기
    this.boundKeyHandler = this.handleKeyPress.bind(this);
    document.addEventListener('keydown', this.boundKeyHandler);
  }

  disconnect() {
    // 모달이 닫힐 때 body 스크롤 다시 활성화
    document.body.classList.remove('overflow-hidden');
    
    // 이벤트 리스너 제거
    if (this.boundKeyHandler) {
      document.removeEventListener('keydown', this.boundKeyHandler);
    }
  }

  // ESC 키 누르면 모달 닫기
  handleKeyPress(event) {
    if (event.key === "Escape") {
      this.close();
    }
  }

  async submit(e) {
    const method =
      e.target.querySelector('input[name="_method"]')?.value?.toUpperCase() ||
      e.target.method?.toUpperCase();
    if (!e.detail.success) return;
    await this.close();

    // if (method !== 'POST') return;
    if (this.hasRefreshUrlValue) {
      Turbo.visit(this.refreshUrlValue);
    }
  }

  async close() {
    // 애니메이션 시작 전에 body 스크롤 다시 활성화
    document.body.classList.remove('overflow-hidden');
    
    // 이벤트 리스너 제거
    if (this.boundKeyHandler) {
      document.removeEventListener('keydown', this.boundKeyHandler);
    }
    
    this.element.classList.add("motion-custom-fade-out");
    return new Promise((resolve) => {
      this.element.addEventListener(
        "animationend",
        () => {
          this.element.remove();
          resolve();
        },
        { once: true }
      );
    });
  }
}