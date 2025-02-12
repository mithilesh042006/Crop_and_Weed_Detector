import axios from "axios";

/**
 * Create Axios instance with `withCredentials: true`
 * This allows automatic browser cookie handling.
 */
const API = axios.create({
  baseURL: "http://127.0.0.1:8000",
  withCredentials: true, // Ensures cookies are sent automatically
});

/**
 * Axios Interceptor: Logs every request.
 */
API.interceptors.request.use(
  (config) => {
    console.log("🚀 [REQUEST SENT]");
    console.log("🔹 URL:", config.url);
    console.log("🔹 Method:", config.method.toUpperCase());
    console.log("🔹 Headers:", config.headers);
    if (config.data) {
      console.log("🔹 Body:", config.data);
    }
    return config;
  },
  (error) => {
    console.error("❌ [REQUEST ERROR]", error);
    return Promise.reject(error);
  }
);

/**
 * Axios Interceptor: Logs every response.
 */
API.interceptors.response.use(
  (response) => {
    console.log("✅ [RESPONSE RECEIVED]");
    console.log("🔹 Status:", response.status);
    console.log("🔹 Data:", response.data);
    return response;
  },
  (error) => {
    console.error("❌ [RESPONSE ERROR]", error);
    if (error.response) {
      console.error("🔹 Status:", error.response.status);
      console.error("🔹 Data:", error.response.data);
    }
    return Promise.reject(error);
  }
);

// 🔹 GET tips (public or requires session).
export const fetchTipsAPI = async () => API.get("/api/tips");

// 🔹 Add tip (relies on session).
export const addTipAPI = async (data) => API.post("/admin_dashboard/add_tip", data);

// 🔹 Delete tip (relies on session).
export const deleteTipAPI = async (cropName) =>
  API.delete("/admin_dashboard/delete_tip", { data: { crop_name: cropName } });

export const fetchHistoryAPI = async () => API.get("/api/history");

export default API;
