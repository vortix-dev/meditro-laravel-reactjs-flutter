// src/routes/ProtectedRoute.jsx
import { Navigate } from "react-router-dom";
import { isAuthenticated } from "../auth";

const ProtectedRoute = ({ children, allowedRoles = [] }) => {
  const user = isAuthenticated();
  
  console.log("Authenticated user:", user);
  console.log("Allowed roles:", allowedRoles);
  if (!user) {
    return <Navigate to="/login" />;
  }

  if (allowedRoles.length > 0 && !allowedRoles.includes(user.role)) {
    return <Navigate to="/unauthorized" />; // صفحة رفض الوصول
  }

  return children;
};

export default ProtectedRoute;
