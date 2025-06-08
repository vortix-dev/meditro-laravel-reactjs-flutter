import { useState, useEffect } from 'react';
import axios from 'axios';
import ServiceCard from '../components/ServiceCard';
import DoctorCard from '../components/DoctorCard';
import { toast } from 'react-toastify';
import { Link } from 'react-router-dom';

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
        toast.success('Data fetched successfully!');
      } catch (error) {
        toast.error('Failed to fetch data');
      }
    };
    fetchData();
  }, []);

  return (
    <div className="pt-20">
      {/* Main Section */}
      <section className="section-bg animate-fade-in" style={{ backgroundImage: "url('https://source.unsplash.com/1600x900/?medical')" }}>
        <div className="container mx-auto px-4">
          <h1 className="text-4xl md:text-5xl font-bold text-gray-800 mb-4">Welcome to Medical Cabinet</h1>
          <p className="text-lg text-gray-600 mb-6">Book your appointment with our top doctors today!</p>
          <Link to={'/booking'} className="btn-primary">Book Appointment</Link>
        </div>
      </section>

      {/* Our Services */}
      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">Our Services</h2>
          <div className="grid-container">
            {services.map((service) => (
              <ServiceCard key={service.id} service={service} />
            ))}
          </div>
        </div>
      </section>

      {/* Our Doctors */}
      <section className="py-16">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center text-gray-800 mb-8 animate-fade-in">Our Doctors</h2>
          <div className="grid-container">
            {doctors.map((doctor) => (
              <DoctorCard key={doctor.id} doctor={doctor} />
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}

export default Home;