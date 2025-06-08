import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';

function MedicalRecords() {
  const [records, setRecords] = useState([]);
  const [loading, setLoading] = useState(false);
  const token = localStorage.getItem('token');

  useEffect(() => {
    const fetchRecords = async () => {
      setLoading(true);
      try {
        const response = await axios.get('http://localhost:8000/api/medecin/dossier-medicale', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setRecords(response.data.data);
      } catch (error) {
        console.error('Error fetching records:', error.response);
        toast.error(error.response?.data?.message || 'Failed to fetch medical records');
      } finally {
        setLoading(false);
      }
    };
    if (token) {
      fetchRecords();
    } else {
      toast.error('Please log in again');
    }
  }, [token]);

  if (loading) return <p className="text-center text-gray-600 pt-20">Loading...</p>;

  return (
    <div className="min-h-screen bg-gray-100 flex">
      <Sidebar />
      <div className="flex-1 container mx-auto px-4 pt-20 pb-16 ml-64">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          Medical Records
        </h2>
        {records.length === 0 ? (
          <p className="text-center text-gray-600">No medical records found.</p>
        ) : (
          <div className="bg-white shadow-lg rounded-lg overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-blue-500 text-white">
                  <th className="py-3 px-4 text-left">ID</th>
                  <th className="py-3 px-4 text-left">Patient</th>
                  <th className="py-3 px-4 text-left">Diagnosis</th>
                  <th className="py-3 px-4 text-left">Blood Group</th>
                  <th className="py-3 px-4 text-left">Weight (kg)</th>
                  <th className="py-3 px-4 text-left">Height (cm)</th>
                  <th className="py-3 px-4 text-left">Actions</th>
                </tr>
              </thead>
              <tbody>
                {records.map((record) => (
                  <tr key={record.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4">{record.id}</td>
                    <td className="py-3 px-4">{record.user?.name || 'N/A'}</td>
                    <td className="py-3 px-4">{record.diagnostic}</td>
                    <td className="py-3 px-4">{record.groupe_sanguin}</td>
                    <td className="py-3 px-4">{record.poids}</td>
                    <td className="py-3 px-4">{record.taille}</td>
                    <td className="py-3 px-4">
                      <Link
                        to={`/doctor/medical-records/${record.id}`}
                        className="px-2 py-1 bg-blue-500 text-white rounded hover:bg-blue-600"
                      >
                        View Dossier
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

export default MedicalRecords;