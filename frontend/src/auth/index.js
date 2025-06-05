export function isAuthenticated() {
  const token = localStorage.getItem("token");
  const user = localStorage.getItem("user");

  if (!token || !user) return null;

  try {
    return JSON.parse(user); // ← يجب أن يحتوي على .role
  } catch {
    return null;
  }
}
