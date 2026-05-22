document.getElementById("logOut").addEventListener("click", () => {

    localStorage.removeItem("Token");
    localStorage.removeItem("User");

    window.location.href = "../index.html";

});

document.addEventListener("DOMContentLoaded", () => {

    const userJson = localStorage.getItem("User");
    const user = userJson ? JSON.parse(userJson) : null;
    if (user) {
        document.getElementById("user-name").textContent = user.name;
    }
    
});