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
            let errorMessage = response.statusText || `HTTP error! status: ${response.status}`;
            if (data) {
                if (typeof data === 'object' && data.message) {
                    errorMessage = data.message;
                } else if (typeof data === 'object' && data.res) {
                    errorMessage = data.res;
                } else if (typeof data === 'string') {
                    errorMessage = data;
                }
            }

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