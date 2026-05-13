import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAppStateContext } from '../hooks/useAppStateContext';

const PublicRoute = () => {
  const { state } = useAppStateContext();

  return state?.isAuthenticated ? <Navigate to="/home" /> : <Outlet />;
};

export default PublicRoute;