import React from 'react';
import Sidebar from '../../components/Sidebar';
import { Outlet } from 'react-router-dom';

export const Assistant = () => {
  return (
    <div className="layout-container">
      <Sidebar />
      <main className="layout-content">
        <Outlet />
      </main>
    </div>
  );
};
