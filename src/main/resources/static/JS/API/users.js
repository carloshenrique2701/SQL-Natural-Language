import { apiClient } from './client.js';

const token = localStorage.getItem("Token");

export async function newUser(user) {
    
    return apiClient('/users/sigin', {
        method: "POST",
        body: JSON.stringify(user)
    });
}

export async function checkEmailAndPassword(email, password) {
    
    return apiClient('/users/login', {
        method: "POST",
        headers: {
            Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({
            email: email,
            password: password
        })
    })

}

export async function userUpdate(id, user) {

    return apiClient(`/users/${id}`, {
        method: "PUT",
        headers: {
            Authorization: `Bearer ${token}`
        },
        body: JSON.stringify(user)
    });
}

export async function userUpdateProfile(id, profile) {
    return apiClient(`/users/${id}/profile`, {
        method: "PUT",
        headers: {
            Authorization: `Bearer ${token}`
        },
        body: JSON.stringify(profile)
    });
}

export async function userUpdatePassword(id, password) {
    return apiClient(`/users/${id}/password`, {
        method: "PUT",
        headers: {
            Authorization: `Bearer ${token}`
        },
        body: JSON.stringify({ password })
    });
}

export async function userUpdateCredentials(id, credentials) {
    return apiClient(`/users/${id}/db-credentials`, {
        method: "PUT",
        headers: {
            Authorization: `Bearer ${token}`
        },
        body: JSON.stringify(credentials)
    });
}

export async function deleteUser(id) {

    return apiClient(`/user/${id}`, {
        method: "DELETE",
        headers: {
            Authorization: `Bearer ${token}`
        }
    });
}
