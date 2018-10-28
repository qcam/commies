const comments = (state = {}, action) => {
  switch (action.type) {
    case "RECEIVE_COMMENTS":
      const { comments } = action;
      return {...state, comments};

    default:
      return state;
  }
};

export default comments;
