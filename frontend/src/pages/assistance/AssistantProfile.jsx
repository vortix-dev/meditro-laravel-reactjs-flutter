import { useState, useEffect } from 'react';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';

function AssistantProfile() {
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
        const response = await axios.get('http://localhost:8000/api/assistance/profile', {
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
      const response = await axios.put(`http://localhost:8000/api/assistance/profile-update/${id}`, payload, {
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

  if (isLoading) return <p className="loading-text">Loading...</p>;

  return (
    <div className="profile-container">
      <div className="profile-wrapper">
        <h2 className="profile-title">Assistant Profile</h2>
        <div className="current-profile">
          <h3 className="current-profile-title">Current Profile</h3>
          <p className="current-profile-text"><strong>Name:</strong> {profile.name}</p>
          <p className="current-profile-text"><strong>Email:</strong> {profile.email}</p>
        </div>
        <h3 className="update-profile-title">Update Profile</h3>
        <form className="profile-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label">Name</label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className="form-input"
            />
          </div>
          <div className="form-group">
            <label className="form-label">Email</label>
            <input
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              className="form-input"
            />
          </div>
          <div className="form-group">
            <label className="form-label">Password (Optional)</label>
            <input
              type="password"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              className="form-input"
              placeholder="Leave blank to keep current password"
            />
          </div>
          <div className="form-group">
            <label className="form-label">Confirm Password</label>
            <input
              type="password"
              value={formData.password_confirmation}
              onChange={(e) => setFormData({ ...formData, password_confirmation: e.target.value })}
              className="form-input"
              placeholder="Confirm new password"
            />
          </div>
          <button type="submit" className="submit-button">
            Update Profile
          </button>
        </form>
      </div>
    </div>
  );
}

export default AssistantProfile;