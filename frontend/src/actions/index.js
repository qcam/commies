import Backend from "../services/backend.js";

export const fetchComments = (linkID, page) => (
  dispatch => (
    Backend.fetchComments(linkID, page).then(
      comments => dispatch(receiveComments(comments)),
      _error => {}
    )
  )
);

export const postComment = (linkID, token, content) => (
  dispatch => (
    Backend.postComment(linkID, token, content).then(
      comment => dispatch(receivePostCommentSuccess(comment)),
      _error => {}
    )
  )
);

const receiveComments = (comments) => ({
  type: "RECEIVE_COMMENTS",
  comments: comments
})

const receivePostCommentSuccess = (comment) => ({
  type: "RECEIVE_POST_COMMENT_SUCCESS",
  comment: comment
})

export const loginGithub = () => ({
  type: "LOGIN_GITHUB"
})

export const receiveAuthSuccess = ({user, token}) => ({
  type: "RECEIVE_AUTH_SUCCESS",
  user: user,
  token: token
})

export const receiveAuthFailure = ({errors}) => ({
  type: "RECEIVE_AUTH_FAILURE",
  errors: errors
})
