import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

    static targets = ['modal'];

    connect() {
        console.log('modal controller connected!');
    }

    async open(event) {
        const url = event.target.dataset.url;
        if (!url) throw new Error('url이 필요합니다.');

        const response = await fetch(url, {
            method: 'GET',
            headers: {
                Accept: "text/vnd.turbo-stream.html"
            }
        });
        if (!response.ok) throw new Error('무언가 잘못되었어요.');

        const streamHtml = await response.text();
        console.log(streamHtml);
        window.Turbo.renderStreamMessage(streamHtml);
    }

    close() {
        console.log(this.modalTarget);
        this.modalTarget.classList.add('motion-custom-fade-out');
        this.modalTarget.addEventListener('animationend', () => {
            this.modalTarget.remove();
        }, { once: true });
    }
}