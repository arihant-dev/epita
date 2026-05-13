const loginForm = () => {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [data, setData] = useState(null);
    const [showpassword, setShowPassword] = useState(false);

    const togglePasswordVisibility = (event) => {
        event.preventDefault();
        setShowPassword(!showpassword);
    }
  return (
    <>
        <span>Login Form</span>
        <label className="email"> Email </label>
        <input type="text" className="email" value={email} onChange={(e) => setEmail(e.target.value)} />
        <label className="password"> Password </label>
        <input type={showpassword ? "text" : "password"} className="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        <button onClick={togglePasswordVisibility}>{showpassword ? "Hide Password" : "Show Password"}</button>
    </>
  )
}

export default loginForm;