import { validateToken, clearAuth } from '../API/auth.js';

function redirectToLogin() {
    clearAuth();
    window.location.replace('/index.html');
}

async function checkAccessControl() {
    const token = localStorage.getItem('Token');
    
    if (!token) window.location.href = "../index.html";

    try {
        await validateToken(token);
    } catch (error) {
        redirectToLogin();
    }
}

window.addEventListener('load', checkAccessControl);

export default checkAccessControl;
