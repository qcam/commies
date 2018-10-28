import React from "react";
import "./Comment.scss";

const Comment = (comment) => {
  return (
    <li className="comment">
      <div className="comment__user">{comment.user.name}</div>
      <div className="comment__content">{comment.content}</div>
    </li>
  );
}

export default Comment;
