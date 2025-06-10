import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import { FaTrash } from 'react-icons/fa';
import './AssistantsList.css'; // تأكد من أن المسار صحيح

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
    <div className="assistants-container">
      <div className="content-wrapper">
        <h2 className="title">Assistants List</h2>
        <div className="actions">
          <Link to="/admin/assistants/create" className="btn">
            Add New Assistant
          </Link>
        </div>
        {loading ? (
          <p className="message">Loading...</p>
        ) : assistants.length === 0 ? (
          <p className="message">No assistants found.</p>
        ) : (
          <div className="table-container">
            <table className="assistants-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {assistants.map((assistant) => (
                  <tr key={assistant.id}>
                    <td>{assistant.name}</td>
                    <td>{assistant.email}</td>
                    <td>
                      <Link onClick={() => handleDelete(assistant.id)}>
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

export default AssistantsList;
