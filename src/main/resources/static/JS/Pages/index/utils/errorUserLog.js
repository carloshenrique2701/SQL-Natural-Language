export function createMessage(message, isError) {
    
    const container = document.querySelector('.auth-card');
    const box = document.createElement('div');
    const span = document.createElement("span");
    span.textContent = message;
    box.appendChild(span);

    if (isError) {
        box.classList.add("error-box");
        box.classList.add("message-box");
    } else {
        box.classList.add("success-box");
        box.classList.add("message-box");
    }

    container.appendChild(box);

    setTimeout(() => {
        container.removeChild(box);
    }, 4000);

}