import { useState, useEffect } from 'react';
import axios from 'axios';
import { toast } from 'react-toastify';

function Booking() {
  const [formData, setFormData] = useState({
    medecin_id: '',
    date: '',
    status: 'pending',
  });
        const token = localStorage.getItem('token');

  const [services, setServices] = useState([]);
  const [doctors, setDoctors] = useState([]);
  const [selectedService, setSelectedService] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchServices = async () => {
      try {
        const servicesRes = await axios.get('http://localhost:8000/api/services');
        setServices(servicesRes.data.data);
      } catch (error) {
        toast.error('Failed to fetch services');
      }
    };
    fetchServices();
  }, []);

  useEffect(() => {
    const fetchDoctors = async () => {
        if (!selectedService) return setDoctors([]);
        try {
            const response = await axios.get(
            `http://localhost:8000/api/user/medecins/${selectedService}`,
            {
                headers: {
                Authorization: `Bearer ${token}`,
                },
            }
            );
            setDoctors(response.data.data || []);
        } catch (error) {
            console.error(error); // مفيد للتصحيح
            toast.error(error.response?.data?.message || 'Failed to fetch doctors');
            setDoctors([]);
        }
    };

    fetchDoctors();
  }, [selectedService]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await axios.post(
        'http://localhost:8000/api/user/create-rdv',
        {
          medecin_id: formData.medecin_id,
          date: `${formData.date}`, // Combine date and time
          status: formData.status,
        },
        {
          headers: { Authorization: `Bearer ${token}` },
        }
      );
      toast.success('Appointment booked successfully!');
      setFormData({ medecin_id: '', date: '', status: 'pending' });
      setSelectedService('');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to book appointment');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="pt-20 pb-16 min-h-screen bg-gray-100">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          Book an Appointment
        </h2>
        <form onSubmit={handleSubmit} className="max-w-lg mx-auto bg-white p-6 rounded-lg shadow-lg">
          <div className="mb-4">
            <label className="block text-gray-700">Service</label>
            <select
              value={selectedService}
              onChange={(e) => {
                setSelectedService(e.target.value);
                setFormData({ ...formData, medecin_id: '' });
              }}
              className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
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
          <div className="mb-4">
            <label className="block text-gray-700">Doctor</label>
            <select
              value={formData.medecin_id}
              onChange={(e) => setFormData({ ...formData, medecin_id: e.target.value })}
              className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
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
          <div className="mb-4">
            <label className="block text-gray-700">Date</label>
            <input
              type="date"
              value={formData.date}
              onChange={(e) => setFormData({ ...formData, date: e.target.value })}
              min={new Date(new Date().setDate(new Date().getDate() + 1)).toISOString().split('T')[0]}
              className="w-full px-3 py-2 border rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>
          <button
            type="submit"
            className="btn-primary w-full"
            disabled={loading || !selectedService || !formData.medecin_id}
          >
            {loading ? 'Booking...' : 'Book Appointment'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default Booking;