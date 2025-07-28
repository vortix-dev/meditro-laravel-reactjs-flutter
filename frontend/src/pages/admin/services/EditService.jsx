import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';

function EditService() {
  const { id } = useParams();
  const [formData, setFormData] = useState({ name: '', img: null });
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const token = localStorage.getItem('token');

  useEffect(() => {
    const fetchService = async () => {
      setLoading(true);
      try {
        const response = await axios.get(`http://localhost:8000/api/admin/services/${id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        setFormData({ name: response.data.data.name, img: null });
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to fetch service');
        navigate('/admin/services');
      } finally {
        setLoading(false);
      }
    };
    fetchService();
  }, [id, token, navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const data = new FormData();
    data.append('name', formData.name);
    if (formData.img) data.append('img', formData.img);
    data.append('_method', 'PUT');

    try {
      await axios.post(`http://localhost:8000/api/admin/services/${id}`, data, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'multipart/form-data',
        },
      });
      toast.success('Service updated successfully!');
      navigate('/admin/services');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to update service');
    }
  };

  if (loading) return <p className="loading-text">Loading...</p>;

  return (
    <div className="edit-service-page">
      <div className="edit-service-container">
        <h2 className="edit-service-title">Edit Service</h2>
        <div className="edit-service-form-wrapper">
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label>Service Name</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                required
              />
            </div>
            <div className="form-group">
              <label>Service Image (Optional)</label>
              <input
                type="file"
                accept="image/*"
                onChange={(e) => setFormData({ ...formData, img: e.target.files[0] })}
              />
            </div>
            <button type="submit" className="submit-btn">Update Service</button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default EditService;
