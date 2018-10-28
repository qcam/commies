import React from "react";
import "./Comment.css";

const Comment = (comment) => {
  return (
    <li className="comment">
      <div className="user">{comment.user.name}</div>
      <div className="content">{comment.content}</div>
    </li>
  );
}

export default Comment;
