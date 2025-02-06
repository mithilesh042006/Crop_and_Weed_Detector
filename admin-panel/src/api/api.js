import axios from "axios";

/**
 * Create Axios instance with `withCredentials: true`
 * This allows automatic browser cookie handling for session & CSRF.
 */
const API = axios.create({
  baseURL: "http://127.0.0.1:8000",
  withCredentials: true, // 🔥 Ensures session cookies are sent automatically
});

/**
 * Get CSRF token from browser cookies.
 */
const getCsrfToken = () => {
  const value = `; ${document.cookie}`;
  const parts = value.split(`; csrftoken=`);
  if (parts.length === 2) return parts.pop().split(";").shift();
  return null;
};

/**
 * Attach CSRF token to headers if available.
 */
const attachCsrfToken = (headers = {}) => {
  const csrfToken = getCsrfToken();
  if (csrfToken) {
    headers["X-CSRFToken"] = csrfToken;
  }
  return headers;
};

/**
 * Axios Interceptor: Logs every request.
 */
API.interceptors.request.use((config) => {
  console.log("🚀 [REQUEST SENT]");
  console.log("🔹 URL:", config.url);
  console.log("🔹 Method:", config.method.toUpperCase());
  console.log("🔹 Headers:", config.headers);
  if (config.data) {
    console.log("🔹 Body:", config.data);
  }
  return config;
}, (error) => {
  console.error("❌ [REQUEST ERROR]", error);
  return Promise.reject(error);
});

/**
 * Axios Interceptor: Logs every response.
 */
API.interceptors.response.use((response) => {
  console.log("✅ [RESPONSE RECEIVED]");
  console.log("🔹 Status:", response.status);
  console.log("🔹 Data:", response.data);
  return response;
}, (error) => {
  console.error("❌ [RESPONSE ERROR]", error);
  if (error.response) {
    console.error("🔹 Status:", error.response.status);
    console.error("🔹 Data:", error.response.data);
  }
  return Promise.reject(error);
});

// 🔹 GET tips (public or requires session).
export const fetchTipsAPI = async () => {
  return API.get("/api/tips");
};

// 🔹 Add tip (relies on session + CSRF token).
export const addTipAPI = async (data) => {
  const headers = attachCsrfToken();
  return API.post("/admin_dashboard/add_tip", data, { headers });
};

// 🔹 Delete tip (relies on session + CSRF token).
export const deleteTipAPI = async (cropName) => {
  const headers = attachCsrfToken();
  return API.delete("/admin_dashboard/delete_tip", {
    data: { crop_name: cropName },
    headers,
  });
};

export default API;
