// DoctorProfile.jsx
import { useState, useEffect } from 'react';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';
import './DoctorProfile.css'; // Ensure this file exists for styling

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
        toast.error(error.response?.data?.message || 'Failed to load profile');
      } finally {
        setLoading(false);
      }
    };
    if (token) fetchProfile();
    else toast.error('Please log in again');
  }, [token]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const payload = {};
    if (formData.name !== profile.name) payload.name = formData.name;
    if (formData.email !== profile.email) payload.email = formData.email;
    if (formData.password) {
      payload.password = formData.password;
      payload.password_confirmation = formData.password_confirmation;
    }
    if (Object.keys(payload).length === 0) return toast.warning('No changes to save');

    try {
      const response = await axios.put(`http://localhost:8000/api/medecin/profile-update/${id}`, payload, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const { name, email } = response.data.data;
      setProfile({ name, email });
      setFormData({ name, email, password: '', password_confirmation: '' });
      toast.success(response.data.message || 'Profile updated successfully!');
    } catch (error) {
      if (error.response?.status === 401) toast.error('Unauthorized: Please log in again');
      else if (error.response?.status === 422) {
        const errors = error.response.data.errors;
        Object.values(errors).forEach((err) => toast.error(err[0]));
      } else toast.error(error.response?.data?.message || 'Failed to update profile');
    }
  };

  if (isLoading) return <p className="loading-text">Loading...</p>;

  return (
    <div className="doctor-profile-page">
      <Sidebar />
      <div className="content">
        <h2 className="title">Doctor Profile</h2>
        <div className="profile-card">
          <div className="current-profile">
            <h3>Current Profile</h3>
            <p><strong>Name:</strong> {profile.name}</p>
            <p><strong>Username:</strong> {profile.email}</p>
          </div>
          <h3>Update Profile</h3>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label>Name</label>
              <input type="text" value={formData.name} onChange={(e) => setFormData({ ...formData, name: e.target.value })} />
            </div>
            <div className="form-group">
              <label>Username</label>
              <input type="text" value={formData.email} onChange={(e) => setFormData({ ...formData, email: e.target.value })} />
            </div>
            <div className="form-group">
              <label>Password (optional)</label>
              <input type="password" value={formData.password} onChange={(e) => setFormData({ ...formData, password: e.target.value })} placeholder="Leave blank to keep current password" />
            </div>
            <div className="form-group">
              <label>Confirm Password</label>
              <input type="password" value={formData.password_confirmation} onChange={(e) => setFormData({ ...formData, password_confirmation: e.target.value })} placeholder="Confirm new password" />
            </div>
            <button type="submit" className="btn-submit">Update Profile</button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default DoctorProfile;
