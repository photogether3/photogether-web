// app/javascript/controllers/log_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["logContainer"]
  
  connect() {
    // 자동 새로고침 타이머 설정 (선택사항)
    // this.startAutoRefresh()
  }
  
  disconnect() {
    this.stopAutoRefresh()
  }
  
  refreshLogs() {
    // 현재 URL 파라미터 유지하면서 새로고침
    const currentParams = new URLSearchParams(window.location.search)
    
    // Turbo Stream 요청
    fetch(`${window.location.pathname}?${currentParams.toString()}`, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html)
      })
      .catch(error => {
        console.error("로그 새로고침 오류:", error)
      })
  }
  
  startAutoRefresh() {
    this.refreshInterval = setInterval(() => {
      this.refreshLogs()
    }, 10000) // 10초마다 자동 새로고침
  }
  
  stopAutoRefresh() {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval)
    }
  }
}