import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import './CreateDoctor.css'; // تأكد من إنشاء هذا الملف

function CreateDoctor() {
  const [formData, setFormData] = useState({ service_id: '', name: '', email: '', password: '' });
  const [services, setServices] = useState([]);
  const navigate = useNavigate();
  const token = localStorage.getItem('token');

  useEffect(() => {
    const fetchServices = async () => {
      try {
        const response = await axios.get('http://localhost:8000/api/admin/services', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setServices(response.data.data);
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to fetch services');
      }
    };
    fetchServices();
  }, [token]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:8000/api/admin/medecins', formData, {
        headers: { Authorization: `Bearer ${token}` },
      });
      toast.success('Doctor created successfully!');
      navigate('/admin/doctors');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to create doctor');
    }
  };

  return (
    <div className="create-doctor-wrapper">
      <div className="container-create">
        <h2 className="title">Create New Doctor</h2>
        <div className="form-card">
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label>Service</label>
              <select
                value={formData.service_id}
                onChange={(e) => setFormData({ ...formData, service_id: e.target.value })}
                required
              >
                <option value="">Select Service</option>
                {services.map((service) => (
                  <option key={service.id} value={service.id}>
                    {service.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label>Name</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                required
              />
            </div>
            <div className="form-group">
              <label>Username</label>
              <input
                type="text"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                required
              />
            </div>
            <div className="form-group">
              <label>Password</label>
              <input
                type="password"
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                required
              />
            </div>
            <button type="submit" className="btn-submit">
              Create Doctor
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default CreateDoctor;
