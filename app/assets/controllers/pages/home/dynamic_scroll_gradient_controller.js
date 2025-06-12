// dynamic_scroll_gradient_controller.js
import { Controller } from "@hotwired/stimulus";

export class DynamicScrollGradientController extends Controller {
  // Stimulus 타겟 정의: HTML의 data-dynamic-scroll-gradient-target="이름"과 매칭됩니다.
  static targets = ["scrollBox", "leftGradient", "rightGradient"];

  connect() {
    // 컨트롤러가 연결되면 스크롤 이벤트 리스너를 추가합니다.
    this.scrollBoxTarget.addEventListener("scroll", this.updateGradientVisibility.bind(this));

    // 페이지 로드 시 초기 그라데이션 상태를 설정합니다.
    this.updateGradientVisibility();

    // 윈도우 리사이즈 시에도 그라데이션 상태를 업데이트합니다.
    // 디바운싱(debouncing)을 적용하여 성능을 최적화합니다.
    this.resizeTimer = null; // 타이머 변수 초기화
    window.addEventListener("resize", this.handleResize.bind(this));
  }

  // 컨트롤러가 연결 해제될 때 이벤트 리스너를 제거하여 메모리 누수를 방지합니다.
  disconnect() {
    this.scrollBoxTarget.removeEventListener("scroll", this.updateGradientVisibility.bind(this));
    window.removeEventListener("resize", this.handleResize.bind(this));
    clearTimeout(this.resizeTimer);
  }

  // 스크롤 위치에 따라 그라데이션의 가시성을 업데이트하는 메서드
  updateGradientVisibility() {
    const scrollLeft = this.scrollBoxTarget.scrollLeft;
    const scrollWidth = this.scrollBoxTarget.scrollWidth;
    const clientWidth = this.scrollBoxTarget.clientWidth;

    // 스크롤이 가장 왼쪽 끝에 있는지 확인
    const isAtStart = scrollLeft === 0;

    // 스크롤이 가장 오른쪽 끝에 있는지 확인
    // 부동소수점 오차를 고려하여 1픽셀 정도 여유를 둡니다.
    const isAtEnd = scrollLeft + clientWidth >= scrollWidth - 1;

    // 1. 스크롤이 왼쪽 끝에 붙어있으면 왼쪽 그라데이션 박스는 안 보이고 오른쪽 보이기
    if (isAtStart) {
      this.leftGradientTarget.style.opacity = '0';
      this.rightGradientTarget.style.opacity = '1';
    }
    // 3. 오른쪽 끝에 달라붙으면 왼쪽만 보이기
    else if (isAtEnd) {
      this.leftGradientTarget.style.opacity = '1';
      this.rightGradientTarget.style.opacity = '0';
    }
    // 2. 스크롤이 왼쪽 오른쪽 둘 다 닿지 않은 경우 둘 다 그라데이션 보이기
    else {
      this.leftGradientTarget.style.opacity = '1';
      this.rightGradientTarget.style.opacity = '1';
    }
  }

  // 리사이즈 이벤트 핸들러 (디바운싱 적용)
  handleResize() {
    clearTimeout(this.resizeTimer);
    this.resizeTimer = setTimeout(() => {
      this.updateGradientVisibility();
    }, 100); // 100ms 지연 후 실행
  }
}