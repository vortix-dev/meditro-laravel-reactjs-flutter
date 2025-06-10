import { Link } from 'react-router-dom';

function Sidebar() {
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const role = user?.role;

  return (
    <div className="w-64 bg-white shadow-lg h-screen p-4 fixed">
      <h2 className="text-xl font-bold mb-6">
        {role === 'admin' ? 'Admin Panel' : role === 'assistance' ? 'Assistant Panel' : 'Doctor Panel'}
      </h2>
      <ul className="space-y-4">
        {role === 'admin' && (
          <>
            <li>
              <Link to="/admin/services" className="text-gray-700 hover:text-blue-500">
                Manage Services
              </Link>
            </li>
            <li>
              <Link to="/admin/doctors" className="text-gray-700 hover:text-blue-500">
                Manage Doctors
              </Link>
            </li>
            <li>
              <Link to="/admin/assistants" className="text-gray-700 hover:text-blue-500">
                Manage Assistants
              </Link>
            </li>
          </>
        )}
        {role === 'assistance' && (
          <>
            <li>
              <Link to="/assistant/profile" className="text-gray-700 hover:text-blue-500">
                My Profile
              </Link>
            </li>
            <li>
              <Link to="/assistant/appointments" className="text-gray-700 hover:text-blue-500">
                Manage Appointments
              </Link>
            </li>
          </>
        )}
        {role === 'medecin' && (
          <>
            <li>
              <Link to="/doctor/profile" className="text-gray-700 hover:text-blue-500">
                My Profile
              </Link>
            </li>
            <li>
              <Link to="/doctor/appointments" className="text-gray-700 hover:text-blue-500">
                My Appointments
              </Link>
            </li>
            <li>
              <Link to="/doctor/patients" className="text-gray-700 hover:text-blue-500">
                My Patients
              </Link>
            </li>
            
          </>
        )}
      </ul>
    </div>
  );
}

export default Sidebar;