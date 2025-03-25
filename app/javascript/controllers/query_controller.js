import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['keyword', 'pagination']

    static values = {
        debounceTime: { default: 500 }
    }

    connect() {
        console.log('query controller connected')
    }

    search(event) {
        clearTimeout(this.debounceId)
        this.debounceId = setTimeout(() => {
            this.#submit({ resetPage: true })
            document.addEventListener("turbo:load", () => {
                const input = document.querySelector("input[name='keyword']")
                input.focus()
                input.setSelectionRange(input.value.length, input.value.length)
            }, { once: true })
        }, this.debounceTimeValue)
    }

    changeOrder() {
        this.#submit({ resetPage: true })
    }

    changeOrderBy() {
        this.#submit({ resetPage: true })
    }

    goToPage(event) {
        const page = event.target.dataset.pageNumber
        this.#submit({ overridePage: page })
    }

    async #submit({ resetPage = false, overridePage = null } = {}) {
        const formData = new FormData(this.element)
        const url = new URL(this.element.action)

        for (const [key, value] of formData.entries()) {
            url.searchParams.set(key, value)
        }

        if (overridePage !== null) {
            url.searchParams.set("page", overridePage)
        } else if (resetPage) {
            url.searchParams.set("page", "1")
        }

        history.pushState({}, "", url)

        const response = await fetch(url.toString(), {
            method: "GET",
            headers: {
                Accept: "text/vnd.turbo-stream.html"
            }
        })

        if (response.ok) {
            const streamHtml = await response.text()
            window.Turbo.renderStreamMessage(streamHtml)
        }
    }
}
