const API_BASE_URL = "http://localhost:8080";

async function apiClient(endPoint, options = {}) {
    try {
        const response = await fetch(`${API_BASE_URL}${endPoint}`, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            }
        });

        const rawBody = await response.text();
        let data = null;

        if (rawBody) {
            try {
                data = JSON.parse(rawBody);
            } catch {
                data = rawBody;
            }
        }

        if (!response.ok) {
            const errorMessage = (data && data.message) ? data.message : `HTTP error! status: ${response.status}`;
            const error = new Error(errorMessage);
            error.response = { status: response.status, data };
            throw error;
        }

        return data;
    } catch (error) {
        console.log("Internal server error: ", error);
        throw error;
    }
}

export { apiClient };