const receiveComments = (state, {comments}) => (
  {...state, comments}
)

const receivePostCommentSuccess = (state, {comment}) => {
  const comments = [...state.comments, comment];
  return {...state, comments};
}

const comments = (state = {}, action) => {
  switch (action.type) {
    case "RECEIVE_COMMENTS":
      return receiveComments(state, action);

    case "RECEIVE_POST_COMMENT_SUCCESS":
      return receivePostCommentSuccess(state, action);

    default:
      return state;
  }
};

export default comments;
