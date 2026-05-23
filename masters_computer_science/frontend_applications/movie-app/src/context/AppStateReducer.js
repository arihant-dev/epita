export const AppStateReducer = (state, action) => {
  switch (action.type) {
    case 'LOGIN':
      const userData = { ...action.payload.user, token: action.payload.token };
      localStorage.setItem('user', JSON.stringify(userData));
      return {
        ...state,
        isAuthenticated: true,
        user: userData,
        token: action.payload.token,
      };

    case 'LOGOUT':
      localStorage.removeItem('user');
      return {
        ...state,
        isAuthenticated: false,
        user: null,
        token: null,
      };

    default:
      return state;
  }
};

export default AppStateReducer;