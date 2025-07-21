import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import './CreateService.css'; // تأكد من ربط ملف CSS

function CreateService() {
  const [formData, setFormData] = useState({ name: '', img: null });
  const navigate = useNavigate();
  const token = localStorage.getItem('token');

  const handleSubmit = async (e) => {
    e.preventDefault();
    const data = new FormData();
    data.append('name', formData.name);

    try {
      await axios.post('http://localhost:8000/api/admin/services', data, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'multipart/form-data',
        },
      });
      toast.success('Service created successfully!');
      navigate('/admin/services');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to create service');
    }
  };

  return (
    <div className="services-page">
      <div className="container">
        <h2 className="page-title">Create New Service</h2>
        <div className="table-container" style={{ maxWidth: '500px', margin: '0 auto' }}>
          <form onSubmit={handleSubmit}>
            <div className="mb-4">
              <label className="block-label">Service Name</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="input-field"
                required
              />
            </div>
            <button type="submit" className="btn-primary w-full">Create Service</button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default CreateService;
