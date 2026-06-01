export function createMessage(message, isError) {
    
    const messageElement = document.getElementById("message");
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

    messageElement.appendChild(box);

    setTimeout(() => {
        messageElement.removeChild(box);
    }, 5000);

}