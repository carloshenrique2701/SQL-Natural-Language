import { apiClient } from './client.js';


export async function validateToken(token) {

  return apiClient('/auth/validate', {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${token}`
    }
  });
}

export async function getMe() {
  const token = localStorage.getItem("Token");

  return apiClient('/auth/me', {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${token}`
    }
  });
}

export function clearAuth() {
  localStorage.removeItem("Token");
  localStorage.removeItem("User");
}

