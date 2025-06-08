import { useState, useEffect } from 'react';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';

function Prescriptions() {
  const [prescriptions, setPrescriptions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    dossier_medicale_id: '',
    date: '',
    medicaments: [{ medicament: '', dosage: '', frequence: '', duree: '' }],
  });
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    const id = user.id;
    const token = localStorage.getItem('token');

  useEffect(() => {
    const fetchPrescriptions = async () => {
      setLoading(true);
      try {
        const response = await axios.get(`http://localhost:8000/api/medecin/ordonnance/${id}`, {
          headers: { Authorization: `Bearer ${token}` },
        });
        setPrescriptions(response.data);
      } catch (error) {
        toast.error(error.response?.data?.message || 'Failed to fetch prescriptions');
      } finally {
        setLoading(false);
      }
    };
    if (token) {
      fetchPrescriptions();
    }
  }, [token]);

  const handleAddMedicament = () => {
    setFormData({
      ...formData,
      medicaments: [...formData.medicaments, { medicament: '', dosage: '', frequence: '', duree: '' }],
    });
  };

  const handleMedicamentChange = (index, field, value) => {
    const updatedMedicaments = formData.medicaments.map((med, i) =>
      i === index ? { ...med, [field]: value } : med
    );
    setFormData({ ...formData, medicaments: updatedMedicaments });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const response = await axios.post('http://localhost:8000/api/medecin/ordonnances', formData, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setPrescriptions([...prescriptions, response.data]);
      setIsModalOpen(false);
      setFormData({
        dossier_medicale_id: '',
        date: '',
        medicaments: [{ medicament: '', dosage: '', frequence: '', duree: '' }],
      });
      toast.success('Prescription created successfully!');
    } catch (error) {
      if (error.response?.status === 422) {
        const errors = error.response.data.errors;
        Object.values(errors).forEach((err) => toast.error(err[0]));
      } else {
        toast.error(error.response?.data?.message || 'Failed to create prescription');
      }
    }
  };

  const handleDelete = async (id) => {
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
          Manage Prescriptions
        </h2>
        <button
          onClick={() => setIsModalOpen(true)}
          className="btn-primary mb-6"
        >
          Create New Prescription
        </button>
        {prescriptions.length === 0 ? (
          <p className="text-center text-gray-600">No prescriptions found.</p>
        ) : (
          <div className="bg-white shadow-lg rounded-lg overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-blue-500 text-white">
                  <th className="py-3 px-4 text-left">ID</th>
                  <th className="py-3 px-4 text-left">Patient</th>
                  <th className="py-3 px-4 text-left">Date</th>
                  <th className="py-3 px-4 text-left">Actions</th>
                </tr>
              </thead>
              <tbody>
                {prescriptions.map((prescription) => (
                  <tr key={prescription.id} className="border-b hover:bg-gray-50">
                    <td className="py-3 px-4">{prescription.id}</td>
                    <td className="py-3 px-4">{prescription.dossierMedicale?.user?.name || 'N/A'}</td>
                    <td className="py-3 px-4">{new Date(prescription.date).toLocaleDateString()}</td>
                    <td className="py-3 px-4">
                      <button
                        onClick={() => handleDownloadPdf(prescription.id)}
                        className="px-2 py-1 bg-blue-500 text-white rounded mr-2 hover:bg-blue-600"
                      >
                        Download PDF
                      </button>
                      <button
                        onClick={() => handleDelete(prescription.id)}
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

        {isModalOpen && (
          <div className="modal-overlay">
            <div className="bg-white rounded-lg p-6 w-full max-w-md">
              <h3 className="text-xl font-semibold text-gray-800 mb-4">Create Prescription</h3>
              <form onSubmit={handleSubmit}>
                <div className="mb-4">
                  <label className="block text-gray-700">Medical Record ID</label>
                  <input
                    type="number"
                    value={formData.dossier_medicale_id}
                    onChange={(e) => setFormData({ ...formData, dossier_medicale_id: e.target.value })}
                    className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
                <div className="mb-4">
                  <label className="block text-gray-700">Date</label>
                  <input
                    type="date"
                    value={formData.date}
                    onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                    className="w-full px-3 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    required
                  />
                </div>
                <div className="mb-4">
                  <h4 className="text-lg font-semibold text-gray-800 mb-2">Medicaments</h4>
                  {formData.medicaments.map((med, index) => (
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
                        className="w-full px-3 py-2 mb-2 border rounded-lg focus:outline-none focus:ring"
                        required
                      />
                      <input
                        type="text"
                        placeholder="Frequency"
                        value={med.frequence}
                        onChange={(e) => handleMedicamentChange(index, 'frequence', e.target.value)}
                        className="w-full px-3 py-2 mb-2 border rounded-lg focus:outline-none focus:ring-2"
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
                    onClick={() => setIsModalOpen(false)}
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
      </div>
    </div>
  );
}

export default Prescriptions;