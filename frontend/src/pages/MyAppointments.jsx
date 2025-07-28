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
    <div className="appointments-container">
      <div className="appointments-wrapper">
        <h2 className="appointments-title">My Appointments</h2>
        {loading ? (
          <p className="loading-text">Loading...</p>
        ) : appointments.length === 0 ? (
          <p className="loading-text">No appointments found.</p>
        ) : (
          <div className="table-container">
            <table className="appointments-table">
              <thead>
                <tr className="table-header">
                  <th>Doctor</th>
                  <th>Date</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {appointments.map((appt) => (
                  <tr key={appt.id} className="table-row">
                    <td>{appt.medecin?.name || 'N/A'}</td>
                    <td>{appt.date}</td>
                    <td className="capitalize">
                      <span className={`status-badge ${appt.status}`}>
                        {appt.status}
                      </span>
                    </td>
                    <td>
                      {appt.status === 'pending' && (
                        <button
                          onClick={() => handleCancel(appt.id)}
                          className="cancel-button"
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
