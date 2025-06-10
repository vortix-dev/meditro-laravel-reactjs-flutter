import './ServiceCard.css'; // Import the CSS file

function ServiceCard({ service }) {
  return (
    <div className="service-card">
      <img src={service.img} alt={service.name} className="card-image" />
      <div className="card-content">
        <h3 className="card-title">{service.name}</h3>
      </div>
    </div>
  );
}

export default ServiceCard;