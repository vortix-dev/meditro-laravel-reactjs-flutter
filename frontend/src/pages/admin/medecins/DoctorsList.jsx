import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import { FaTrash } from 'react-icons/fa';

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
    <div className="doctors-container">
      <div className="content-wrapper">
        <h2 className="title">Doctors List</h2>
        <div className="actions">
          <Link to="/admin/doctors/create" className="btn">
            Add New Doctor
          </Link>
        </div>
        {loading ? (
          <p className="message">Loading...</p>
        ) : doctors.length === 0 ? (
          <p className="message">No doctors found.</p>
        ) : (
          <div className="table-container">
            <table className="doctors-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Service</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {doctors.map((doctor) => (
                  <tr key={doctor.id}>
                    <td>{doctor.name}</td>
                    <td>{doctor.email}</td>
                    <td>{services.find((s) => s.id === doctor.service_id)?.name || 'N/A'}</td>
                    <td>
                      <Link  onClick={() => handleDelete(doctor.id)}>
                        <FaTrash />
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

export default DoctorsList;
