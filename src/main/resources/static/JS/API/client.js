const API_BASE_URL = "http://localhost:8080";

async function apiClient(endPoint, options = {}) {
    
    try {
        
        const response = await fetch(`${API_BASE_URL}${endPoint}`, {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        });

        const data = await response.json();

        if (!response.ok) throw new Error(data.message || `HTTP error! status: ${response.status}`);

        return data;

    } catch (error) {
        console.log("Internal server error: ", error);
    }

}

export { apiClient };