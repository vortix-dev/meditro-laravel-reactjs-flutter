import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';

function MedicalRecord() {
  const { user_id } = useParams();
  const [dossier, setDossier] = useState(null);
  const [prescriptions, setPrescriptions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isPrescriptionModalOpen, setIsPrescriptionModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    diagnostic: '',
    groupe_sanguin: '',
    poids: '',
    taille: '',
  });
  const [prescriptionFormData, setPrescriptionFormData] = useState({
    date: '',
    medicaments: [{ medicament: '', dosage: '', frequence: '', duree: '' }],
  });
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const medecinId = user?.id;

  useEffect(() => {
    const fetchDossier = async () => {
      setLoading(true);
      try {
        const response = await axios.get(`http://localhost:8000/api/medecin/get-dossier/${user_id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        if (response.data.data.length > 0) {
          const dossierData = response.data.data[0]; // Assuming one dossier per patient
          setDossier(dossierData);
          setFormData({
            diagnostic: dossierData.diagnostic,
            groupe_sanguin: dossierData.groupe_sanguin,
            poids: dossierData.poids,
            taille: dossierData.taille,
          });
          setPrescriptions(dossierData.ordonnance || []);
        }
      } catch (error) {
        console.error('Error fetching dossier:', error.response);
        toast.error(error.response?.data?.message || 'Failed to fetch dossier');
      } finally {
        setLoading(false);
      }
    };
    if (token && user_id) {
      fetchDossier();
    } else {
      toast.error('Please log in again');
    }
  }, [token, user_id]);

  const handleCreateDossier = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(
        'http://localhost:8000/api/medecin/dossier-medicale',
        { ...formData, medecin_id: medecinId, user_id },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setDossier(response.data.data);
      setPrescriptions(response.data.data.ordonnance || []);
      setIsCreateModalOpen(false);
      setFormData({ diagnostic: '', groupe_sanguin: '', poids: '', taille: '' });
      toast.success(response.data.message || 'Dossier created successfully!');
    } catch (error) {
      if (error.response?.status === 422) {
        Object.values(error.response.data.errors).forEach((err) => toast.error(err[0]));
      } else {
        toast.error(error.response?.data?.message || 'Failed to create dossier');
      }
    }
  };

  const handleEditDossier = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.put(
        `http://localhost:8000/api/medecin/dossier-medicale/${user_id}`,
        formData,
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setDossier(response.data.data);
      setIsEditModalOpen(false);
      toast.success(response.data.message || 'Dossier updated successfully!');
    } catch (error) {
      if (error.response?.status === 422) {
        Object.values(error.response.data.errors).forEach((err) => toast.error(err[0]));
      } else {
        toast.error(error.response?.data?.message || 'Failed to update dossier');
      }
    }
  };

  const handleAddMedicament = () => {
    setPrescriptionFormData({
      ...prescriptionFormData,
      medicaments: [...prescriptionFormData.medicaments, { medicament: '', dosage: '', frequence: '', duree: '' }],
    });
  };

  const handleMedicamentChange = (index, field, value) => {
    const updatedMedicaments = prescriptionFormData.medicaments.map((med, i) =>
      i === index ? { ...med, [field]: value } : med
    );
    setPrescriptionFormData({ ...prescriptionFormData, medicaments: updatedMedicaments });
  };

  const handleCreatePrescription = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post(
        'http://localhost:8000/api/medecin/ordonnances',
        { ...prescriptionFormData, dossier_medicale_id: dossier.id, medecin_id: medecinId },
        { headers: { Authorization: `Bearer ${token}` } }
      );
      setPrescriptions([...prescriptions, response.data]);
      setIsPrescriptionModalOpen(false);
      setPrescriptionFormData({ date: '', medicaments: [{ medicament: '', dosage: '', frequence: '', duree: '' }] });
      toast.success(response.data.message || 'Prescription created successfully!');
    } catch (error) {
      if (error.response?.status === 422) {
        Object.values(error.response.data.errors).forEach((err) => toast.error(err[0]));
      } else {
        toast.error(error.response?.data?.message || 'Failed to create prescription');
      }
    }
  };

  const handleDeletePrescription = async (id) => {
    try {
      await axios.delete(`http://localhost:8000/api/medecin/ordonnances/${id}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setPrescriptions(prescriptions.filter((prescription) => prescription.id !== id));
      toast.success('Prescription deleted successfully!');
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to delete prescription');
    }
  };

  const handleDownloadPdf = async (id) => {
    try {
      const response = await axios.get(`http://localhost:8000/api/medecin/ordonnances/${id}/pdf`, {
        headers: { Authorization: `Bearer ${token}` },
        responseType: 'blob',
      });
      const url = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `ordonnance-${id}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
    } catch (error) {
      toast.error(error.response?.data?.message || 'Failed to download PDF');
    }
  };

  if (loading) return <p className="text-center text-gray-600 pt-20">Loading...</p>;

  return (
    <div className="min-h-screen bg-gray-100 flex">
      <Sidebar />
      <div className="flex-1 container mx-auto px-4 pt-20 pb-16 ml-64">
        <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">
          Medical Record
        </h2>
        {!dossier ? (
          <>
            <p className="text-center text-gray-600 mb-4">No medical record found for this patient.</p>
            <button
              onClick={() => setIsCreateModalOpen(true)}
              className="btn-primary mb-6"
            >
              Create Dossier
            </button>
            {isCreateModalOpen && (
              <div className="modal-overlay">
                <div className="bg-white rounded-lg p-6 w-full max-w-md">
                  <h3 className="text-xl font-semibold text-gray-800 mb-4">Create Medical Record</h3>
                  <form onSubmit={handleCreateDossier}>
                    <div className="mb-4">
                      <label className="block text-gray-700">Diagnostic</label>
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
                        required
                        min="0"
                      />
                    </div>
                    <div className="mb-4">
                      <label className="block text-gray-700">Height (cm)</label>
                      <input
                        type="number"
                        value={formData.taille}
                        onChange={(e) => setFormData({ ...formData, taille: e.target.value })}
                        className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                        required
                        min="0"
                      />
                    </div>
                    <div className="flex justify-end space-x-2">
                      <button
                        type="button"
                        onClick={() => setIsCreateModalOpen(false)}
                        className="px-4 py-2 bg-gray-300 text-gray-800 rounded hover:bg-gray-400"
                      >
                        Cancel
                      </button>
                      <button type="submit" className="btn-primary px-4 py-2">
                        Create
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            )}
          </>
        ) : (
          <>
            <div className="max-w-md mx-auto bg-white shadow-lg rounded-lg p-6 mb-8">
              <h3 className="text-xl font-semibold text-gray-800 mb-4">Medical Record Details</h3>
              <p><strong>Diagnostic:</strong> {dossier.diagnostic}</p>
              <p><strong>Blood Group:</strong> {dossier.groupe_sanguin}</p>
              <p><strong>Weight:</strong> {dossier.poids} kg</p>
              <p><strong>Height:</strong> {dossier.taille} cm</p>
              <p><strong>Patient:</strong> {dossier.user?.name || 'N/A'}</p>
              <button
                onClick={() => setIsEditModalOpen(true)}
                className="btn-primary mt-4"
              >
                Edit Dossier
              </button>
            </div>
            {isEditModalOpen && (
              <div className="modal-overlay">
                <div className="bg-white rounded-lg p-6 w-full max-w-md">
                  <h3 className="text-xl font-semibold text-gray-800 mb-4">Edit Medical Record</h3>
                  <form onSubmit={handleEditDossier}>
                    <div className="mb-4">
                      <label className="block text-gray-700">Diagnostic</label>
                      <input
                        type="text"
                        value={formData.diagnostic}
                        onChange={(e) => setFormData({ ...formData, diagnostic: e.target.value })}
                        className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                      />
                    </div>
                    <div className="mb-4">
                      <label className="block text-gray-700">Blood Group</label>
                      <select
                        value={formData.groupe_sanguin}
                        onChange={(e) => setFormData({ ...formData, groupe_sanguin: e.target.value })}
                        className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
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
                      />
                    </div>
                    <div className="flex justify-end space-x-2">
                      <button
                        type="button"
                        onClick={() => setIsEditModalOpen(false)}
                        className="px-4 py-2 bg-gray-300 text-gray-800 rounded hover:bg-gray-400"
                      >
                        Cancel
                      </button>
                      <button type="submit" className="btn-primary px-4 py-2">
                        Update
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            )}
            <div className="bg-white shadow-lg rounded-lg overflow-hidden">
              <div className="flex justify-between items-center p-4">
                <h3 className="text-xl font-semibold text-gray-800">Prescriptions</h3>
                <button
                  onClick={() => setIsPrescriptionModalOpen(true)}
                  className="btn-primary"
                >
                  Add Prescription
                </button>
              </div>
              {prescriptions.length === 0 ? (
                <p className="text-center text-gray-600 p-4">No prescriptions found.</p>
              ) : (
                <table className="w-full">
                  <thead>
                    <tr className="bg-blue-500 text-white">
                      <th className="py-3 px-4 text-left">ID</th>
                      <th className="py-3 px-4 text-left">Date</th>
                      <th className="py-3 px-4 text-left">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {prescriptions.map((prescription) => (
                      <tr key={prescription.id} className="border-b hover:bg-gray-50">
                        <td className="py-3 px-4">{prescription.id}</td>
                        <td className="py-3 px-4">{new Date(prescription.date).toLocaleDateString()}</td>
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
              )}
            </div>
            {isPrescriptionModalOpen && (
              <div className="modal-overlay">
                <div className="bg-white rounded-lg p-6 w-full max-w-md">
                  <h3 className="text-xl font-semibold text-gray-800 mb-4">Add Prescription</h3>
                  <form onSubmit={handleCreatePrescription}>
                    <div className="mb-4">
                      <label className="block text-gray-700">Date</label>
                      <input
                        type="date"
                        value={prescriptionFormData.date}
                        onChange={(e) => setPrescriptionFormData({ ...prescriptionFormData, date: e.target.value })}
                        className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                        required
                      />
                    </div>
                    <div className="mb-4">
                      <h4 className="text-lg font-semibold text-gray-800 mb-2">Medicaments</h4>
                      {prescriptionFormData.medicaments.map((med, index) => (
                        <div key={index} className="mb-2">
                          <input
                            type="text"
                            placeholder="Medicament"
                            value={med.medicament}
                            onChange={(e) => handleMedicamentChange(index, 'medicament', e.target.value)}
                            className="w-full px-3 py-2 mb-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            required
                          />
                          <input
                            type="text"
                            placeholder="Dosage"
                            value={med.dosage}
                            onChange={(e) => handleMedicamentChange(index, 'dosage', e.target.value)}
                            className="w-full px-3 py-2 mb-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            required
                          />
                          <input
                            type="text"
                            placeholder="Frequency"
                            value={med.frequence}
                            onChange={(e) => handleMedicamentChange(index, 'frequence', e.target.value)}
                            className="w-full px-3 py-2 mb-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            required
                          />
                          <input
                            type="text"
                            placeholder="Duration"
                            value={med.duree}
                            onChange={(e) => handleMedicamentChange(index, 'duree', e.target.value)}
                            className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                            required
                          />
                        </div>
                      ))}
                      <button
                        type="button"
                        onClick={handleAddMedicament}
                        className="px-4 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600"
                      >
                        Add Medicament
                      </button>
                    </div>
                    <div className="flex justify-end space-x-2">
                      <button
                        type="button"
                        onClick={() => setIsPrescriptionModalOpen(false)}
                        className="px-4 py-2 bg-gray-300 text-gray-800 rounded hover:bg-gray-400"
                      >
                        Cancel
                      </button>
                      <button type="submit" className="btn-primary px-4 py-2">
                        Create
                      </button>
                    </div>
                  </form>
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}

export default MedicalRecord;