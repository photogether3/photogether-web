import { Controller } from "@hotwired/stimulus";

export class NotYetController extends Controller {
  connect() {
    // 초기 상태: 오른쪽에 위치 (화면 밖에서 시작)
    this.element.style.transform = "translateX(100%)";
    this.element.style.opacity = "0";
    this.element.style.transition = "transform 0.5s ease-in-out, opacity 0.5s ease-in-out";
    
    // 약간의 지연 후 화면에 나타남 (DOM이 업데이트될 시간을 줌)
    setTimeout(() => {
      // 화면 안으로 슬라이드 인
      this.element.style.transform = "translateX(0)";
      this.element.style.opacity = "1";
      
      setTimeout(() => {
        // 오른쪽으로 슬라이드 아웃
        this.element.style.transform = "translateX(100%)";
        this.element.style.opacity = "0";
        
        // 애니메이션 완료 후 요소 제거
        setTimeout(() => {
          this.element.remove();
        }, 500);
      }, 2000);
    }, 50);
  }
}