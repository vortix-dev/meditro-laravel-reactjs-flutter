import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';

function DoctorPatients() {
  const [patients, setPatients] = useState([]);
  const [loading, setLoading] = useState(false);
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const medecinId = user?.id;

  useEffect(() => {
    const fetchPatients = async () => {
      setLoading(true);
      try {
        const patientsResponse = await axios.get('http://localhost:8000/api/medecin/all-my-patient', {
          headers: { Authorization: `Bearer ${token}` },
        });
        const uniquePatients = [];
        const seenUserIds = new Set();
        patientsResponse.data.data.forEach((appt) => {
          if (!seenUserIds.has(appt.user_id)) {
            seenUserIds.add(appt.user_id);
            uniquePatients.push(appt);
          }
        });
        setPatients(uniquePatients);
      } catch (error) {
        console.error('Error fetching patients:', error.response);
        toast.error(error.response?.data?.message || 'Failed to fetch patients');
      } finally {
        setLoading(false);
      }
    };
    if (token && medecinId) {
      fetchPatients();
    } else {
      toast.error('Please log in again');
    }
  }, [token, medecinId]);

  if (loading) return <p className="text-center text-gray-600 pt-20">Loading...</p>;

  return (
    <div className="min-h-screen bg-gray-100 flex">
      <Sidebar />
      <div className="flex-1 container mx-auto px-4 pt-20 pb-16 ml-64">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          Manage Patients
        </h2>
        {patients.length === 0 ? (
          <p className="text-center text-gray-600">No patients found.</p>
        ) : (
          <div className="bg-white shadow-lg rounded-lg overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-blue-500 text-white">
                  <th className="py-3 px-4 text-left">ID</th>
                  <th className="py-3 px-4 text-left">Patient Name</th>
                  <th className="py-3 px-4 text-left">Date</th>
                  <th className="py-3 px-4 text-left">Dossier</th>
                </tr>
              </thead>
              <tbody>
                {patients.map((appt) => (
                  <tr key={appt.user_id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4">{appt.user_id}</td>
                    <td className="py-3 px-4">{appt.user?.name || 'N/A'}</td>
                    <td className="py-3 px-4">{new Date(appt.date).toLocaleDateString()}</td>
                    <td className="py-3 px-4">
                      <Link
                        to={`/doctor/medical-records/${appt.user_id}`}
                        className="px-2 py-1 bg-blue-500 text-white rounded hover:bg-blue-600"
                      >
                        View Dossier
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}

export default DoctorPatients;