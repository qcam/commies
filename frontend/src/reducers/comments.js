const comments = (state = {comments: []}, action) => {
  switch (action.type) {
    case "RECEIVE_COMMENTS":
      const { comments } = action;
      return {comments: comments};

    default:
      return state;
  }
};

export default comments;
