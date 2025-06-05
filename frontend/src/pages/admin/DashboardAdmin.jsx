import { useEffect, useState } from "react";
import { toast } from "react-toastify";
import api from "../../api/axios";

export default function AdminDashboard() {
  const [services, setServices] = useState([]);
  const [medecins, setMedecins] = useState([]);
  const [assistants, setAssistants] = useState([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(null);

  // تحميل البيانات
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [servicesRes, medecinsRes, assistantsRes] = await Promise.all([
          api.get("/admin/services"),
          api.get("/admin/medecins"),
          api.get("/admin/assistance"),
        ]);
        setServices(servicesRes.data.data);
        setMedecins(medecinsRes.data.data);
        setAssistants(assistantsRes.data.data);
      } catch (error) {
        const message = error.response?.data?.message || "فشل تحميل البيانات";
        setLoadError(message);
        toast.error(message);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  // دالة عامة للحذف
  const handleDelete = async (type, id, setState) => {
    if (!window.confirm("هل أنت متأكد من الحذف؟")) return;
    try {
      const response = await api.delete(`/admin/${type}/${id}`);
      setState((prev) => prev.filter((item) => item.id !== id));
      toast.success(response.data?.message || "تم الحذف بنجاح");
    } catch (error) {
      toast.error(error.response?.data?.message || "فشل الحذف");
    }
  };

  if (loading) return <p>جاري تحميل لوحة التحكم...</p>;
  if (loadError) return <p style={{ color: "red" }}>{loadError}</p>;

  return (
    <div>
      <h1>لوحة تحكم المسؤول</h1>

      {/* الخدمات */}
      <section>
        <h2>الخدمات</h2>
        {services.length === 0 ? (
          <p>لا توجد خدمات.</p>
        ) : (
          <table border="1" cellPadding="5" cellSpacing="0">
            <thead>
              <tr>
                <th>ID</th>
                <th>الاسم</th>
                <th>الصورة</th>
                <th>إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {services.map((service) => (
                <tr key={service.id}>
                  <td>{service.id}</td>
                  <td>{service.name}</td>
                  <td>
                    {service.img ? (
                      <img
                        src={`${import.meta.env.VITE_API_URL}/storage/${service.img}`}
                        alt={service.name}
                        width={50}
                      />
                    ) : (
                      "لا توجد صورة"
                    )}
                  </td>
                  <td>
                    <button
                      onClick={() =>
                        handleDelete("services", service.id, setServices)
                      }
                    >
                      حذف
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      {/* الأطباء */}
      <section>
        <h2>الأطباء</h2>
        {medecins.length === 0 ? (
          <p>لا يوجد أطباء.</p>
        ) : (
          <table border="1" cellPadding="5" cellSpacing="0">
            <thead>
              <tr>
                <th>ID</th>
                <th>رقم الخدمة</th>
                <th>الاسم</th>
                <th>البريد</th>
                <th>إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {medecins.map((medecin) => (
                <tr key={medecin.id}>
                  <td>{medecin.id}</td>
                  <td>{medecin.service_id}</td>
                  <td>{medecin.name}</td>
                  <td>{medecin.email}</td>
                  <td>
                    <button
                      onClick={() =>
                        handleDelete("medecins", medecin.id, setMedecins)
                      }
                    >
                      حذف
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>

      {/* المساعدين */}
      <section>
        <h2>المساعدون</h2>
        {assistants.length === 0 ? (
          <p>لا يوجد مساعدين.</p>
        ) : (
          <table border="1" cellPadding="5" cellSpacing="0">
            <thead>
              <tr>
                <th>ID</th>
                <th>الاسم</th>
                <th>البريد</th>
                <th>إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {assistants.map((assistant) => (
                <tr key={assistant.id}>
                  <td>{assistant.id}</td>
                  <td>{assistant.name}</td>
                  <td>{assistant.email}</td>
                  <td>
                    <button
                      onClick={() =>
                        handleDelete("assistance", assistant.id, setAssistants)
                      }
                    >
                      حذف
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </section>
    </div>
  );
}
