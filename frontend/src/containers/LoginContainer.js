import { connect } from "react-redux";
import LoginForm from "../components/LoginForm";
import { loginGithub, receiveAuthSuccess, receiveAuthFailure } from "../actions";

const mapStateToProps = state => {
  return state.login;
}

const mapDispatchToProps = dispatch => ({
  loginGithub: () => dispatch(loginGithub()),
  receiveAuthSuccess: (payload) => dispatch(receiveAuthSuccess(payload)),
  receiveAuthFailure: (payload) => dispatch(receiveAuthFailure(payload))
})

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(LoginForm);
