import React, { Component } from "react";
import config from "../config";

class LoginForm extends Component {
  componentDidMount() {
    window.addEventListener("message", event => {
      if (event.origin === config.backend.endpoint) {
        const { type, payload } = event.data;

        switch (type) {
          case "AUTH_SUCCESS":
            return this.props.receiveAuthSuccess(payload);

          case "AUTH_FAILURE":
            return this.props.receiveAuthFailure(payload);

          default:
            console.error("Received unexpected event");
            return false;
        }
      }
    });
  }

  render() {
    const {login, loginGithub} = this.props;

    if (login.user) {
      return (<div>Congrats {login.user.name}, you are logged in!</div>);
    } else {
      return (
        <div className="login-form">
          <a href="#login" onClick={loginGithub}>Login with Github</a>
        </div>
      );
    }
  }
}

export default LoginForm;
