import { Outlet } from 'react-router-dom';
import Sidebar from '../../components/Sidebar';
import './AdminDashboard.css'; // أنشئ هذا الملف للستايلات

function AdminDashboard() {
  return (
    <div className="admin-dashboard">
      <Sidebar />
      <main className="admin-main">
        <div className="container">
          <Outlet />
        </div>
      </main>
    </div>
  );
}

export default AdminDashboard;
