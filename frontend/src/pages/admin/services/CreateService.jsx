import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';

function CreateService() {
  const [formData, setFormData] = useState({ name: '', img: null });
  const navigate = useNavigate();
  const token = localStorage.getItem('token');

  const handleSubmit = async (e) => {
    e.preventDefault();
    const data = new FormData();
    data.append('name', formData.name);
    if (formData.img) data.append('img', formData.img);

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
    <div className="pt-20 pb-16 min-h-screen bg-gray-100">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-6 animate-fade-in">
          Create New Service
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
              <label className="block text-gray-700">Service Image</label>
              <input
                type="file"
                accept="image/*"
                onChange={(e) => setFormData({ ...formData, img: e.target.files[0] })}
                className="w-full px-3 py-2 border-b border-gray-200"
                required
              />
            </div>
            <button type="submit" className="btn-primary w-full">
              Create Service
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default CreateService;