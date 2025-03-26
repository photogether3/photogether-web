import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

    submit(e) {
        console.log(e);
        if (!e.detail.success) return;
        this.close();
    }

    close() {
        this.element.classList.add('motion-custom-fade-out');
        this.element.addEventListener('animationend', () => {
            this.element.remove();
        }, { once: true });
    }
}