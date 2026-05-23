import { faEye, faEyeSlash } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { useState } from "react";
import { movieApi } from "../constants/axios";
import { userRequests } from "../constants/request";
import { useAppStateContext } from "../hooks/useAppStateContext";

const RegisterForm = () => {
  const { dispatch } = useAppStateContext()

  const [showPass, setShowPass] = useState(false);
  const [message, setMessage] = useState("");
  const [messageType, setMessageType] = useState("");

  const [user, setUser] = useState({
    email: "",
    username: "",
    password: "",
  });

  const togglePassword = (event) => {
    event.preventDefault();

    console.log(showPass);
    setShowPass(!showPass);
  };

  const registerUser = (event) => {
    event.preventDefault()

    if (!user.email || !user.username || !user.password) {
      setMessage("Please fill all required fields")
      setMessageType("error")
    } else {
      movieApi.post(userRequests.register, {
        email: user.email,
        password: user.password,
        username: user.username
      }).then((response) => {
        setMessage("Registration successful! You can now login.")
        setMessageType("success")
        setUser({ email: "", username: "", password: "" })
        dispatch({
          type: "Register",
          payload: {
            email: response.data.email,
            username: response.data.username
          }
        })
      }).catch((error) => {
        setMessage(error.response?.data?.message || "Registration failed")
        setMessageType("error")
      })
    }
  };
  return (
    <div>
      <div className="inputs-container">
        <div className="input-container">
          <label className="email">Email</label>
          <input
            type="email"
            className="email"
            onChange={(e) => setUser({ ...user, email: e.target.value })}
          ></input>
          <div className="input-container">
            <label className="password">Password</label>
            <input
              type={showPass ? "text" : "password"}
              className="password"
              onChange={(e) => setUser({ ...user, password: e.target.value })}
            ></input>
            <span onClick={(e) => togglePassword(e)}>
              <span>
                {showPass ? (
                  <FontAwesomeIcon icon={faEye} className="customIcon" />
                ) : (
                  <FontAwesomeIcon icon={faEyeSlash} className="customIcon" />
                )}
              </span>
            </span>
          </div>
          <div className="inputs-container">
            <div className="input-container">
              <label className="username">Username</label>
              <input
                type="text"
                className="username"
                onChange={(e) => setUser({ ...user, username: e.target.value })}
              ></input>
            </div>
          </div>
          <button className="submit" onClick={(e) => registerUser(e)}>
            submit
          </button>
          <span className="form-message" style={{ color: messageType === "success" ? "green" : "red" }}>
            {message}
          </span>
        </div>
      </div>
    </div>
  );
};

export default RegisterForm;