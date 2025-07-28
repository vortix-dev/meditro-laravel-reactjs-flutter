import { useState, useEffect, useRef } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';

function RegisterModal({ isOpen, onClose }) {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    password_confirmation: '',
    sexe: '',
    address: '',
    telephone: '',
  });
  const modalRef = useRef(null);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    // Client-side validation
    if (!/\S+@\S+\.\S+/.test(formData.email)) {
      toast.error('Please enter a valid email address.');
      return;
    }
    if (formData.password !== formData.password_confirmation) {
      toast.error('Passwords do not match.');
      return;
    }
    if (!/^\+?\d{10,15}$/.test(formData.telephone)) {
      toast.error('Please enter a valid phone number (10-15 digits).');
      return;
    }

    try {
      const response = await axios.post('http://localhost:8000/api/register', formData);
      localStorage.setItem('token', response.data.token);
      localStorage.setItem('user', JSON.stringify(response.data.user));
      toast.success('Registration successful!');
      onClose();
      // Navigate based on role
      const role = response.data.user.role;
      if (role === 'admin') navigate('/admin');
      else if (role === 'assistant') navigate('/assistant');
      else if (role === 'medecin') navigate('/doctor');
      else navigate('/'); // Default to home
    } catch (error) {
      const errorMessage = error.response?.data?.message || 'Registration failed. Please try again.';
      toast.error(errorMessage);
    }
  };

  // Handle Escape key and focus
  useEffect(() => {
    const handleKeyDown = (e) => {
      if (e.key === 'Escape') onClose();
    };

    if (isOpen) {
      document.addEventListener('keydown', handleKeyDown);
      modalRef.current?.focus();
    }

    return () => {
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [isOpen, onClose]);

  // Handle click outside to close
  const handleOverlayClick = (e) => {
    if (e.target === e.currentTarget) onClose();
  };

  if (!isOpen) return null;

  return (
    <div
      className="modal-overlay"
      onClick={handleOverlayClick}
      role="dialog"
      aria-modal="true"
      aria-labelledby="register-modal-title"
      tabIndex="-1"
      ref={modalRef}
    >
      <div className="modal-content">
        <h2 id="register-modal-title" className="modal-title">Register</h2>
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="name" className="form-label">Name</label>
            <input
              id="name"
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className="form-input"
              required
              aria-required="true"
            />
          </div>
          <div className="form-group">
            <label htmlFor="email" className="form-label">Email</label>
            <input
              id="email"
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              className="form-input"
              required
              aria-required="true"
            />
          </div>
          <div className="form-group">
            <label htmlFor="password" className="form-label">Password</label>
            <input
              id="password"
              type="password"
              value={formData.password}
              onChange={(e) => setFormData({ ...formData, password: e.target.value })}
              className="form-input"
              required
              aria-required="true"
            />
          </div>
          <div className="form-group">
            <label htmlFor="password_confirmation" className="form-label">Confirm Password</label>
            <input
              id="password_confirmation"
              type="password"
              value={formData.password_confirmation}
              onChange={(e) => setFormData({ ...formData, password_confirmation: e.target.value })}
              className="form-input"
              required
              aria-required="true"
            />
          </div>
          <div className="form-group">
            <label htmlFor="sexe" className="form-label">Gender</label>
            <select
              id="sexe"
              value={formData.sexe}
              onChange={(e) => setFormData({ ...formData, sexe: e.target.value })}
              className="form-input"
              required
              aria-required="true"
            >
              <option value="">Select Gender</option>
              <option value="Homme">Male</option>
              <option value="Femme">Female</option>
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="address" className="form-label">Address</label>
            <input
              id="address"
              type="text"
              value={formData.address}
              onChange={(e) => setFormData({ ...formData, address: e.target.value })}
              className="form-input"
              required
              aria-required="true"
            />
          </div>
          <div className="form-group">
            <label htmlFor="telephone" className="form-label">Phone Number</label>
            <input
              id="telephone"
              type="tel"
              value={formData.telephone}
              onChange={(e) => setFormData({ ...formData, telephone: e.target.value })}
              className="form-input"
              required
              aria-required="true"
            />
          </div>
          <div className="form-actions">
            <button type="submit" className="btn btn-primary">Register</button>
            <button type="button" onClick={onClose} className="btn btn-secondary">Cancel</button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default RegisterModal;