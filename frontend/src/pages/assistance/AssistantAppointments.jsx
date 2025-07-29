import { useState, useEffect } from 'react';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';
import './AssistantAppointments.css'; // Import the new CSS

function AssistantAppointments() {
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(false);
  const token = localStorage.getItem('token');

  useEffect(() => {
    const fetchAppointments = async () => {
      setLoading(true);
      try {
        const response = await axios.get('http://localhost:8000/api/assistance/all-rdv', {
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
  }, [token]);

  const handleStatusChange = async (id, status) => {
    try {
      const payload = { status };
      const response = await axios.put(`http://localhost:8000/api/assistance/update-rdv/${id}`, payload, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setAppointments(
        appointments.map((appt) =>
          appt.id === id ? { ...appt, status } : appt
        )
      );
      toast.success(response.data.message || 'Appointment status updated successfully!');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to update status');
    }
  };

  if (loading) return <p className="loading-text">Loading...</p>;

  return (
    <div className="appointments-container">
      <div className="appointments-wrapper">
        <h2 className="appointments-title">Manage Appointments</h2>
        {appointments.length === 0 ? (
          <p className="no-appointments">No appointments found.</p>
        ) : (
          <div className="table-container">
            <table className="appointments-table">
              <thead className="table-header">
                <tr>
                  <th>ID</th>
                  <th>Doctor</th>
                  <th>User</th>
                  <th>Date</th>
                  <th>Time</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {appointments.map((appt) => (
                  <tr key={appt.id} className="table-row">
                    <td>{appt.id}</td>
                    <td>{appt.medecin?.name || 'N/A'}</td>
                    <td>{appt.user?.name || 'N/A'}</td>
                    <td>{new Date(appt.date).toLocaleDateString()}</td>
                    <td>{appt.heure || 'N/A'}</td>
                    <td>{appt.status}</td>
                    <td>
                      <select
                        className="status-select"
                        value={appt.status}
                        onChange={(e) => handleStatusChange(appt.id, e.target.value)}
                        disabled={appt.status === 'done'}
                      >
                        <option value="">Select</option>
                        <option value="confirmed">Confirmed</option>
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

export default AssistantAppointments;