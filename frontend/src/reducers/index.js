import { combineReducers } from "redux";
import comments from "./comments";
import login from "./login";

export default combineReducers({comments, login});
