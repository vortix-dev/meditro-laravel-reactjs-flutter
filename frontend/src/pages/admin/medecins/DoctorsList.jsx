import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';

function DoctorsList() {
  const [doctors, setDoctors] = useState([]);
  const [services, setServices] = useState([]);
  const [loading, setLoading] = useState(false);
  const token = localStorage.getItem('token');

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const [doctorsRes, servicesRes] = await Promise.all([
          axios.get('http://localhost:8000/api/admin/medecins', { headers: { Authorization: `Bearer ${token}` } }),
          axios.get('http://localhost:8000/api/admin/services', { headers: { Authorization: `Bearer ${token}` } }),
        ]);
        setDoctors(doctorsRes.data.data);
        setServices(servicesRes.data.data);
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to fetch data');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [token]);

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this doctor?')) return;
    try {
      await axios.delete(`http://localhost:8000/api/admin/medecins/${id}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setDoctors(doctors.filter((doctor) => doctor.id !== id));
      toast.success('Doctor deleted successfully!');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to delete doctor');
    }
  };

  return (
    <div className="pt-20 pb-16 min-h-screen bg-gray-100">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          Doctors List
        </h2>
        <div className="mb-4">
          <Link to="/admin/doctors/create" className="btn-primary">
            Add New Doctor
          </Link>
        </div>
        {loading ? (
          <p className="text-center text-gray-600">Loading...</p>
        ) : doctors.length === 0 ? (
          <p className="text-center text-gray-600">No doctors found.</p>
        ) : (
          <div className="bg-white shadow-lg rounded-lg overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-blue-500 text-white">
                  <th className="py-3 px-4 text-left">Name</th>
                  <th className="py-3 px-4 text-left">Email</th>
                  <th className="py-3 px-4 text-left">Service</th>
                  <th className="py-3 px-4 text-left">Actions</th>
                </tr>
              </thead>
              <tbody>
                {doctors.map((doctor) => (
                  <tr key={doctor.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4">{doctor.name}</td>
                    <td className="py-3 px-4">{doctor.email}</td>
                    <td className="py-3 px-4">
                      {services.find((s) => s.id === doctor.service_id)?.name || 'N/A'}
                    </td>
                    <td className="py-3 px-4">

                      <button
                        onClick={() => handleDelete(doctor.id)}
                        className="text-red-500 hover:text-red-700"
                      >
                        Delete
                      </button>
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

export default DoctorsList;