import { Controller } from "@hotwired/stimulus"

export default class PostFormController extends Controller {
  static targets = ["metadataContainer"]
  
  connect() {
    this.removedImageIds = [];
    this.metadataItems = [];
    this.urlRegex = /(https?:\/\/[^\s]+)/g;
  }
  
  // 단일 이미지 미리보기
  previewImage(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    const reader = new FileReader();
    const preview = document.getElementById('image-preview');
    const previewImg = preview.querySelector('img');
    
    reader.onload = e => {
      previewImg.src = e.target.result;
      preview.classList.remove('hidden');
      
      // 이미지가 로드되면 자동으로 텍스트 인식 버튼을 찾아 클릭
      const extractButton = preview.querySelector('button[data-action="click->post-form#extractTextFromImage"]');
      if (extractButton) {
        // 약간의 지연 후 텍스트 인식 실행 (이미지가 완전히 로드되도록)
        setTimeout(() => {
          this.extractTextFromImage({ currentTarget: extractButton });
        }, 500);
      }
    };
    
    reader.readAsDataURL(file);
  }
  
  clearPreview() {
    const preview = document.getElementById('image-preview');
    const fileInput = document.querySelector('input[type="file"][name="post[image]"]');
    
    preview.classList.add('hidden');
    fileInput.value = '';
  }
  
  extractTextFromImage(event) {
    const button = event.currentTarget;
    const fileInput = document.querySelector('input[type="file"][name="post[image]"]');
    const file = fileInput.files[0];
    
    if (!file) {
      alert('먼저 이미지를 업로드해주세요.');
      return;
    }
    
    // 로딩 상태 표시
    button.innerHTML = `
      <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      처리 중...
    `;
    
    const formData = new FormData();
    formData.append('file', file);
    
    fetch('/admin/images/extract_text', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: formData
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('텍스트 인식에 실패했습니다.');
      }
      return response.json();
    })
    .then(data => {
      // 메타데이터 컨테이너 초기화
      this.initializeMetadataContainer();
      
      // 인식된 각 라인에 대해 메타데이터 항목 생성
      if (data.lines && data.lines.length > 0) {
        data.lines.forEach(line => {
          this.addMetadataItemFromText(line);
        });
      } else {
        // 인식된 텍스트가 없을 때
        this.showNoTextDetectedMessage();
      }
      
      // 버튼 상태 복원
      button.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4">
          <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
        </svg>
        텍스트 인식 완료
      `;
      button.classList.remove('bg-blue-500', 'hover:bg-blue-600');
      button.classList.add('bg-green-500', 'hover:bg-green-600');
    })
    .catch(error => {
      console.error('Error:', error);
      // 오류 표시
      button.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z" />
        </svg>
        실패
      `;
      button.classList.remove('bg-blue-500', 'hover:bg-blue-600');
      button.classList.add('bg-red-500', 'hover:bg-red-600');
    });
  }
  
  initializeMetadataContainer() {
    const container = document.getElementById('metadata-container');
    if (container) {
      container.innerHTML = '';
    }
    
    // 메타데이터 섹션 제목 표시
    const metadataSection = document.getElementById('metadata-section');
    if (metadataSection) {
      metadataSection.classList.remove('hidden');
    }
  }
  
  showNoTextDetectedMessage() {
    const container = document.getElementById('metadata-container');
    if (container) {
      const message = document.createElement('div');
      message.className = 'p-4 text-center text-gray-500 rounded-lg bg-gray-50';
      message.textContent = '이미지에서 텍스트를 인식하지 못했습니다.';
      container.appendChild(message);
    }
  }
  
  addMetadataItemFromText(text) {
    const container = document.getElementById('metadata-container');
    if (!container) return;
    
    const items = container.querySelectorAll('.metadata-item');
    const newIndex = items.length + 1;
    
    // URL 패턴 탐지
    const hasUrl = this.urlRegex.test(text);
    // 정규식 초기화 (global 플래그 때문에 필요)
    this.urlRegex.lastIndex = 0;
    
    const newItem = document.createElement('div');
    newItem.className = 'p-4 mb-2 border border-gray-200 metadata-item rounded-xl';
    newItem.innerHTML = `
      <div class="flex justify-between mb-2">
        <h4 class="font-medium">메타데이터 항목 #${newIndex}</h4>
        <button type="button" class="text-gray-400 hover:text-red-500" data-action="click->post-form#removeMetadataItem">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
          </svg>
        </button>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="flex flex-col gap-1 md:col-span-3">
          <label class="text-xs text-gray-500">내용</label>
          <input type="text" name="post[metadata][][content]" value="${text}" class="border border-gray-300 p-2 rounded-lg" placeholder="내용 입력" data-action="input->post-form#checkForUrl">
        </div>
        <div class="flex items-center gap-2 md:col-span-2">
          <input type="checkbox" name="post[metadata][][isPublic]" id="metadata_public_${newIndex}" class="rounded" checked>
          <label for="metadata_public_${newIndex}" class="text-sm">공개</label>
        </div>
        <div class="flex items-center gap-2 md:col-span-1">
          <input type="checkbox" name="post[metadata][][hasLink]" id="metadata_link_${newIndex}" class="rounded" ${hasUrl ? 'checked' : ''}>
          <label for="metadata_link_${newIndex}" class="text-sm">링크 포함</label>
          ${hasUrl ? '<span class="ml-1 text-xs text-green-600">URL 감지됨</span>' : ''}
        </div>
      </div>
    `;
    
    container.appendChild(newItem);
  }
  
  checkForUrl(event) {
    const input = event.target;
    const item = input.closest('.metadata-item');
    const text = input.value;
    const linkCheckbox = item.querySelector('input[name="post[metadata][][hasLink]"]');
    const linkLabel = linkCheckbox.nextElementSibling.nextElementSibling;
    
    // URL 패턴 탐지
    const hasUrl = this.urlRegex.test(text);
    // 정규식 초기화
    this.urlRegex.lastIndex = 0;
    
    linkCheckbox.checked = hasUrl;
    
    // URL 감지 표시
    if (hasUrl) {
      if (!linkLabel) {
        const span = document.createElement('span');
        span.className = 'ml-1 text-xs text-green-600';
        span.textContent = 'URL 감지됨';
        linkCheckbox.nextElementSibling.after(span);
      }
    } else {
      if (linkLabel) {
        linkLabel.remove();
      }
    }
  }
  
  addMetadataItem() {
    this.addMetadataItemFromText('');
  }
  
  removeMetadataItem(event) {
    const item = event.target.closest('.metadata-item');
    if (item) {
      item.remove();
      
      // 남은 항목들의 번호 다시 매기기
      const items = document.querySelectorAll('.metadata-item');
      items.forEach((item, index) => {
        const titleElement = item.querySelector('h4');
        if (titleElement) {
          titleElement.textContent = `메타데이터 항목 #${index + 1}`;
        }
      });
    }
  }
  
  removeImage(event) {
    event.preventDefault();
    const button = event.currentTarget;
    const imageId = button.dataset.imageId;
    const preview = button.closest('.relative');
    
    // 이미지 삭제 요청 전송
    if (imageId && confirm('이미지를 삭제하시겠습니까?')) {
      fetch(`/admin/posts/${this.getPostId()}/remove_image`, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Content-Type': 'application/json'
        }
      })
      .then(response => {
        if (response.ok) {
          const preview = button.closest('.relative.group');
          if (preview) preview.remove();
        } else {
          alert('이미지 삭제에 실패했습니다.');
        }
      })
      .catch(error => {
        console.error('Error:', error);
        alert('이미지 삭제 중 오류가 발생했습니다.');
      });
    }
  }
  
  getPostId() {
    const form = document.getElementById('post_form');
    const action = form.getAttribute('action');
    const matches = action.match(/\/admin\/posts\/(\d+)/);
    return matches ? matches[1] : null;
  }
}