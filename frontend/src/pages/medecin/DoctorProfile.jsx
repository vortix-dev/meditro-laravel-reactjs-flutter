import { useState, useEffect } from 'react';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';

function DoctorProfile() {
  const [profile, setProfile] = useState({ name: '', email: '' });
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
  });
  const [isLoading, setLoading] = useState(false);
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const id = user.id;

  useEffect(() => {
    const fetchProfile = async () => {
      setLoading(true);
      try {
        const response = await axios.get('http://localhost:8000/api/medecin/profile', {
          headers: { Authorization: `Bearer ${token}` },
        });
        const { name, email } = response.data.data;
        setProfile({ name, email });
        setFormData({ name, email, password: '', password_confirmation: '' });
      } catch (error) {
        console.error('Error fetching profile:', error.response);
        toast.error(error.response?.data?.message || 'Failed to load profile');
      } finally {
        setLoading(false);
      }
    };
    if (token) {
      fetchProfile();
    } else {
      console.error('No token found');
      toast.error('Please log in again');
    }
  }, [token]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const payload = {};
    if (formData.name && formData.name !== profile.name) {
      payload.name = formData.name;
    }
    if (formData.email && formData.email !== profile.email) {
      payload.email = formData.email;
    }
    if (formData.password) {
      payload.password = formData.password;
      payload.password_confirmation = formData.password_confirmation;
    }

    if (Object.keys(payload).length === 0) {
      toast.warning('No changes to save');
      return;
    }

    try {
      const response = await axios.put(`http://localhost:8000/api/medecin/profile-update/${id}`, payload, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const { name, email } = response.data.data;
      setProfile({ name, email });
      setFormData({ name, email, password: '', password_confirmation: '' });
      toast.success(response.data.message || 'Profile updated successfully!');
    } catch (error) {
      console.error('Error updating profile:', error.response);
      if (error.response?.status === 401) {
        toast.error('Unauthorized: Please log in again');
      } else if (error.response?.status === 422) {
        const errors = error.response.data.errors;
        Object.values(errors).forEach((err) => toast.error(err[0]));
      } else {
        toast.error(error.response?.data?.message || 'Failed to update profile');
      }
    }
  };

  if (isLoading) return <p className="text-center text-gray-600 pt-20">Loading...</p>;

  return (
    <div className="min-h-screen bg-gray-100 flex">
      <Sidebar />
      <div className="flex-1 container mx-auto px-4 pt-20 pb-16 ml-64">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-6 animate-fade-in">
          Doctor Profile
        </h2>
        <div className="max-w-md mx-auto bg-white shadow-lg rounded-lg p-6">
          <div className="mb-6">
            <h3 className="text-xl font-semibold text-gray-800 mb-2">Current Profile</h3>
            <p><strong>Name:</strong> {profile.name}</p>
            <p><strong>Email:</strong> {profile.email}</p>
          </div>
          <h3 className="text-xl font-semibold text-gray-800 mb-4">Update Profile</h3>
          <form onSubmit={handleSubmit}>
            <div className="mb-4">
              <label className="block text-gray-700">Name</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="w-full px-3 py-2 border rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="mb-4">
              <label className="block text-gray-700">Username</label>
              <input
                type="text"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                className="w-full px-3 py-2 border rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="mb-4">
              <label className="block text-gray-700">Password (Optional)</label>
              <input
                type="password"
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                className="w-full px-3 py-2 border rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Leave blank to keep current password"
              />
            </div>
            <div className="mb-4">
              <label className="block text-gray-700">Confirm Password</label>
              <input
                type="password"
                value={formData.password_confirmation}
                onChange={(e) => setFormData({ ...formData, password_confirmation: e.target.value })}
                className="w-full px-3 py-2 border rounded-full focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Confirm new password"
              />
            </div>
            <button type="submit" className="btn-primary w-full">
              Update Profile
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default DoctorProfile;