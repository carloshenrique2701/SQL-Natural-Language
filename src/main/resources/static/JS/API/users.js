import { apiClient } from './client.js';

export async function newUser(user) {
    
    return apiClient('/users', {
        method: "POST",
        body: JSON.stringify( user )
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
    
    return apiClient(`/users/${id}`, {
        method: "PUT",
        body: JSON.stringify( user )
    });

}

export async function deleteUser(id) {
    
    return apiClient(`/user/${id}`, {
        method: "DELETE"
    });

}