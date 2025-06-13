import { Controller } from "@hotwired/stimulus";

export class MobileGuideController extends Controller {
  static targets = ["indicator", "stepBoxContainer", "mobileFrame"];

  static values = {
    currentStep: Number,
    totalSteps: Number,
    platform: String, // 모바일용인지 데스크탑용인지 구분
  };

  connect() {
    console.log(this.mobileFrameTarget);
    if (this.hasIndicatorTarget) {
      this.#onChangeIndicator();
    }

    this.#onChangeStepBox();
    this.#onChangeFrame();
  }

  /** ----------------------------------------------------------
   * onPrevStep, onNextStep
   * -----------------------------------------------------------
   * 동시에 여러 상태를 바꿈
   * - 모바일 프레임 내의 페이지
   * - 스텝박스 상태 변화
   * - 닷 인디게이터 상태 변화
   * ----------------------------------------------------------*/

  /**
   * 모바일용
   */
  async onPrevStep() {
    if (this.currentStepValue === 1) {
      return;
    }
    this.currentStepValue -= 1;

    if (this.hasIndicatorTarget) {
      this.#onChangeIndicator();
    }

    this.#onChangeStepBoxByMobilePlatform();
    this.#onChangeFrame();
  }

  /**
   * 모바일용
   */
  onNextStep() {
    if (this.currentStepValue === this.totalStepsValue) {
      return;
    }
    this.currentStepValue += 1;

    if (this.hasIndicatorTarget) {
      this.#onChangeIndicator();
    }

    this.#onChangeStepBoxByMobilePlatform();
    this.#onChangeFrame();
  }

  /**
   * 데스크탑용
   */
  onClickStep(event) {
    if (this.platformValue === "mobile") {
      return;
    }

    const step = event.currentTarget.dataset.step;
    this.currentStepValue = step;

    this.#onChangeStepBoxByDesktopPlatform();
    this.#onChangeFrame();
  }

  /**
   * 모바일 프레임 내의 페이지 변경
   */
  #onChangeFrame() {
    // 2025-06-13: 해당 방법은 랜딩페이지처럼 정적 콘텐츠를 랜더링 방법으로는 적절하지 않은것 같음
    // (서버를 한번 찍고 오니 비교적 더 느린게 채감이됨)
    // 이 방식은 url까지 변경시킴. 현재 내 요구사항을 만족하지 않음
    // 찾아보니 해당 방식은 turbo drive 방식으로 페이지까지 변경하는 기능이 맞음
    // Turbo.visit(`mobile-frame-step?step=${this.currentStepValue}`, {
    //   action: "replace",
    //   frame: "mobile_frame_step"
    // });

    // 해당 방식이 자바스크립트에서 터보 프레임을 업데이트하는 방식
    // const turboFrame = this.mobileFrameTarget.querySelector("turbo-frame");
    // turboFrame.src = `mobile-frame-step?step=${this.currentStepValue}`;

    // html에 미리 페이지들을 모두 그려놓고 css로 토글하는 방식 사용
    let index = this.currentStepValue - 1;
    this.mobileFrameTarget.childNodes.forEach((e, i) => {
      if (i === index) {
        e.classList.remove("hidden");
      } else {
        e.classList.add("hidden");
      }
    });
  }

  /**
   * 플랫폼에 따라 스텝박스 업데이트 방식 변경
   */
  #onChangeStepBox() {
    if (this.platformValue === "mobile") {
      this.#onChangeStepBoxByMobilePlatform();
    } else {
      this.#onChangeStepBoxByDesktopPlatform();
    }
  }

  /**
   * 스텝박스의 상태 변경 (모바일용)
   */
  #onChangeStepBoxByMobilePlatform() {
    let index = this.currentStepValue - 1;
    this.stepBoxContainerTarget.childNodes.forEach((e, i) => {
      if (i === index) {
        e.classList.remove("hidden", "border-[#A6A6A6]");
        e.classList.add("border-primary");
      } else {
        e.classList.remove("border-primary");
        e.classList.add("hidden", "border-[#A6A6A6]");
      }
    });
  }

  /**
   * 스텝박스의 상태 변경 (데스크탑용)
   */
  #onChangeStepBoxByDesktopPlatform() {
    let index = this.currentStepValue - 1;
    this.stepBoxContainerTarget.querySelectorAll(".step-box").forEach((e, i) => {
      if (i === index) {
        e.classList.remove("border-[#A6A6A6]");
        e.classList.add("border-primary");
      } else {
        e.classList.remove("border-primary");
        e.classList.add("border-[#A6A6A6]");
      }
    });
  }

  /**
   * 인디게이터 상태 변경 (모바일용)
   */
  #onChangeIndicator() {
    let index = this.currentStepValue - 1;
    this.indicatorTarget.childNodes.forEach((e, i) => {
      if (i === index) {
        e.classList.remove("w-[5px]", "bg-[#515867]");
        e.classList.add("w-[12px]", "bg-primary");
      } else {
        e.classList.remove("w-[12px]", "bg-primary");
        e.classList.add("w-[5px]", "bg-[#515867]");
      }
    });
  }
}
