import { useState, useEffect } from 'react';
import axios from 'axios';
import { toast } from 'react-toastify';

function MedicalRecord() {
  const [records, setRecords] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const fetchRecords = async () => {
      setLoading(true);
      try {
        const token = localStorage.getItem('token');
        const response = await axios.get('http://localhost:8000/api/user/dossier-medical', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setRecords(response.data.data);
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to fetch medical records');
      } finally {
        setLoading(false);
      }
    };
    fetchRecords();
  }, []);

  const handleDownloadPrescription = async (ordonnanceId) => {
    try {
      const token = localStorage.getItem('token');
      const response = await axios.get(`http://localhost:8000/api/user/ordonnances/${ordonnanceId}/pdf`, {
        headers: { Authorization: `Bearer ${token}` },
        responseType: 'blob', // For handling PDF
      });
      const url = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `ordonnance-${ordonnanceId}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      toast.success('Prescription downloaded successfully!');
    } catch (error) {
      toast.error('Failed to download prescription');
    }
  };

  return (
    <div className="pt-20 pb-16 min-h-screen bg-gray-100">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          My Medical Record
        </h2>
        {loading ? (
          <p className="text-center text-gray-600">Loading...</p>
        ) : records.length === 0 ? (
          <p className="text-center text-gray-600">No medical records found.</p>
        ) : (
          <div className="grid-container">
            {records.map((record) => (
              <div key={record.id} className="card">
                <div className="p-6">
                  <h3 className="text-xl font-semibold text-gray-800 mb-2">
                    Doctor: {record.medecin?.name || 'N/A'}
                  </h3>
                  <p className="text-gray-600 mb-1"><strong>Diagnosis:</strong> {record.diagnostic}</p>
                  <p className="text-gray-600 mb-1"><strong>Blood Group:</strong> {record.groupe_sanguin}</p>
                  <p className="text-gray-600 mb-1"><strong>Weight:</strong> {record.poids} kg</p>
                  <p className="text-gray-600 mb-4"><strong>Height:</strong> {record.taille} cm</p>
                  {record.ordonnance && record.ordonnance.length > 0 && (
                    <div>
                      <h4 className="text-lg font-semibold text-gray-800 mb-2">Prescriptions</h4>
                      {record.ordonnance.map((prescription) => (
                        <div key={prescription.id} className="mb-2">
                          <p className="text-gray-600">
                            Date: {prescription.date}
                            <button
                              onClick={() => handleDownloadPrescription(prescription.id)}
                              className="ml-4 text-blue-500 hover:text-blue-700"
                            >
                              Download PDF
                            </button>
                          </p>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default MedicalRecord;