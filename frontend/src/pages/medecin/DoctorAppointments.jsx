import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';

function DoctorAppointments() {
  const [appointments, setAppointments] = useState([]);
  const [dossiers, setDossiers] = useState({});
  const [loading, setLoading] = useState(false);
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const medecinId = user?.id;

  useEffect(() => {
    const fetchAppointmentsAndDossiers = async () => {
      setLoading(true);
      try {
        const apptResponse = await axios.get('http://localhost:8000/api/medecin/all-my-rdv', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setAppointments(apptResponse.data.data);

        const dossierResponse = await axios.get(`http://localhost:8000/api/medecin/dossier-medicale/${medecinId}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        const dossiersMap = dossierResponse.data.data.reduce((acc, dossier) => {
          acc[dossier.user_id] = dossier;
          return acc;
        }, {});
        setDossiers(dossiersMap);
      } catch (error) {
        console.error('Error fetching data:', error.response);
        toast.error(error.response?.data?.message || 'Failed to fetch data');
      } finally {
        setLoading(false);
      }
    };
    if (token && medecinId) {
      fetchAppointmentsAndDossiers();
    } else {
      toast.error('Please log in again');
    }
  }, [token, medecinId]);

  const handleStatusChange = async (id, status) => {
    try {
      const payload = { status };
      const response = await axios.put(`http://localhost:8000/api/medecin/update-rdv/${id}`, payload, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setAppointments(
        appointments.map((appt) => (appt.id === id ? { ...appt, status } : appt))
      );
      toast.success(response.data.message || 'Appointment status updated successfully!');
    } catch (error) {
      console.error('Error updating status:', error.response);
      if (error.response?.status === 401) {
        toast.error('Unauthorized: Please log in again');
      } else if (error.response?.status === 422) {
        Object.values(error.response.data.errors).forEach((err) => toast.error(err[0]));
      } else {
        toast.error(error.response?.data?.message || 'Failed to update status');
      }
    }
  };

  if (loading) return <p className="text-center text-gray-600 pt-20">Loading...</p>;

  return (
    <div className="min-h-screen bg-gray-100 flex">
      <Sidebar />
      <div className="flex-1 container mx-auto px-4 pt-20 pb-16 ml-64">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          Manage Appointments
        </h2>
        {appointments.length === 0 ? (
          <p className="text-center text-gray-600">No appointments found.</p>
        ) : (
          <div className="bg-white shadow-lg rounded-lg overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-blue-500 text-white">
                  <th className="py-3 px-4 text-left">ID</th>
                  <th className="py-3 px-4 text-left">Patient</th>
                  <th className="py-3 px-4 text-left">Date</th>
                  <th className="py-3 px-4 text-left">Time</th>
                  <th className="py-3 px-4 text-left">Status</th>
                  <th className="py-3 px-4 text-left">Actions</th>
                  <th className="py-3 px-4 text-left">Dossier</th>
                </tr>
              </thead>
              <tbody>
                {appointments.map((appt) => (
                  <tr key={appt.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4">{appt.id}</td>
                    <td className="py-3 px-4">{appt.user?.name || 'N/A'}</td>
                    <td className="py-3 px-4">{new Date(appt.date).toLocaleDateString()}</td>
                    <td className="py-3 px-4">{appt.heure || 'N/A'}</td>
                    <td className="py-3 px-4">{appt.status}</td>
                    <td className="py-3 px-4">
                      <select
                        value={appt.status}
                        onChange={(e) => handleStatusChange(appt.id, e.target.value)}
                        className="px-2 py-1 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-200 disabled:cursor-not-allowed"
                        disabled={['done', 'cancelled'].includes(appt.status)}
                      >
                        <option value="done">Done</option>
                        <option value="cancelled">Cancelled</option>
                      </select>
                    </td>
                    <td className="py-3 px-4">
                      <Link
                        to={
                          dossiers[appt.user_id]
                            ? `/doctor/medical-records/${dossiers[appt.user_id].id}`
                            : `/doctor/medical-records/new?patient_id=${appt.user_id}`
                        }
                        className="px-2 py-1 bg-blue-500 text-white rounded hover:bg-blue-600"
                      >
                        View Dossier Medicale
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

export default DoctorAppointments;