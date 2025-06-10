import { useState, useEffect } from 'react';
import axios from 'axios';
import ServiceCard from '../components/ServiceCard';
import DoctorCard from '../components/DoctorCard';
import { toast } from 'react-toastify';
import { Link } from 'react-router-dom';
import './Home.css'; // Import the CSS file

function Home() {
  const [services, setServices] = useState([]);
  const [doctors, setDoctors] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const servicesRes = await axios.get('http://localhost:8000/api/services');
        const doctorsRes = await axios.get('http://localhost:8000/api/medecins');
        setServices(servicesRes.data.data);
        setDoctors(doctorsRes.data.data);
      } catch (error) {
        toast.error('Failed to fetch data');
      }
    };
    fetchData();
  }, []);

  return (
    <div className="home-container">
      {/* Main Section */}
      <section className="main-section" style={{ backgroundImage: "url('https://source.unsplash.com/1600x900/?medical')" }}>
        <div className="container">
          <h1 className="main-title">Welcome to Medical Cabinet</h1>
          <p className="main-description">Book your appointment with our top doctors today!</p>
          <Link to="/booking" className="btn-primary">Book Appointment</Link>
        </div>
      </section>

      {/* Our Services */}
      <section className="services-section">
        <div className="container">
          <h2 className="section-title">Our Services</h2>
          <div className="grid-container">
            {services.map((service) => (
              <ServiceCard key={service.id} service={service} />
            ))}
          </div>
        </div>
      </section>

      {/* Our Doctors */}
      <section className="doctors-section">
        <div className="container">
          <h2 className="section-title">Our Doctors</h2>
          <div className="grid-container">
            {doctors.map((doctor) => (
              <DoctorCard
                key={doctor.id}
                doctor={doctor}
                serviceName={
                  services.find((s) => s.id === doctor.service_id)?.name || 'General'
                }
              />
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}

export default Home;