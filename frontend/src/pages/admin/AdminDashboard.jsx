import { Outlet } from 'react-router-dom';
import Sidebar from '../../components/Sidebar';

function AdminDashboard() {
  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <main className="flex-1 p-6 bg-gray-100">
        <Outlet />
      </main>
    </div>
  );
}

export default AdminDashboard;
