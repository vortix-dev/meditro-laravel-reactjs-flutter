function Footer() {
  return (
    <footer className="bg-gray-800 text-white py-8">
      <div className="container mx-auto px-4">
        <div className="flex flex-col md:flex-row justify-between items-center">
          <div>
            <h3 className="text-lg font-semibold">Medical Cabinet</h3>
            <p className="mt-2">Providing top-notch healthcare services.</p>
          </div>
          <div className="mt-4 md:mt-0">
            <h4 className="text-md font-semibold">Quick Links</h4>
            <ul className="mt-2 space-y-1">
              <li><a href="/about" className="hover:text-blue-300">About Us</a></li>
              <li><a href="/contact" className="hover:text-blue-300">Contact</a></li>
            </ul>
          </div>
          <div className="mt-4 md:mt-0">
            <h4 className="text-md font-semibold">Contact Us</h4>
            <p className="mt-2">Email: contact@medicalcabinet.com</p>
            <p>Phone: +123 456 7890</p>
          </div>
        </div>
      </div>
    </footer>
  );
}

export default Footer;