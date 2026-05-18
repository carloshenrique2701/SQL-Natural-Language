document.getElementById("logOut").addEventListener("click", () => {

    localStorage.removeItem("Token");
    localStorage.removeItem("USer");

    window.location.href = "../index.html";

});

