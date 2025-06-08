import { Navigate, useLocation } from 'react-router-dom';
import { toast } from 'react-toastify';

function ProtectedRoute({ children, requiredRole }) {
  const token = localStorage.getItem('token');
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  const isAuthenticated = !!token;
  const hasRequiredRole = user?.role === requiredRole;
  const location = useLocation();

  if (!isAuthenticated) {
    toast.error('Please log in to access this page');
    return <Navigate to="/" replace state={{ from: location }} />;
  }

  if (!hasRequiredRole) {
    toast.error(`Only users with "${requiredRole}" role can access this page`);
    return <Navigate to="/" replace state={{ from: location }} />;
  }

  return children;
}

export default ProtectedRoute;