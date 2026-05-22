import { sendMessage } from "../../API/genAi.js";

const sendBtn = document.getElementById("send-btn");
sendBtn.addEventListener("click", checkRequest);

document.addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
        checkRequest();
    }
});

async function checkRequest() {
    const requestInput = document.getElementById("user-request");
    const request = requestInput.value;

    if (request.length < 8) {
        return;
    }

    requestInput.value = "";

    let model = "gemini-2.5-flash";
    const genOptions = document.querySelectorAll(".gemini-option");
    genOptions.forEach((o) => {
        if (o.checked) {
            model = o.getAttribute("data-version");
        }
    });

    const token = localStorage.getItem("Token");
    const messages = document.getElementById("chat-messages");

    const userMessage = document.createElement("div");
    userMessage.className = "message user";
    userMessage.innerHTML = `
        <div class="msg-content">
            ${request}
        </div>
    `;
    messages.appendChild(userMessage);

    const aiMessage = document.createElement("div");
    aiMessage.className = "message ai";
    aiMessage.innerHTML = `
        <div class="loader">
          <div class="circle">
            <div class="dot"></div>
            <div class="outline"></div>
          </div>
          <div class="circle">
            <div class="dot"></div>
            <div class="outline"></div>
          </div>
          <div class="circle">
            <div class="dot"></div>
            <div class="outline"></div>
          </div>
          <div class="circle">
            <div class="dot"></div>
            <div class="outline"></div>
          </div>
        </div>
    `;
    messages.appendChild(aiMessage);

    try {
        const data = await sendMessage(request, model, token);
        const aiResponse = data?.res ?? "Erro: resposta inesperada do servidor.";

        aiMessage.innerHTML = `
            <div class="msg-content">
                ${aiResponse}
            </div>
        `;
    } catch (error) {
        const aiResponse = error?.response?.data?.res || error?.message || "Erro no servidor. Tente novamente.";

        aiMessage.innerHTML = `
            <div class="msg-content">
                ${aiResponse}
            </div>
        `;

        console.error("Erro ao enviar mensagem:", error);
    }
} 
