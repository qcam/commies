import Backend from "../services/backend.js";

export const fetchComments = (linkID, page) => (
  dispatch => (
    Backend.fetchComments(linkID, page).then(
      comments => dispatch(receiveComments(comments)),
      _error => {}
    )
  )
);

const receiveComments = (comments) => ({
  type: "RECEIVE_COMMENTS",
  comments: comments
})
