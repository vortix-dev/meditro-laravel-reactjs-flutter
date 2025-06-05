import { useState } from "react";
import api from "../api/axios";
import { toast } from "react-toastify";
import { useNavigate } from "react-router-dom";

export default function Login() {
  const [data, setData] = useState({ email: "", password: "" });
  const navigate = useNavigate();

  const handleChange = (e) =>
    setData({ ...data, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await api.post("/login", data);

      // Get token and user info from response
      const { token, user } = res.data;

      // Save token and user in localStorage
      localStorage.setItem("token", token);
      localStorage.setItem("user", JSON.stringify(user));

      toast.success("Login successful");

      // Redirect user based on role
      if (user.role === "admin") {
        navigate("/admin/dashboard");
      } else if (user.role === "medecin") {
        navigate("/medecin/dashboard");
      } else if (user.role === "assistant") {
        navigate("/assistant/dashboard");
      } else if (user.role === "user") {
        navigate("/");
      }
    } catch (err) {
      const message =
        err.response?.data?.message || "Login failed, please try again";
      toast.error(message);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <h2>Login</h2>
      <input
        name="email"
        type="text"
        placeholder="Email"
        onChange={handleChange}
        required
      />
      <input
        name="password"
        type="password"
        placeholder="Password"
        onChange={handleChange}
        required
      />
      <button type="submit">Login</button>
    </form>
  );
}
