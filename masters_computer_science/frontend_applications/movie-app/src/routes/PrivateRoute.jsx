import React from 'react'
import { Navigate, Outlet } from 'react-router-dom';
import { useAppStateContext } from '../hooks/useAppStateContext';

export const PrivateRoute = () => {
    const {appState} = useAppStateContext();

    return appState?.isAuthenticated && appState?.user ?  <Outlet /> : <Navigate to="/login" />
}

export default PrivateRoute
