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
        responseType: 'blob',
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
    <div className="medical-record">
      <div className="container-medical-record">
        <h2 className="title">My Medical Record</h2>
        {loading ? (
          <p className="loading">Loading...</p>
        ) : records.length === 0 ? (
          <p className="empty">No medical records found.</p>
        ) : (
          <div className="grid-container">
            {records.map((record) => (
              <div key={record.id} className="card">
                <div className="card-content">
                  <h3 className="card-title">
                    Doctor: {record.medecin?.name || 'N/A'}
                  </h3>
                  <p className="card-text"><strong>Diagnosis:</strong> {record.diagnostic}</p>
                  <p className="card-text"><strong>Blood Group:</strong> {record.groupe_sanguin}</p>
                  <p className="card-text"><strong>Weight:</strong> {record.poids} kg</p>
                  <p className="card-text"><strong>Height:</strong> {record.taille} cm</p>
                  {record.ordonnance && record.ordonnance.length > 0 && (
                    <div>
                      <h4 className="prescriptions-title">Prescriptions</h4>
                      {record.ordonnance.map((prescription) => (
                        <div key={prescription.id} className="prescription-item">
                          Date: {prescription.date} &nbsp;
                          <button
                            onClick={() => handleDownloadPrescription(prescription.id)}
                            className="download-button"
                          >
                            Download PDF
                          </button>
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
