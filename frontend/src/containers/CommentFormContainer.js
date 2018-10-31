import { connect } from "react-redux";
import CommentForm from "../components/CommentForm";
import { postComment } from "../actions";

const mapStateToProps = state => {
  console.log(state);
  return {
    login: state.login,
    linkID: state.comments.linkID
  };
}

const mapDispatchToProps = dispatch => ({
  postComment: (linkID, token, content) => {
    dispatch(postComment(linkID, token, content));
  }
})

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(CommentForm);
