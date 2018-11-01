import React from "react";
import "./Comment.scss";

const formatDateTime = (iso8601) => {
  const date = Date.parse(iso8601);
  const options = {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric"
  };

  return (new Date(date)).toLocaleDateString("en-GB", options);
}

const Comment = (comment) => {
  return (
    <li className="comment">
      <div className="comment__avatar">
        <a className="comment__avatar__link" href="#">
          <img className="comment__avatar__photo" src={comment.user.avatar_url}/>
        </a>
      </div>
      <div className="comment__content">
        <div className="comment__user">{comment.user.name}</div>
        <div className="comment__meta">{formatDateTime(comment.inserted_at)}</div>
        <div className="comment__text">{comment.content}</div>
      </div>
    </li>
  );
}

export default Comment;
