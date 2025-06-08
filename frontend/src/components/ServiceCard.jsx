function ServiceCard({ service }) {
  return (
    <div className="bg-white shadow-lg rounded-lg overflow-hidden transform hover:scale-105 transition">
      <img src={service.img} alt={service.name} className="w-full h-48 object-cover" />
      <div className="p-4">
        <h3 className="text-xl font-semibold text-gray-800">{service.name}</h3>
      </div>
    </div>
  );
}

export default ServiceCard;