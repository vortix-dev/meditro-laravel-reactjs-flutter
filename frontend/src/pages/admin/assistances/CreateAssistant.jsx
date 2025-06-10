import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import './CreateAssistant.css'; // تأكد من الربط بملف CSS الصحيح

function CreateAssistant() {
  const [formData, setFormData] = useState({ name: '', email: '', password: '' });
  const navigate = useNavigate();
  const token = localStorage.getItem('token');

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await axios.post('http://localhost:8000/api/admin/assistance', formData, {
        headers: { Authorization: `Bearer ${token}` },
      });
      toast.success('Assistant created successfully!');
      navigate('/admin/assistants');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to create assistant');
    }
  };

  return (
    <div className="create-container">
      <div className="form-wrapper">
        <h2 className="form-title">Create New Assistant</h2>
        <div className="form-box">
          <form onSubmit={handleSubmit}>
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
              Create Assistant
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default CreateAssistant;
