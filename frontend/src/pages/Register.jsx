import { useState } from "react";
import { useNavigate } from "react-router-dom";
import api from "../api/axios";
import { toast } from "react-toastify";

export default function Register() {
  const navigate = useNavigate();

  const [data, setData] = useState({
    name: "",
    email: "",
    password: "",
    password_confirmation: "",
    sexe: "Homme",
    address: "",
    telephone: "",
  });

  const handleChange = (e) => {
    setData({ ...data, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    try {
      const res = await api.post("/register", data);
      toast.success(res.data.message);

      setTimeout(() => {
        navigate("/login");
      }, 1000);
    } catch (err) {
      if (err.response?.status === 422) {
        const errors = err.response.data.errors;
        Object.values(errors).forEach((fieldErrors) => {
          fieldErrors.forEach((error) => toast.error(error));
        });
      } else {
        const message =
          err.response?.data?.message || "فشل التسجيل، تحقق من الحقول";
        toast.error(message);
      }
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input name="name" placeholder="الاسم" onChange={handleChange} />
      <input name="email" type="email" placeholder="البريد الإلكتروني" onChange={handleChange} />
      <input name="password" type="password" placeholder="كلمة السر" onChange={handleChange} />
      <input name="password_confirmation" type="password" placeholder="تأكيد كلمة السر" onChange={handleChange} />

      <select name="sexe" onChange={handleChange}>
        <option value="Homme">ذكر</option>
        <option value="Femme">أنثى</option>
      </select>

      <input name="address" placeholder="العنوان" onChange={handleChange} />
      <input name="telephone" placeholder="الهاتف" onChange={handleChange} />

      <button type="submit">تسجيل</button>
    </form>
  );
}
