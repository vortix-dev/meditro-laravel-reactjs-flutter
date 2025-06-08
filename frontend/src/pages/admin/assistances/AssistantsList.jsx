import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';

function AssistantsList() {
  const [assistants, setAssistants] = useState([]);
  const [loading, setLoading] = useState(false);
  const token = localStorage.getItem('token');

  useEffect(() => {
    const fetchAssistants = async () => {
      setLoading(true);
      try {
        const response = await axios.get('http://localhost:8000/api/admin/assistance', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setAssistants(response.data.data);
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to fetch assistants');
      } finally {
        setLoading(false);
      }
    };
    fetchAssistants();
  }, [token]);

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this assistant?')) return;
    try {
      await axios.delete(`http://localhost:8000/api/admin/assistance/${id}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setAssistants(assistants.filter((assistant) => assistant.id !== id));
      toast.success('Assistant deleted successfully!');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to delete assistant');
    }
  };

  return (
    <div className="pt-20 pb-16 min-h-screen bg-gray-100">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          Assistants List
        </h2>
        <div className="mb-4">
          <Link to="/admin/assistants/create" className="btn-primary">
            Add New Assistant
          </Link>
        </div>
        {loading ? (
          <p className="text-center text-gray-600">Loading...</p>
        ) : assistants.length === 0 ? (
          <p className="text-center text-gray-600">No assistants found.</p>
        ) : (
          <div className="bg-white shadow-lg rounded-lg overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-blue-500 text-white">
                  <th className="py-3 px-4 text-left">Name</th>
                  <th className="py-3 px-4 text-left">Email</th>
                  <th className="py-3 px-4 text-left">Actions</th>
                </tr>
              </thead>
              <tbody>
                {assistants.map((assistant) => (
                  <tr key={assistant.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4">{assistant.name}</td>
                    <td className="py-3 px-4">{assistant.email}</td>
                    <td className="py-3 px-4">

                      <button
                        onClick={() => handleDelete(assistant.id)}
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

export default AssistantsList;