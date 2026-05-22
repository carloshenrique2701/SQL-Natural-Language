document.addEventListener("DOMContentLoaded", function() {

    const user = JSON.parse(localStorage.getItem("User"));
    const userNameElement = document.getElementById("userName");
    const userEmailElement = document.getElementById("userEmail");
    if (user) {
        userNameElement.textContent = user.name;
        userEmailElement.textContent = user.email;
    }

});