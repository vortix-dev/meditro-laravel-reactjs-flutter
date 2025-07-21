import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import './ServicesList.css'; // تأكد من إضافة هذا الملف
import { FaEdit, FaTrash } from 'react-icons/fa';

function ServicesList() {
  const [services, setServices] = useState([]);
  const [loading, setLoading] = useState(false);
  const token = localStorage.getItem('token');

  useEffect(() => {
    const fetchServices = async () => {
      setLoading(true);
      try {
        const response = await axios.get('http://localhost:8000/api/admin/services', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setServices(response.data.data);
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to fetch services');
      } finally {
        setLoading(false);
      }
    };
    fetchServices();
  }, [token]);

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this service?')) return;
    try {
      await axios.delete(`http://localhost:8000/api/admin/services/${id}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setServices(services.filter((service) => service.id !== id));
      toast.success('Service deleted successfully!');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to delete service');
    }
  };

  return (
    <div className="services-page">
      <div className="container">
        <h2 className="page-title">Services List</h2>
        <div className="actions">
          <Link to="/admin/services/create" className="btn-primary">
            Add New Service
          </Link>
        </div>
        {loading ? (
          <p className="text-center">Loading...</p>
        ) : services.length === 0 ? (
          <p className="text-center">No services found.</p>
        ) : (
          <div className="table-container">
            <table className="services-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {services.map((service) => (
                  <tr key={service.id}>
                    <td>{service.name}</td>
                    <td>
                      <Link to={`/admin/services/edit/${service.id}`} className="link edit-link">
                        <FaEdit />
                      </Link>
                      <Link onClick={() => handleDelete(service.id)} className="link delete-link">
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

export default ServicesList;
