import { connect } from "react-redux";
import CommentList from "../components/CommentList";
import { fetchComments } from "../actions";

const mapStateToProps = state => {
  return state.comments;
}

const mapDispatchToProps = dispatch => ({
  fetchComments: (linkID, page) => {
    dispatch(fetchComments(linkID, page));
  }
})

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(CommentList);
