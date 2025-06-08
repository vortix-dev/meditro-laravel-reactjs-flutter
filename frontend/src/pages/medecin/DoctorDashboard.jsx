import { Link } from 'react-router-dom';
import Sidebar from '../../components/Sidebar';

function DoctorDashboard() {
  return (
    <div className="min-h-screen bg-gray-100 flex">
      <Sidebar />
      <div className="flex-1 container mx-auto px-4 pt-20 pb-16 ml-64">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          Doctor Dashboard
        </h2>
      </div>
    </div>
  );
}

export default DoctorDashboard;