import React, { Component } from 'react';
import Comment from "./Comment";

class CommentList extends Component {
  componentDidMount() {
    const { linkID } = this.props;
    this.props.fetchComments(linkID, 1);
  }

  render() {
    const { comments } = this.props;

    if (comments.length === 0) {
      return (<div>Be the first to comment</div>);
    } else {
      return comments.map(
        comment => (<Comment key={ comment.id } { ...comment }/>)
      );
    }
  }
}

export default CommentList;
