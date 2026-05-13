import React, { Component } from 'react'

const INITIAL_STATE = {
    isAuthenticated: localStorage.getItem('user') ? true : false,
    user: JSON.parse(localStorage.getItem('user')) || null,
    token: localStorage.getItem('token') || null,
}

export const AppStateContext = createContext(INITIAL_STATE);
export const AppStateProvider = ({ children }) => {
  const [state, dispatch] = useReducer(AppStateReducer, INITIAL_STATE);

  return (
    <AppStateContext.Provider value={{ state, dispatch }}>
      {children}
    </AppStateContext.Provider>
  );
};

export default AppStateProvider;
