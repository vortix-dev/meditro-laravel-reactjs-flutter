import { useState, useEffect } from 'react';
import axios from 'axios';
import { toast } from 'react-toastify';

function MyAppointments() {
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchAppointments = async () => {
      setLoading(true);
      try {
        const token = localStorage.getItem('token');
        const response = await axios.get('http://localhost:8000/api/user/all-my-rdv', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setAppointments(response.data.data);
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to fetch appointments');
      } finally {
        setLoading(false);
      }
    };
    fetchAppointments();
  }, []);

  const handleCancel = async (id) => {
    if (!window.confirm('Are you sure you want to cancel this appointment?')) return;
    try {
      const token = localStorage.getItem('token');
      await axios.post(`http://localhost:8000/api/user/cancel-rdv/${id}`, {}, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setAppointments(appointments.filter((appt) => appt.id !== id));
      toast.success('Appointment cancelled successfully!');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to cancel appointment');
    }
  };

  return (
    <div className="pt-20 pb-16 min-h-screen bg-gray-100">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          My Appointments
        </h2>
        {loading ? (
          <p className="text-center text-gray-600">Loading...</p>
        ) : appointments.length === 0 ? (
          <p className="text-center text-gray-600">No appointments found.</p>
        ) : (
          <div className="bg-white shadow-lg rounded-lg overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-blue-500 text-white">
                  <th className="py-3 px-4 text-left">Doctor</th>
                  <th className="py-3 px-4 text-left">Date</th>
                  <th className="py-3 px-4 text-left">Status</th>
                  <th className="py-3 px-4 text-left">Actions</th>
                </tr>
              </thead>
              <tbody>
                {appointments.map((appt) => (
                  <tr key={appt.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4">{appt.medecin?.name || 'N/A'}</td>
                    <td className="py-3 px-4">{appt.date}</td>
                    <td className="py-3 px-4 capitalize">{appt.status}</td>
                    <td className="py-3 px-4">
                      {appt.status === 'pending' && (
                        <button
                          onClick={() => handleCancel(appt.id)}
                          className="text-red-500 hover:text-red-700"
                        >
                          Cancel
                        </button>
                      )}
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

export default MyAppointments;