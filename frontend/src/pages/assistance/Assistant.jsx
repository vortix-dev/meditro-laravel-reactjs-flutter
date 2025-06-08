import React from 'react'
import Sidebar from '../../components/Sidebar'
import { Outlet } from 'react-router-dom'

export const Assistant = () => {
  return (
        <div className="flex min-h-screen">
            <Sidebar />
            <main className="flex-1 p-6 bg-gray-100">
                <Outlet />
            </main>
        </div>
  )
}
