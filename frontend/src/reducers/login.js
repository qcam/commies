import config from "../config";

const loginGithub = (state) => {
  const loginURL = config.backend.endpoint + "/oauth/login/github?r=http://localhost:3000";
  const popup = window.open(loginURL, "loginPopup", "width=600,height=300");

  return {...state, popup};
}

const receiveAuthSuccess = (state, action) => {
  const {popup} = state;

  if (popup) {
    popup.close();
  }

  const {token, user} = action;
  return {token, user};
}

const receiveAuthFailure = (state, action) => {
  const {popup} = state;

  if (popup) {
    popup.close();
  }

  console.error("Failed to authenticate user");

  return state;
}

const login = (state = {}, action) => {
  switch (action.type) {
    case "LOGIN_GITHUB":
      return loginGithub(state);

    case "RECEIVE_AUTH_SUCCESS":
      return receiveAuthSuccess(state, action);

    case "RECEIVE_AUTH_FAILURE":
      return receiveAuthFailure(state, action);

    default:
      return state;
  }
};

export default login;
