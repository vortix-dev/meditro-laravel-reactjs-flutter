import doctorImage from '../assets/doctor.jpg'; // تأكد من صحة المسار
import './DoctorCard.css';

function DoctorCard({ doctor, serviceName }) {
  return (
    <div className="doctor-card">
      <div className="card-content">
        <img src={doctorImage} alt="Doctor" className="card-image" />
        <h3 className="card-title">{doctor.name}</h3>
        <p className="card-description">Specialty: {serviceName}</p>
      </div>
    </div>
  );
}

export default DoctorCard;
