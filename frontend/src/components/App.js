import React from "react";
import LoginContainer from "../containers/LoginContainer";
import CommentContainer from "../containers/CommentContainer";
import CommentFormContainer from "../containers/CommentFormContainer";

const App = () => (
  <div>
    <LoginContainer/>
    <CommentContainer/>
    <CommentFormContainer/>
  </div>
);

export default App;
