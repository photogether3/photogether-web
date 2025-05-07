// app/javascript/controllers/log_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["logContainer"]
  
  connect() {
    // console.log("Log controller connected")
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
}