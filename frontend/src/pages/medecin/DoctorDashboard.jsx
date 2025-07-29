import { Link } from 'react-router-dom';
import Sidebar from '../../components/Sidebar';

function DoctorDashboard() {
  return (
    <div className="dashboard-container">
      <Sidebar />
      <div className="dashboard-content">
        <h2 className="dashboard-title">Doctor Dashboard</h2>
      </div>
    </div>
  );
}

export default DoctorDashboard;
