
function Footer() {
  return (
    <footer className="footer">
      <div className="container">
        <div className="footer-content">
          <div className="footer-section">
            <h3 className="footer-title">Medical Cabinet</h3>
            <p className="footer-description">Providing top-notch healthcare services.</p>
          </div>
          <div className="footer-section">
            <h4 className="footer-subtitle">Quick Links</h4>
            <ul className="footer-links">
              <li><a href="/about" className="footer-link">About Us</a></li>
              <li><a href="/contact" className="footer-link">Contact</a></li>
            </ul>
          </div>
          <div className="footer-section">
            <h4 className="footer-subtitle">Contact Us</h4>
            <p className="footer-contact">Email: contact@medicalcabinet.com</p>
            <p className="footer-contact">Phone: +123 456 7890</p>
          </div>
        </div>
      </div>
    </footer>
  );
}

export default Footer;