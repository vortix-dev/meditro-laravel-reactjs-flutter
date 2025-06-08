import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import LoginModal from './LoginModal';
import RegisterModal from './RegisterModal';
import { logout } from '../api/auth';
import logo from '../assets/logo.png';
import { toast } from 'react-toastify';

function Header() {
  const [isLoginOpen, setIsLoginOpen] = useState(false);
  const [isRegisterOpen, setIsRegisterOpen] = useState(false);
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
    <header className="bg-white shadow-md fixed w-full top-0 z-50">
      <div className="container mx-auto px-4 py-4 flex justify-between items-center">
        <div className="flex items-center">
          <img src={logo} alt="Logo" className="h-12" />
        </div>
        <nav className="flex space-x-6 items-center">
          <Link to="/" className="text-gray-700 hover:text-blue-500">Home</Link>
          {isAuthenticated && isUserRole && (
            <>
              <Link to="/booking" className="text-gray-700 hover:text-blue-500">Book Appointment</Link>
              <Link to="/my-appointments" className="text-gray-700 hover:text-blue-500">My Appointments</Link>
              <Link to="/medical-record" className="text-gray-700 hover:text-blue-500">Medical Record</Link>
            </>
          )}
          {isAuthenticated && isAdminRole && (
            <Link to="/admin" className="text-gray-700 hover:text-blue-500">
              Admin Dashboard
            </Link>
          )}
          {isAuthenticated && isAssistantRole && (
            <Link to="/assistant" className="text-gray-700 hover:text-blue-500">
              Assistant Dashboard
            </Link>
          )}
          {isAuthenticated && isDoctorRole && (
            <Link to="/doctor" className="text-gray-700 hover:text-blue-500">
              Doctor Dashboard
            </Link>
          )}
          <Link to="/about" className="text-gray-700 hover:text-blue-500">About</Link>
          <Link to="/contact" className="text-gray-700 hover:text-blue-500">Contact</Link>
        </nav>
        <div className="flex space-x-4">
          {isAuthenticated ? (
            <button onClick={handleLogout} className="text-gray-700 hover:text-blue-500">
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 16l4-4m0 0l-4-4m4 4H7m5 4v-7" />
              </svg>
            </button>
          ) : (
            <>
              <button onClick={() => setIsLoginOpen(true)} className="text-gray-700 hover:text-blue-500">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M11 16l-4-4m0 0l4-4m-4 4h14" />
                </svg>
              </button>
              <button onClick={() => setIsRegisterOpen(true)} className="text-gray-700 hover:text-blue-500">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M18 9v3m0 0v3m0-3h-3m3 0h3" />
                </svg>
              </button>
            </>
          )}
        </div>
      </div>
      <LoginModal isOpen={isLoginOpen} onClose={() => setIsLoginOpen(false)} />
      <RegisterModal isOpen={isRegisterOpen} onClose={() => setIsRegisterOpen(false)} />
    </header>
  );
}

export default Header;