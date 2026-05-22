import { apiClient } from './client.js';

export async function newUser(user) {
    // Endpoint correto no backend: POST /users/sigin
    return apiClient('/users/sigin', {
        method: "POST",
        body: JSON.stringify(user)
    });
}

export async function checkEmailAndPassword(email, password) {
    
    return apiClient('/users/login', {
        method: "POST",
        body: JSON.stringify({
            email: email,
            password: password
        })
    })

}

export async function userUpdate(id, user) {
    const token = localStorage.getItem("Token");

    return apiClient(`/users/${id}`, {
        method: "PUT",
        headers: {
            Authorization: `Bearer ${token}`
        },
        body: JSON.stringify(user)
    });
}

export async function deleteUser(id) {
    const token = localStorage.getItem("Token");

    return apiClient(`/user/${id}`, {
        method: "DELETE",
        headers: {
            Authorization: `Bearer ${token}`
        }
    });
}
