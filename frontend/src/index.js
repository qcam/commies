import React from "react";
import { render } from "react-dom";

import { Provider } from "react-redux";
import { createStore, applyMiddleware } from "redux";
import thunkMiddleware from "redux-thunk";

import rootReducer from "./reducers";
import App from "./components/App";

const url = new URL(window.location.href);

const initState = {
  comments: {
    linkID: url.searchParams.get("link_id"),
    comments: []
  }
};

const store = createStore(
  rootReducer,
  initState,
  applyMiddleware(thunkMiddleware)
);

render(
  <Provider store={store}><App/></Provider>, document.getElementById('root')
);
