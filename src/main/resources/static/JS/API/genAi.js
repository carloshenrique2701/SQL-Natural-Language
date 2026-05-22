import { apiClient } from './client.js';

export async function sendMessage(message, option, token) {
    if (!token) {
        throw new Error('Token de autenticação não encontrado. Faça login novamente.');
    }

    const authHeader = token.startsWith('Bearer ') ? token : `Bearer ${token}`;

    return apiClient('/api/genai', {
        method: 'POST',
        headers: {
            Authorization: authHeader
        },
        body: JSON.stringify({
            userQuery: message,
            model: option
        })
    });
}
