import { Link } from 'react-router-dom';
import './Sidebar.css'; // Import custom CSS

function Sidebar() {
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const role = user?.role;

  // Hide sidebar if no valid role
  if (!['admin', 'assistant', 'medecin'].includes(role)) {
    return null;
  }

  return (
    <nav className="sidebar" role="navigation" aria-label="Dashboard Navigation">
      <div className="sidebar-header">
        <h2 className="sidebar-title">
          {role === 'admin' ? 'Admin Panel' : role === 'assistant' ? 'Assistant Panel' : 'Doctor Panel'}
        </h2>
      </div>
      <ul className="sidebar-list">
        {role === 'admin' && (
          <>
            <li className="sidebar-item">
              <Link to="/admin/services" className="sidebar-link">
                <svg className="sidebar-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
                </svg>
                Manage Services
              </Link>
            </li>
            <li className="sidebar-item">
              <Link to="/admin/doctors" className="sidebar-link">
                <svg className="sidebar-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 14l9-5-9-5-9 5 9 5z" />
                </svg>
                Manage Doctors
              </Link>
            </li>
            <li className="sidebar-item">
              <Link to="/admin/assistants" className="sidebar-link">
                <svg className="sidebar-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
                Manage Assistants
              </Link>
            </li>
          </>
        )}
        {role === 'assistant' && (
          <>
            <li className="sidebar-item">
              <Link to="/assistant/profile" className="sidebar-link">
                <svg className="sidebar-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
                My Profile
              </Link>
            </li>
            <li className="sidebar-item">
              <Link to="/assistant/appointments" className="sidebar-link">
                <svg className="sidebar-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                Manage Appointments
              </Link>
            </li>
          </>
        )}
        {role === 'medecin' && (
          <>
            <li className="sidebar-item">
              <Link to="/doctor/profile" className="sidebar-link">
                <svg className="sidebar-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
                My Profile
              </Link>
            </li>
            <li className="sidebar-item">
              <Link to="/doctor/appointments" className="sidebar-link">
                <svg className="sidebar-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                My Appointments
              </Link>
            </li>
            <li className="sidebar-item">
              <Link to="/doctor/patients" className="sidebar-link">
                <svg className="sidebar-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                </svg>
                My Patients
              </Link>
            </li>
          </>
        )}
      </ul>
    </nav>
  );
}

export default Sidebar;