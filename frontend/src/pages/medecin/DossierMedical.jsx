import { useState, useEffect } from 'react';
import { useParams, useNavigate, useLocation } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';

function DossierMedical() {
  const { id } = useParams();
  const navigate = useNavigate();
  const location = useLocation();
  const [dossier, setDossier] = useState(null);
  const [prescriptions, setPrescriptions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    diagnostic: '',
    groupe_sanguin: '',
    poids: '',
    taille: '',
  });
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const medecinId = user?.id;
  const patientId = new URLSearchParams(location.search).get('patient_id');
  const isNewDossier = id === 'new' && patientId;

  useEffect(() => {
    const fetchDossierAndPrescriptions = async () => {
      if (isNewDossier) {
        setLoading(false);
        return;
      }
      setLoading(true);
      try {
        const dossierResponse = await axios.get(`http://localhost:8000/api/medecin/dossier-medicale/${id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        setDossier(dossierResponse.data.data);

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
    if (token && !isNewDossier) {
      fetchDossierAndPrescriptions();
    } else if (!token) {
      toast.error('Please log in again');
    } else {
      setLoading(false);
    }
  }, [id, token, isNewDossier]);

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

  const openCreateModal = () => {
    setIsCreateModalOpen(true);
  };

  const closeCreateModal = () => {
    setIsCreateModalOpen(false);
    setFormData({ diagnostic: '', groupe_sanguin: '', poids: '', taille: '' });
  };

  const handleCreateDossier = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(
        'http://localhost:8000/api/medecin/dossier-medicale',
        {
          medecin_id: medecinId,
          user_id: patientId,
          diagnostic: formData.diagnostic,
          groupe_sanguin: formData.groupe_sanguin,
          poids: parseFloat(formData.poids),
          taille: parseFloat(formData.taille),
        },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setIsCreateModalOpen(false);
      setFormData({ diagnostic: '', groupe_sanguin: '', poids: '', taille: '' });
      toast.success(response.data.message || 'Medical record created successfully!');
      navigate(`/doctor/medical-records/${response.data.data.id}`);
    } catch (error) {
      console.error('Error creating dossier:', error.response);
      if (error.response?.status === 422) {
        Object.values(error.response.data.errors).forEach((err) => toast.error(err[0]));
      } else {
        toast.error(error.response?.data?.message || 'Failed to create medical record');
      }
    }
  };

  if (loading) return <p className="text-center text-gray-600 pt-20">Loading...</p>;

  return (
    <div className="min-h-screen bg-gray-100 flex">
      <Sidebar />
      <div className="flex-1 container mx-auto px-4 pt-20 pb-16 ml-64">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          Medical Dossier
        </h2>
        {isNewDossier ? (
          <div className="bg-white shadow-lg rounded-lg p-6 mb-8 text-center">
            <p className="text-gray-600 mb-4">No medical dossier found for this patient.</p>
            <button
              onClick={openCreateModal}
              className="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600"
            >
              Create Dossier
            </button>
          </div>
        ) : !dossier ? (
          <p className="text-center text-gray-600 pt-20">Dossier not found.</p>
        ) : (
          <>
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
          </>
        )}

        {isCreateModalOpen && (
          <div className="modal-overlay fixed inset-0 bg-black bg-opacity-30 flex justify-center items-center z-50">
            <div className="bg-white rounded-lg p-6 w-full max-w-md">
              <h3 className="text-xl font-semibold text-gray-800 mb-4">Create Medical Dossier</h3>
              <form onSubmit={handleCreateDossier}>
                <div className="mb-4">
                  <label className="block text-gray-700">Diagnosis</label>
                  <input
                    type="text"
                    value={formData.diagnostic}
                    onChange={(e) => setFormData({ ...formData, diagnostic: e.target.value })}
                    className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
                <div className="mb-4">
                  <label className="block text-gray-700">Blood Group</label>
                  <select
                    value={formData.groupe_sanguin}
                    onChange={(e) => setFormData({ ...formData, groupe_sanguin: e.target.value })}
                    className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  >
                    <option value="">Select Blood Group</option>
                    {['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((group) => (
                      <option key={group} value={group}>{group}</option>
                    ))}
                  </select>
                </div>
                <div className="mb-4">
                  <label className="block text-gray-700">Weight (kg)</label>
                  <input
                    type="number"
                    value={formData.poids}
                    onChange={(e) => setFormData({ ...formData, poids: e.target.value })}
                    className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    min="0"
                    required
                  />
                </div>
                <div className="mb-4">
                  <label className="block text-gray-700">Height (cm)</label>
                  <input
                    type="number"
                    value={formData.taille}
                    onChange={(e) => setFormData({ ...formData, taille: e.target.value })}
                    className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    min="0"
                    required
                  />
                </div>
                <div className="flex justify-end space-x-2">
                  <button
                    type="button"
                    onClick={closeCreateModal}
                    className="px-4 py-2 bg-gray-300 text-gray-800 rounded hover:bg-gray-400"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
                  >
                    Create
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

export default DossierMedical;