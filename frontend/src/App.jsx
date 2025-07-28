import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import Booking from './pages/Booking';
import Header from './components/Header';
import Footer from './components/Footer';
import ProtectedRoute from './components/ProtectedRoute';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import MyAppointments from './pages/MyAppointments';
import MedicalRecord from './pages/MedicalRecord';
import AdminDashboard from './pages/admin/AdminDashboard';
import ServicesList from './pages/admin/services/ServicesList';
import CreateService from './pages/admin/services/CreateService';
import DoctorsList from './pages/admin/medecins/DoctorsList';
import CreateDoctor from './pages/admin/medecins/CreateDoctor';
import AssistantsList from './pages/admin/assistances/AssistantsList';
import CreateAssistant from './pages/admin/assistances/CreateAssistant';
import { Assistant } from './pages/assistance/Assistant';
import AssistantProfile from './pages/assistance/AssistantProfile';
import AssistantAppointments from './pages/assistance/AssistantAppointments';
import DoctorDashboard from './pages/medecin/DoctorDashboard';
import DoctorProfile from './pages/medecin/DoctorProfile';
import DoctorAppointments from './pages/medecin/DoctorAppointments';
import DoctorPatients from './pages/medecin/DoctorPatients';
import MedicalRecordDoctor from './pages/medecin/MedicalRecord';
import EditService from './pages/admin/services/EditService';

function App() {
  return (
    <Router>
        <Header />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route
            path="/booking"
            element={
              <ProtectedRoute requiredRole="user">
                <Booking />
              </ProtectedRoute>
            }
          />
          <Route
            path="/my-appointments"
            element={
              <ProtectedRoute requiredRole="user">
                <MyAppointments />
              </ProtectedRoute>
            }
          />
          <Route
            path="/medical-record"
            element={
              <ProtectedRoute requiredRole="user">
                <MedicalRecord />
              </ProtectedRoute>
            }
          />
          <Route
            path="/admin"
            element={
              <ProtectedRoute requiredRoute="/admin/services" requiredRole="admin">
                <AdminDashboard />
              </ProtectedRoute>
            }
          >
            <Route path="services" element={<ServicesList />} />
            <Route path="services/create" element={<CreateService />} />
            <Route path="services/edit/:id" element={<EditService />} />
            <Route path="doctors" element={<DoctorsList />} />
            <Route path="doctors/create" element={<CreateDoctor />} />
            <Route path="assistants" element={<AssistantsList />} />
            <Route path="assistants/create" element={<CreateAssistant />} />
          </Route>
          <Route
            path="/assistant"
            element={
              <ProtectedRoute requiredRoute="/assistant/profile" requiredRole="assistance">
                <Assistant />
              </ProtectedRoute>
            }
          >
            <Route path="profile" element={<AssistantProfile />} />
            <Route path="appointments" element={<AssistantAppointments />} />
          </Route>
          <Route
            path="/doctor"
            element={
              <ProtectedRoute requiredRole="medecin">
                <DoctorDashboard />
              </ProtectedRoute>
            }
          />
          <Route
            path="/doctor/profile"
            element={
              <ProtectedRoute requiredRole="medecin">
                <DoctorProfile />
              </ProtectedRoute>
            }
          />
          <Route
            path="/doctor/appointments"
            element={
              <ProtectedRoute requiredRole="medecin">
                <DoctorAppointments />
              </ProtectedRoute>
            }
          />
          <Route
            path="/doctor/patients"
            element={
              <ProtectedRoute requiredRole="medecin">
                <DoctorPatients />
              </ProtectedRoute>
            }
          />
          <Route
            path="/doctor/medical-records/:user_id"
            element={
              <ProtectedRoute requiredRole="medecin">
                <MedicalRecordDoctor />
              </ProtectedRoute>
            }
          />
        </Routes>
        <Footer />
        <ToastContainer position="top-right" autoClose={3000} />
    </Router>
  );
}

export default App;