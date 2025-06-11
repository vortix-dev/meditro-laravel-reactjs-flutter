import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { toast } from 'react-toastify';
import Sidebar from '../../components/Sidebar';
import './DoctorPatients.css';

function DoctorPatients() {
  const [patients, setPatients] = useState([]);
  const [loading, setLoading] = useState(false);
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const medecinId = user?.id;

  useEffect(() => {
    const fetchPatients = async () => {
      setLoading(true);
      try {
        const patientsResponse = await axios.get('http://localhost:8000/api/medecin/all-my-patient', {
          headers: { Authorization: `Bearer ${token}` },
        });
        setPatients(patientsResponse.data.data);
      } catch (error) {
        console.error('Error fetching patients:', error.response);
        toast.error(error.response?.data?.message || 'Failed to fetch patients');
      } finally {
        setLoading(false);
      }
    };
    if (token && medecinId) {
      fetchPatients();
    } else {
      toast.error('Please log in again');
    }
  }, [token, medecinId]);

  if (loading) return <p className="loading">Loading...</p>;

  return (
    <div className="doctor-patients">
      <Sidebar />
      <div className="content">
        <h2 className="title">Manage Patients</h2>
        {patients.length === 0 ? (
          <p className="no-patients">No patients found.</p>
        ) : (
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Name</th>
                  <th>Sexe</th>
                  <th>Phone</th>
                  <th>Date</th>
                  <th>Time</th>
                  <th>Dossier</th>
                </tr>
              </thead>
                <tbody>
                  {patients.map((patient) => {
                    const doneAppointments = patient.rdv.filter(r => r.status === 'done');
                    if (doneAppointments.length === 0) return null;

                    // اختار آخر موعد (مثلاً حسب التاريخ الأحدث)
                    const latestRdv = doneAppointments.reduce((latest, current) =>
                      new Date(current.date) > new Date(latest.date) ? current : latest
                    );

                    return (
                      <tr key={patient.id}>
                        <td>{patient.id}</td>
                        <td>{patient.name}</td>
                        <td>{patient.sexe}</td>
                        <td>{patient.telephone}</td>
                        <td>{new Date(latestRdv.date).toLocaleDateString()}</td>
                        <td>{latestRdv.heure || 'N/A'}</td>
                        <td>
                          <Link
                            to={`/doctor/medical-records/${patient.id}`}
                            className="btn-dossier"
                          >
                            View Dossier
                          </Link>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}

export default DoctorPatients;
