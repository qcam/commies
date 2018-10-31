import React from "react";
import config from "../config";

const handleSubmit = (e, input, props) => {
  e.preventDefault();

  if (!input.value.trim()) {
    return
  }

  const {login, postComment, linkID} = props;
  const {token} = login;

  postComment(linkID, token, input.value);
  input.value = "";
}

const CommentForm = (props) => {
  const {user} = props.login;

  if (user) {
    let input;

    return (
      <form onSubmit={e => handleSubmit(e, input, props)}
      >
        <textarea ref={node => (input = node)} placeholder="post-your-comment here"></textarea>
        <button>Submit</button>
      </form>
    );
  } else {
    return null;
  }
}

export default CommentForm;
