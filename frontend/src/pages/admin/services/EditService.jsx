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

  if (loading) return <p className="text-center text-gray-600 pt-20">Loading...</p>;

  return (
    <div className="pt-20 pb-16 min-h-screen bg-gray-100">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-6 animate-fade-in">
          Edit Service
        </h2>
        <div className="max-w-md mx-auto bg-white shadow-lg rounded-lg p-6">
          <form onSubmit={handleSubmit}>
            <div className="mb-4">
              <label className="block text-gray-700">Service Name</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-3 py-2 border rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>
            <div className="mb-4">
              <label className="block text-gray-700">Service Image (Optional)</label>
              <input
                type="file"
                accept="image/*"
                onChange={(e) => setFormData({ ...formData, img: e.target.files[0] })}
                className="w-full px-3 py-2 border-b border-gray-200"
              />
            </div>
            <button type="submit" className="btn-primary w-full">
              Update Service
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default EditService;