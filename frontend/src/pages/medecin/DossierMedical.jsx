import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';

function DossierMedical() {
  const { id } = useParams();
  const [dossier, setDossier] = useState(null);
  const [prescriptions, setPrescriptions] = useState([]);
  const [loading, setLoading] = useState(false);
  const token = localStorage.getItem('token');

  useEffect(() => {
    const fetchDossierAndPrescriptions = async () => {
      setLoading(true);
      try {
        // Fetch dossier medical
        const dossierResponse = await axios.get(`http://localhost:8000/api/medecin/dossier-medicale/${id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        setDossier(dossierResponse.data.data);

        // Fetch prescriptions for this dossier
        const prescriptionsResponse = await axios.get(`http://localhost:8000/api/medecin/ordonnances/${id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        setPrescriptions(prescriptionsResponse.data);
      } catch (error) {
        console.error('Error fetching data:', error.response);
        toast.error(error.response?.data?.message || 'Failed to load dossier or prescriptions');
      } finally {
        setLoading(false);
      }
    };
    if (token) {
      fetchDossierAndPrescriptions();
    } else {
      toast.error('Please log in again');
    }
  }, [id, token]);

  const handleDeletePrescription = async (prescriptionId) => {
    try {
      await axios.delete(`http://localhost:8000/api/medecin/ordonnances/${prescriptionId}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setPrescriptions(prescriptions.filter((p) => p.id !== prescriptionId));
      toast.success('Prescription deleted successfully!');
    } catch (error) {
      console.error('Error deleting prescription:', error.response);
      toast.error(error.response?.data?.message || 'Failed to delete prescription');
    }
  };

  const handleDownloadPdf = async (prescriptionId) => {
    try {
      const response = await axios.get(`http://localhost:8000/api/medecin/ordonnances/${prescriptionId}/pdf`, {
        headers: { Authorization: `Bearer ${token}` },
        responseType: 'blob',
      });
      const url = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `ordonnance-${prescriptionId}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      toast.success('PDF downloaded successfully!');
    } catch (error) {
      console.error('Error downloading PDF:', error.response);
      toast.error(error.response?.data?.message || 'Failed to download PDF');
    }
  };

  if (loading) return <p className="text-center text-gray-600 pt-20">Loading...</p>;
  if (!dossier) return <p className="text-center text-gray-600 pt-20">Dossier not found.</p>;

  return (
    <div className="min-h-screen bg-gray-100 flex">
      <Sidebar />
      <div className="flex-1 container mx-auto px-4 pt-20 pb-16 ml-64">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          Medical Dossier
        </h2>
        <div className="bg-white shadow-lg rounded-lg p-6 mb-8">
          <h3 className="text-xl font-semibold text-gray-800 mb-4">Dossier Details</h3>
          <p><strong>Patient:</strong> {dossier.user?.name || 'N/A'}</p>
          <p><strong>Doctor:</strong> {dossier.medecin?.name || 'N/A'}</p>
          <p><strong>Diagnosis:</strong> {dossier.diagnostic}</p>
          <p><strong>Blood Group:</strong> {dossier.groupe_sanguin}</p>
          <p><strong>Weight:</strong> {dossier.poids} kg</p>
          <p><strong>Height:</strong> {dossier.taille} cm</p>
        </div>
        <h3 className="text-xl font-semibold text-gray-800 mb-4">Prescriptions</h3>
        {prescriptions.length === 0 ? (
          <p className="text-center text-gray-600">No prescriptions found for this dossier.</p>
        ) : (
          <div className="bg-white shadow-lg rounded-lg overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-blue-500 text-white">
                  <th className="py-3 px-4 text-left">ID</th>
                  <th className="py-3 px-4 text-left">Date</th>
                  <th className="py-3 px-4 text-left">Medicaments</th>
                  <th className="py-3 px-4 text-left">Actions</th>
                </tr>
              </thead>
              <tbody>
                {prescriptions.map((prescription) => (
                  <tr key={prescription.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4">{prescription.id}</td>
                    <td className="py-3 px-4">{new Date(prescription.date).toLocaleDateString()}</td>
                    <td className="py-3 px-4">
                      {prescription.details.map((detail, index) => (
                        <div key={index}>
                          {detail.medicament} ({detail.dosage}, {detail.frequence}, {detail.duree})
                        </div>
                      ))}
                    </td>
                    <td className="py-3 px-4">
                      <button
                        onClick={() => handleDownloadPdf(prescription.id)}
                        className="px-2 py-1 bg-blue-500 text-white rounded mr-2 hover:bg-blue-600"
                      >
                        Download PDF
                      </button>
                      <button
                        onClick={() => handleDeletePrescription(prescription.id)}
                        className="px-2 py-1 bg-red-500 text-white rounded hover:bg-red-600"
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

export default DossierMedical;