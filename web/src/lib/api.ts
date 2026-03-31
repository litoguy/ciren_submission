const BASE_URL = import.meta.env.VITE_API_URL;

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}

export interface ChatResponse {
  reply: string;
  sessionId?: string;
  isGuest: boolean;
}

export interface Topic {
  id: string;
  label: string;
  icon: string;
  prompt: string;
}

export interface FAQ {
  id: number;
  question: string;
}

class ApiClient {
  private getSessionId(): string | null {
    return sessionStorage.getItem("X-Session-ID");
  }

  private setSessionId(id: string) {
    sessionStorage.setItem("X-Session-ID", id);
  }

  private getAuthToken(): string | null {
    return localStorage.getItem("accessToken");
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${BASE_URL}${endpoint}`;
    const headers = new Headers(options.headers || {});
    
    if (!headers.has("Content-Type")) {
      headers.set("Content-Type", "application/json");
    }

    const sessionId = this.getSessionId();
    if (sessionId) {
      headers.set("X-Session-ID", sessionId);
    }

    const token = this.getAuthToken();
    if (token) {
      headers.set("Authorization", `Bearer ${token}`);
    }

    const response = await fetch(url, { ...options, headers });
    
    // Handle session ID from headers
    const newSessionId = response.headers.get("X-Session-ID");
    if (newSessionId) {
      this.setSessionId(newSessionId);
    }

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || "An error occurred");
    }

    return data;
  }

  async postChat(message: string): Promise<ApiResponse<ChatResponse>> {
    return this.request<ApiResponse<ChatResponse>>("/api/chat", {
      method: "POST",
      body: JSON.stringify({ message }),
    });
  }

  async getTopics(): Promise<ApiResponse<{ topics: Topic[] }>> {
    return this.request<ApiResponse<{ topics: Topic[] }>>("/api/topics");
  }

  async getFAQs(): Promise<ApiResponse<{ faqs: FAQ[] }>> {
    return this.request<ApiResponse<{ faqs: FAQ[] }>>("/api/faqs");
  }

  async getHistory(): Promise<ApiResponse<{ history: any[] }>> {
    return this.request<ApiResponse<{ history: any[] }>>("/api/chat/history");
  }

  async clearHistory(): Promise<ApiResponse<{ message: string }>> {
    return this.request<ApiResponse<{ message: string }>>("/api/chat/history", {
      method: "DELETE",
    });
  }
}

export const api = new ApiClient();
