import React, { useState } from "react";
import LoginForm from "../components/login-form";
import "../styles/LoginPage.css";
import { useSpring, animated } from "react-spring";
import RegisterForm from "../components/register-form";
const LoginPage = () => {
  const [registrationFormStatus, setRegistrationFormStatus] = useState(false);

  const loginProps = useSpring({
    left: registrationFormStatus ? -500 : 0,
  });

  const registerProps = useSpring({
    left: registrationFormStatus ? 0 : 500,
  });

  const loginButtonProps = useSpring({
    borderBottom: registrationFormStatus
      ? "solid 0px transparent"
      : "solid 2px white",
  });

  const registerButtonProps = useSpring({
    borderBottom: registrationFormStatus
      ? "solid 2px white"
      : "solid 0px transparent",
  });

  return (
    <div className="container">
      <div className="login-wrapper">
        <div className="nav-buttons">
          <animated.button
            id="loginButton"
            onClick={() => setRegistrationFormStatus(false)}
            style={loginButtonProps}
          >
            Login
          </animated.button>
          <animated.button
            id="registerButton"
            onClick={() => setRegistrationFormStatus(true)}
            style={registerButtonProps}
          >
            Register
          </animated.button>
        </div>
        <div className="form-group">
          <animated.form action="" id="loginform" style={loginProps}>
            <LoginForm />
          </animated.form>
          <animated.form action="" id="registerform" style={registerProps}>
            <RegisterForm />
          </animated.form>
        </div>
      </div>
    </div>
  );
};

export default LoginPage;