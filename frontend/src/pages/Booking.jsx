import { useState, useEffect } from 'react';
import axios from 'axios';
import { toast } from 'react-toastify';

function Booking() {
  const [formData, setFormData] = useState({
    medecin_id: '',
    date: '',
    time: '',
    status: 'pending',
  });
  const token = localStorage.getItem('token');
  const [services, setServices] = useState([]);
  const [doctors, setDoctors] = useState([]);
  const [availableTimes, setAvailableTimes] = useState([]);
  const [selectedService, setSelectedService] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchServices = async () => {
      try {
        const servicesRes = await axios.get('http://localhost:8000/api/services', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setServices(servicesRes.data.data);
      } catch (error) {
        toast.error('Failed to fetch services');
      }
    };
    fetchServices();
  }, [token]);

  useEffect(() => {
    const fetchDoctors = async () => {
      if (!selectedService) {
        setDoctors([]);
        return;
      }
      try {
        const response = await axios.get(
          `http://localhost:8000/api/user/medecins/${selectedService}`,
          { headers: { Authorization: `Bearer ${token}` } }
        );
        setDoctors(response.data.data || []);
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to fetch doctors');
        setDoctors([]);
      }
    };
    fetchDoctors();
  }, [selectedService, token]);

  useEffect(() => {
    const fetchAvailableTimes = async () => {
      if (!formData.medecin_id || !formData.date) {
        setAvailableTimes([]);
        return;
      }
      try {
        const response = await axios.get(
          `http://localhost:8000/api/user/available-times?medecin_id=${formData.medecin_id}&date=${formData.date}`,
          { headers: { Authorization: `Bearer ${token}` } }
        );
        setAvailableTimes(response.data.times || []);
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to fetch available times');
        setAvailableTimes([]);
      }
    };
    fetchAvailableTimes();
  }, [formData.medecin_id, formData.date, token]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await axios.post(
        'http://localhost:8000/api/user/create-rdv',
        {
          medecin_id: formData.medecin_id,
          date: formData.date,
          heure: formData.time, // Laravel controller expects `heure`
          status: formData.status,
        },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      toast.success('Appointment booked successfully!');
      setFormData({ medecin_id: '', date: '', time: '', status: 'pending' });
      setSelectedService('');
      setAvailableTimes([]);
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to book appointment');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="booking-page">
      <div className="booking-container">
        <h2 className="booking-title">Book an Appointment</h2>
        <form onSubmit={handleSubmit} className="booking-form">
          <div className="form-group">
            <label className="form-label">Service</label>
            <select
              value={selectedService}
              onChange={(e) => {
                setSelectedService(e.target.value);
                setFormData({ ...formData, medecin_id: '', time: '' });
                setAvailableTimes([]);
              }}
              className="form-select"
              required
            >
              <option value="">Select a Service</option>
              {services.map((service) => (
                <option key={service.id} value={service.id}>
                  {service.name}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label className="form-label">Doctor</label>
            <select
              value={formData.medecin_id}
              onChange={(e) => setFormData({ ...formData, medecin_id: e.target.value, time: '' })}
              className="form-select"
              required
              disabled={!selectedService}
            >
              <option value="">Select a Doctor</option>
              {doctors.map((doctor) => (
                <option key={doctor.id} value={doctor.id}>
                  {doctor.name}
                </option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label className="form-label">Date</label>
            <input
              type="date"
              value={formData.date}
              onChange={(e) => setFormData({ ...formData, date: e.target.value, time: '' })}
              className="form-input"
              required
            />
          </div>
          <div className="form-group">
            <label className="form-label">Time</label>
            <select
              value={formData.time}
              onChange={(e) => setFormData({ ...formData, time: e.target.value })}
              className="form-select"
              required
              disabled={availableTimes.length === 0}
            >
              <option value="">Select a Time</option>
              {availableTimes.map((time) => (
                <option key={time} value={time}>
                  {time}
                </option>
              ))}
            </select>
          </div>
          <button type="submit" className="submit-button" disabled={loading}>
            {loading ? 'Booking...' : 'Book Appointment'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default Booking;
