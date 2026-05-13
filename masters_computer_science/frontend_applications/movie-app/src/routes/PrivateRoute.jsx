import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAppStateContext } from '../hooks/useAppStateContext';

export const PrivateRoute = () => {
  const { state } = useAppStateContext();

  return state?.isAuthenticated && state?.user ? <Outlet /> : <Navigate to="/login" />;
};

export default PrivateRoute;