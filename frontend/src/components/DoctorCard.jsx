function DoctorCard({ doctor }) {
  return (
    <div className="bg-white shadow-lg rounded-lg overflow-hidden transform hover:scale-105 transition">
      <img src="https://source.unsplash.com/300x300/?doctor" alt={doctor.name} className="w-full h-48 object-cover" />
      <div className="p-4">
        <h3 className="text-xl font-semibold text-gray-800">{doctor.name}</h3>
        <p className="text-gray-600">{doctor.service_id ? `Specialty: ${doctor.service_id}` : 'General'}</p>
      </div>
    </div>
  );
}

export default DoctorCard;