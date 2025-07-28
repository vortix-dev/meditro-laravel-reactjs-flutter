import { useState, useEffect } from 'react';
import axios from 'axios';
import { Link, useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import ServiceCard from '../components/ServiceCard';
import DoctorCard from '../components/DoctorCard';
import forme5 from "../assets/imgForm/forme5.png";
import forme4 from "../assets/imgForm/forme4.png";
import forme3 from "../assets/imgForm/forme3.png";
import forme2 from "../assets/imgForm/forme2.png";
import forme1 from "../assets/imgForm/forme1.png";
import doctor from "../assets/imgDoctor/DoctorHeader.png";

function Home() {
  const [services, setServices] = useState([]);
  const [doctors, setDoctors] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isBookButtonPressed, setIsBookButtonPressed] = useState(false);
  const [selectedIndex, setSelectedIndex] = useState(0);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchData = async () => {
      setIsLoading(true);
      try {
        const token = localStorage.getItem('token'); // Assuming token is stored in localStorage
        const headers = { Authorization: `Bearer ${token}` };

        const servicesRes = await axios.get('http://localhost:8000/api/services', { headers });
        const doctorsRes = await axios.get('http://localhost:8000/api/medecins', { headers });

        setServices(servicesRes.data.data);
        setDoctors(doctorsRes.data.data);
      } catch (error) {
        toast.error('Failed to fetch data');
      } finally {
        setIsLoading(false);
      }
    };
    fetchData();
  }, []);

  const handleNavItemClick = (index) => {
    setSelectedIndex(index);
    if (index === 0) {
      navigate('/'); // Home
    } else if (index === 1) {
      navigate('/booking', { state: { services } }); // Pass services as state
    } else if (index === 2) {
      navigate('/profile');
    }
  };

  return (
    <div className="home-container">
      {/* Background Image */}
      <div className="background-image" style={{ backgroundImage: "url('/assets/Backgroundelapps.jpg')" }}></div>

      {/* Decorative Shapes */}
      <img src={forme5} alt="Shape 1" className="shape shape-top-left" />
      <img src={forme4} alt="Shape 2" className="shape shape-top-right" />
      <img src={forme1} alt="Shape 3" className="shape shape-bottom-left" />
      <img src={forme3} alt="Shape 4" className="shape shape-bottom-right" />
      <img src={forme2} alt="Shape 5" className="shape shape-bottom-left2" />

      {/* AppBar */}
      

      {/* Main Content */}
      <div className="safe-area">
        {isLoading ? (
          <div className="loading">Loading...</div>
        ) : (
          <div className="content">
            {/* Central Image */}
            <div className="central-image-container">
              <img src={doctor} alt="Doctor Header" className="central-image" />
            </div>

            {/* Title */}
            <h1 className="main-title">Votre santé Mérite Tout Notre Attention</h1>

            {/* Description */}
            <p className="main-description">
              Bienvenue sur Meditro, votre application de prise de rendez-vous simple et rapide avec notre cabinet médical.
              En quelques clics, choisissez le créneau qui vous convient et recevez un rappel avant votre consultation.
              Plus besoin d’attendre au téléphone — Meditro vous simplifie la santé, avec attention et proximité.
            </p>

            {/* Book Appointment Button */}
            <div
              className={`book-button ${isBookButtonPressed ? 'pressed' : ''}`}
              onMouseDown={() => setIsBookButtonPressed(true)}
              onMouseUp={() => setIsBookButtonPressed(false)}
              onMouseLeave={() => setIsBookButtonPressed(false)}
            >
              <Link to="/booking" state={{ services }} className="book-button-link">
                Demander un Rendez-vous
              </Link>
            </div>

            {/* Services Section */}
            <section className="services-section">
              <h2 className="section-title">Services</h2>
              <div className="horizontal-scroll">
                {services.map((service) => (
                  <ServiceCard key={service.id} service={service} />
                ))}
              </div>
            </section>

            {/* Doctors Section */}
            <section className="doctors-section">
              <h2 className="section-title">Doctors</h2>
              <div className="horizontal-scroll">
                {doctors.map((doctor) => (
                  <DoctorCard
                    key={doctor.id}
                    doctor={doctor}
                    serviceName={services.find((s) => s.id === doctor.service_id)?.name || 'Unknown'}
                  />
                ))}
              </div>
            </section>
          </div>
        )}
      </div>

    </div>
  );
}

export default Home;