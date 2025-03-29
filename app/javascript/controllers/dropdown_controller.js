import { Controller } from "@hotwired/stimulus";

export default class DropdownController extends Controller {
    select() {
        this.element.removeAttribute('open');
    }
}