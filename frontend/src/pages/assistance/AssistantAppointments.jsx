import { useState, useEffect } from 'react';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';

function AssistantAppointments() {
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedApptId, setSelectedApptId] = useState(null);
  const [formData, setFormData] = useState({
    status: '',
    date: '',
    heure: '',
  });
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

  const openModal = (apptId, status) => {
    if (status === 'confirmed') {
      setSelectedApptId(apptId);
      setFormData({ status, date: '', heure: '' });
      setIsModalOpen(true);
    } else {
      handleStatusChange(apptId, status);
    }
  };

  const handleStatusChange = async (id, status, date = null, heure = null) => {
    try {
      const payload = { status };
      if (status === 'confirmed') {
        payload.date = date;
        payload.heure = heure;
      }
      const response = await axios.put(`http://localhost:8000/api/assistance/update-rdv/${id}`, payload, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setAppointments(
        appointments.map((appt) =>
          appt.id === id ? { ...appt, status, date: date || appt.date, heure: heure || appt.heure } : appt
        )
      );
      toast.success(response.data.message || 'Appointment status updated successfully!');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to update status');
    }
  };

  const handleModalSubmit = (e) => {
    e.preventDefault();
    const { status, date, heure } = formData;
    if (status === 'confirmed' && (!date || !heure)) {
      toast.error('Date and time are required for confirmed appointments');
      return;
    }
    // Convert heure from H:i to H:i:s by appending :00
    const formattedHeure = heure ? `${heure}:00` : null;
    handleStatusChange(selectedApptId, status, date, formattedHeure);
    setIsModalOpen(false);
    setFormData({ status: '', date: '', heure: '' });
    setSelectedApptId(null);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setFormData({ status: '', date: '', heure: '' });
    setSelectedApptId(null);
  };

  if (loading) return <p className="text-center text-gray-600 pt-20">Loading...</p>;

  return (
    <div className="min-h-screen bg-gray-100 flex">
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
                  <th className="py-3 px-4 text-left">Doctor</th>
                  <th className="py-3 px-4 text-left">User</th>
                  <th className="py-3 px-4 text-left">Date</th>
                  <th className="py-3 px-4 text-left">Time</th>
                  <th className="py-3 px-4 text-left">Status</th>
                  <th className="py-3 px-4 text-left">Actions</th>
                </tr>
              </thead>
              <tbody>
                {appointments.map((appt) => (
                  <tr key={appt.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4">{appt.id}</td>
                    <td className="py-3 px-4">{appt.medecin?.name || 'N/A'}</td>
                    <td className="py-3 px-4">{appt.user?.name || 'N/A'}</td>
                    <td className="py-3 px-4">{new Date(appt.date).toLocaleDateString()}</td>
                    <td className="py-3 px-4">{appt.heure || 'N/A'}</td>
                    <td className="py-3 px-4">{appt.status}</td>
                    <td className="py-3 px-4">
                      <select
                        value={appt.status}
                        onChange={(e) => openModal(appt.id, e.target.value)}
                        className="px-2 py-1 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                        disabled={appt.status === 'done'}
                      >
                        <option value="">Select </option>
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

        {/* Modal for Confirmed Status */}
        {isModalOpen && (
          <div className="modal-overlay">
            <div className="bg-white rounded-lg p-6 w-full max-w-md">
              <h3 className="text-xl font-semibold text-gray-800 mb-4">Confirm Appointment</h3>
              <form onSubmit={handleModalSubmit}>
                <div className="mb-4">
                  <label className="block text-gray-700">Date</label>
                  <input
                    type="date"
                    value={formData.date}
                    onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                    className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                    min={new Date().toISOString().split('T')[0]}
                    required
                  />
                </div>
                <div className="mb-4">
                  <label className="block text-gray-700">Time</label>
                  <input
                    type="time"
                    value={formData.heure}
                    onChange={(e) => setFormData({ ...formData, heure: e.target.value })}
                    className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
                <div className="flex justify-end space-x-2">
                  <button
                    type="button"
                    onClick={closeModal}
                    className="px-4 py-2 bg-gray-300 text-gray-800 rounded hover:bg-gray-400"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="btn-primary px-4 py-2"
                  >
                    Confirm
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default AssistantAppointments;