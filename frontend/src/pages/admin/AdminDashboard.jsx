import { Outlet } from 'react-router-dom';
import Sidebar from '../../components/Sidebar';

function AdminDashboard() {
  return (
    <div className="admin-dashboard">
      <main className="admin-main">
        <Sidebar />
        <div className="container">
          <Outlet />
        </div>
      </main>
    </div>
  );
}

export default AdminDashboard;