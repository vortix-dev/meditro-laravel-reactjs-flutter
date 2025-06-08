import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';

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
    <div className="pt-20 pb-16 min-h-screen bg-gray-100">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          Services List
        </h2>
        <div className="mb-4">
          <Link to="/admin/services/create" className="btn-primary">
            Add New Service
          </Link>
        </div>
        {loading ? (
          <p className="text-center text-gray-600">Loading...</p>
        ) : services.length === 0 ? (
          <p className="text-center text-gray-600">No services found.</p>
        ) : (
          <div className="bg-white shadow-lg rounded-lg overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-blue-500 text-white">
                  <th className="py-3 px-4 text-left">Image</th>
                  <th className="py-3 px-4 text-left">Name</th>
                  <th className="py-3 px-4 text-left">Actions</th>
                </tr>
              </thead>
              <tbody>
                {services.map((service) => (
                  <tr key={service.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4">
                      {service.img && (
                        <img
                          src={service.img}
                          width={100}
                          alt={service.name}
                          className="h-12 w-12 object-cover rounded"
                        />
                      )}
                    </td>
                    <td className="py-3 px-4">{service.name}</td>
                    <td className="py-3 px-4">
                      <Link
                        to={`/admin/services/edit/${service.id}`}
                        className="text-blue-500 hover:text-blue-700 mr-4"
                      >
                        Edit
                      </Link>
                      <button
                        onClick={() => handleDelete(service.id)}
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

export default ServicesList;