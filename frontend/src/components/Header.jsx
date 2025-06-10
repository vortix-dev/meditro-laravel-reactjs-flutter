import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import LoginModal from './LoginModal';
import RegisterModal from './RegisterModal';
import { logout } from '../api/auth';
import logo from '../assets/logo.png';
import { toast } from 'react-toastify';
import './Header.css'; // Re-added CSS import

function Header() {
  const [isLoginOpen, setIsLoginOpen] = useState(false);
  const [isRegisterOpen, setIsRegisterOpen] = useState(false);
  const navigate = useNavigate();
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const isAuthenticated = !!token;
  const isUserRole = user?.role === 'user';
  const isAdminRole = user?.role === 'admin';
  const isAssistantRole = user?.role === 'assistant'; // Fixed typo
  const isDoctorRole = user?.role === 'medecin';

  const handleLogout = async () => {
    try {
      await logout();
      toast.success('Logged out successfully!');
      navigate('/'); // Changed to /login for consistency
    } catch (error) {
      toast.error('Logout failed. Please try again.');
    }
  };

  return (
    <header className="header">
      <div className="container">
        <div className="header-content">
          <div className="logo-container">
            <img src={logo} alt="Logo" className="logo" />
          </div>
          <nav className="nav">
            <ul className="nav-list">
              <li className="nav-item">
                <Link to="/" className="nav-link">Home</Link>
              </li>
              {isAuthenticated && isUserRole && (
                <>
                  <li className="nav-item">
                    <Link to="/my-appointments" className="nav-link">My Appointments</Link>
                  </li>
                  <li className="nav-item">
                    <Link to="/medical-record" className="nav-link">Medical Record</Link>
                  </li>
                </>
              )}
              {isAuthenticated && isAdminRole && (
                <li className="nav-item">
                  <Link to="/admin" className="nav-link">Admin Dashboard</Link>
                </li>
              )}
              {isAuthenticated && isAssistantRole && (
                <li className="nav-item">
                  <Link to="/assistant" className="nav-link">Assistant Dashboard</Link>
                </li>
              )}
              {isAuthenticated && isDoctorRole && (
                <li className="nav-item">
                  <Link to="/doctor" className="nav-link">Doctor Dashboard</Link>
                </li>
              )}
              <li className="nav-item">
                <Link to="/about" className="nav-link">About</Link>
              </li>
              <li className="nav-item">
                <Link to="/contact" className="nav-link">Contact</Link>
              </li>
            </ul>
          </nav>
          <div className="auth-buttons">
            {isAuthenticated ? (
              <button onClick={handleLogout} className="auth-button">
                <svg className="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 16l4-4m0 0l-4-4m4 4H7m5 4v-7" />
                </svg>
              </button>
            ) : (
              <>
                <button onClick={() => setIsLoginOpen(true)} className="auth-button">
                  <svg className="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M11 16l-4-4m0 0l4-4m-4 4h14" />
                  </svg>
                </button>
                <button onClick={() => setIsRegisterOpen(true)} className="auth-button">
                  <svg className="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M18 9v3m0 0v3m0-3h-3m3 0h3" />
                  </svg>
                </button>
              </>
            )}
          </div>
        </div>
      </div>
      <LoginModal isOpen={isLoginOpen} onClose={() => setIsLoginOpen(false)} />
      <RegisterModal isOpen={isRegisterOpen} onClose={() => setIsRegisterOpen(false)} />
    </header>
  );
}

export default Header;