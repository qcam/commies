import React from "react";
import config from "../config";

import "./CommentForm.scss";

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
    const infoMessage = "Life is short, don't make it hard.";

    return (
      <form className="comment-form" onSubmit={e => handleSubmit(e, input, props)}
      >
        <textarea className="comment-form__input" ref={node => (input = node)} placeholder="What is your opinion?"></textarea>
        <div className="comment-form__actions">
          <div className="comment-form__info">{infoMessage}</div>
          <button className="comment-form__button">Submit</button>
        </div>
      </form>
    );
  } else {
    return null;
  }
}

export default CommentForm;
