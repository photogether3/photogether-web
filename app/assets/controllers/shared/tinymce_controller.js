import { Controller } from "@hotwired/stimulus";

export class TinymceController extends Controller {
  connect() {
    // 이미 존재하는 인스턴스 제거 - 초기화 전에 항상 수행
    if (typeof tinymce !== "undefined" && tinymce.get("tinymce-editor")) {
      tinymce.get("tinymce-editor").remove();
    }
    
    // 이미 로드 중인지 확인
    if (this.isLoading) return;
    this.isLoading = true;
    
    // Turbo 페이지 이벤트 핸들러 등록
    document.addEventListener("turbo:before-render", this.cleanup);
    
    // 초기화 지연 적용 (10ms 정도만 지연)
    setTimeout(() => {
      this.initEditor();
      this.isLoading = false;
    }, 10);
  }
  
  disconnect() {
    document.removeEventListener("turbo:before-render", this.cleanup);
    this.cleanup();
  }
  
  cleanup = () => {
    try {
      if (typeof tinymce !== "undefined") {
        const editor = tinymce.get("tinymce-editor");
        if (editor) {
          // 내용 저장 후 제거
          const content = editor.getContent();
          const hiddenField = document.getElementById('policy_content_hidden');
          if (hiddenField) hiddenField.value = content;
          
          // 에디터 인스턴스 제거
          editor.remove();
          console.log("TinyMCE 에디터 인스턴스가 제거되었습니다.");
        }
      }
    } catch (error) {
      console.warn("TinyMCE 정리 중 오류:", error);
    }
  }
  
  initEditor() {
    tinymce.init({
      selector: "#tinymce-editor",
      // 핵심 플러그인만 로드하여 초기화 속도 향상
      plugins: [
        "anchor", "autolink", "charmap", "link", "lists", 
        "image", "media", "table", "emoticons"
      ],
      // 간소화된 툴바
      toolbar: "undo redo | blocks | bold italic | link image media table | numlist bullist | emoticons | removeformat",
      // 로딩 성능 개선을 위한 설정
      skin: "oxide",
      resize: true,
      min_height: 300,
      statusbar: false,
      menubar: false,
      branding: false,
      // 성능 개선을 위한 설정
      setup: function(editor) {
        editor.on('change', function() {
          // hidden 필드에 내용 동기화
          const hiddenField = document.getElementById('policy_content_hidden');
          if (hiddenField) hiddenField.value = editor.getContent();
        });
        
        // 초기화 완료 시 이벤트
        editor.on('init', function() {
          console.log('TinyMCE 초기화 완료');
        });
      }
    });
  }
}