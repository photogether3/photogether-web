import { Controller } from "@hotwired/stimulus";

export class TinymceController extends Controller {
  connect() {
    tinymce.init({
      selector: "#tinymce-editor",
      plugins: [
        // Core editing features
        "anchor",
        "autolink",
        "charmap",
        "codesample",
        "emoticons",
        "image",
        "link",
        "lists",
        "media",
        "searchreplace",
        "table",
        "visualblocks",
        "wordcount",
        // Your account includes a free trial of TinyMCE premium features
        // Try the most popular premium features until Jun 5, 2025:
        "checklist",
        "mediaembed",
        "casechange",
        "formatpainter",
        "pageembed",
        "a11ychecker",
        "tinymcespellchecker",
        "permanentpen",
        "powerpaste",
        "advtable",
        "advcode",
        "editimage",
        "advtemplate",
        "mentions",
        "tinycomments",
        "tableofcontents",
        "footnotes",
        "mergetags",
        "autocorrect",
        "typography",
        "inlinecss",
        "markdown",
        "importword",
        "exportword",
        "exportpdf",
      ],
      toolbar:
        "undo redo | blocks fontfamily fontsize | bold italic underline strikethrough | link image media table mergetags | addcomment showcomments | spellcheckdialog a11ycheck typography | align lineheight | checklist numlist bullist indent outdent | emoticons charmap | removeformat",
      tinycomments_mode: "embedded",
      tinycomments_author: "Author name",
      mergetags_list: [
        { value: "First.Name", title: "First Name" },
        { value: "Email", title: "Email" },
      ],
      // ai_request: (request, respondWith) => respondWith.string(() => Promise.reject('See docs to implement AI Assistant')),
      setup: function(editor) {
        editor.on('change', function() {
          // hidden 필드에 내용 동기화
          document.getElementById('policy_content_hidden').value = editor.getContent();
        });
      }
    });
  }

  disconnect() {
    // 컨트롤러 해제 시 TinyMCE 인스턴스 정리
    if (typeof tinymce !== "undefined") {
      // 특정 에디터 인스턴스만 정리
      const editor = tinymce.get("tinymce-editor");
      if (editor) {
        editor.remove();
        console.log("TinyMCE 에디터 인스턴스가 제거되었습니다.");
      }

      // 또는 모든 인스턴스 정리가 필요한 경우
      // tinymce.remove('#tinymce-editor');
    }
  }
}
