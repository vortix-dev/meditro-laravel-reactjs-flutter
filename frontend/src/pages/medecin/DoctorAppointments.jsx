import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';

function DoctorAppointments() {
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(false);
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const medecinId = user?.id;

  useEffect(() => {
    const fetchAppointments = async () => {
      setLoading(true);
      try {
        const apptResponse = await axios.get('http://localhost:8000/api/medecin/all-my-rdv', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setAppointments(apptResponse.data.data);
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to fetch data');
      } finally {
        setLoading(false);
      }
    };

    if (token && medecinId) {
      fetchAppointments();
    } else {
      toast.error('Please log in again');
    }
  }, [token, medecinId]);

  const handleStatusChange = async (id, status) => {
    try {
      const response = await axios.put(
        `http://localhost:8000/api/medecin/update-rdv/${id}`,
        { status },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setAppointments(appointments.map((appt) => (appt.id === id ? { ...appt, status } : appt)));
      toast.success(response.data.message || 'Status updated');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to update status');
    }
  };

  return (
    <div className="appointments-container">
      <Sidebar />
      <div className="appointments-content">
        <h2 className="appointments-title">Manage Appointments</h2>
        {loading ? (
          <p className="appointments-loading">Loading...</p>
        ) : appointments.length === 0 ? (
          <p className="appointments-empty">No appointments found.</p>
        ) : (
          <div className="appointments-table-wrapper">
            <table className="appointments-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Patient</th>
                  <th>Date</th>
                  <th>Time</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {appointments.map((appt) => (
                  <tr key={appt.id}>
                    <td>{appt.id}</td>
                    <td>{appt.user?.name || 'N/A'}</td>
                    <td>{new Date(appt.date).toLocaleDateString()}</td>
                    <td>{appt.heure || 'N/A'}</td>
                    <td>{appt.status}</td>
                    <td>
                      <select
                        value={appt.status}
                        onChange={(e) => handleStatusChange(appt.id, e.target.value)}
                        disabled={['done', 'cancelled'].includes(appt.status)}
                      >
                        <option value="">Select</option>
                        <option value="done">Done</option>
                        <option value="cancelled">Cancelled</option>
                      </select>
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
