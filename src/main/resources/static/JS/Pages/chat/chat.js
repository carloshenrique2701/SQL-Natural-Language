document.getElementById("logOut").addEventListener("click", () => {

    localStorage.removeItem("Token");
    localStorage.removeItem("User");

    window.location.href = "/";

});

document.addEventListener("DOMContentLoaded", () => {

    const userJson = localStorage.getItem("User");
    const user = userJson ? JSON.parse(userJson) : null;
    console.log("User data from localStorage:", user); // Debugging log
    if (user) {
        document.getElementById("user-name").textContent = user.name;
        document.getElementById("db-name").textContent = user.dbName;
    }
    
});