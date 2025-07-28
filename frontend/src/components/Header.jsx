import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import LoginModal from './LoginModal';
import RegisterModal from './RegisterModal';
import { logout } from '../api/auth';
import logo from '../assets/logo.png';
import { toast } from 'react-toastify';
import { ArrowRightOnRectangleIcon, ArrowLeftOnRectangleIcon, UserPlusIcon } from '@heroicons/react/24/outline';

function Header() {
  const [isLoginOpen, setIsLoginOpen] = useState(false);
  const [isRegisterOpen, setIsRegisterOpen] = useState(false);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const navigate = useNavigate();
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const isAuthenticated = !!token;
  const isUserRole = user?.role === 'user';
  const isAdminRole = user?.role === 'admin';
  const isAssistantRole = user?.role === 'assistance';
  const isDoctorRole = user?.role === 'medecin';

  const handleLogout = async () => {
    try {
      await logout();
      toast.success('Logged out successfully!');
      navigate('/');
    } catch (error) {
      toast.error('Logout failed. Please try again.');
    }
  };

  return (
    <>
    <header className="app-bar">
      <div className="container">
        <div className="header-content">
          <div className="logo-container">
            <img src={logo} alt="Logo" className="logo" />
          </div>

          {/* زر القائمة المنسدلة للشاشات الصغيرة */}
          <button
            className="menu-toggle"
            onClick={() => setIsMenuOpen(!isMenuOpen)}
          >
            <svg className="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>

          {/* القائمة الرئيسية */}
          <nav className={`nav ${isMenuOpen ? 'open' : ''}`}>
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
                  <Link to="/admin" className="nav-link">Dashboard</Link>
                </li>
              )}
              {isAuthenticated && isAssistantRole && (
                <li className="nav-item">
                  <Link to="/assistant" className="nav-link">Dashboard</Link>
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

          {/* أزرار تسجيل الدخول/الخروج */}
          <div className="auth-buttons">
            {isAuthenticated ? (
              <button onClick={handleLogout} className="auth-button">
                <ArrowLeftOnRectangleIcon className="icon" />
              </button>
            ) : (
              <>
                <button onClick={() => setIsLoginOpen(true)} className="auth-button">
                  <ArrowRightOnRectangleIcon className="icon" />
                </button>
                <button onClick={() => setIsRegisterOpen(true)} className="auth-button">
                  <UserPlusIcon className="icon" />
                </button>
              </>
            )}
          </div>
        </div>
      </div>
    </header>
      <LoginModal isOpen={isLoginOpen} onClose={() => setIsLoginOpen(false)} />
      <RegisterModal isOpen={isRegisterOpen} onClose={() => setIsRegisterOpen(false)} />
      </>
  );
}

export default Header;
