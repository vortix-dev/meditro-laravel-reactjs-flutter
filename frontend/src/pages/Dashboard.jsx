import api from "../api/axios";
import { toast } from "react-toastify";
import { useNavigate } from "react-router-dom";

export default function Dashboard() {
  const navigate = useNavigate();

  const logout = async () => {
    try {
      await api.post("/logout"); // تأكد من وجود هذا الـ route في Laravel
      localStorage.removeItem("token");
      toast.success("تم تسجيل الخروج");
      navigate("/login");
    } catch {
      toast.error("فشل تسجيل الخروج");
    }
  };

  return (
    <div>
      <h1>لوحة التحكم</h1>
      <button onClick={logout}>خروج</button>
    </div>
  );
}
