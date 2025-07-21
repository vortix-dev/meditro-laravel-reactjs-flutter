import './ServiceCard.css'; // Import the CSS file

function ServiceCard({ service }) {
  return (
    <div className="service-card">
      <div className="card-content">
        <h3 className="card-title" align="center">{service.name}</h3>
      </div>
    </div>
  );
}

export default ServiceCard;