import config from "../config";

export default class Backend {
  static fetchComments(linkID) {
    const req_url = `${config.backend.endpoint}/links/${linkID}/comments`;
    const req_headers = {"accept": "application/json"};
    const req_options = {headers: req_headers};

    return fetch(req_url, req_options).then((resp) => {
      if (resp.status === 200) {
        return resp.json();
      } else {
        return Promise.reject(resp.json());
      }
    }).then((payload) => payload.comments)
    .catch((error) => error);
  }

  static postComment(linkID, token, content) {
    const req_url = `${config.backend.endpoint}/links/${linkID}/comments`;
    const req_headers = {
      "accept": "application/json",
      "content-type": "application/json",
      "authorization": token
    };
    const req_options = {
      method: "post",
      headers: req_headers,
      body: JSON.stringify({content: content})
    };

    return fetch(req_url, req_options).then((resp) => {
      if (resp.status === 201) {
        return resp.json();
      } else {
        return Promise.reject(resp.json());
      }
    }).then((payload) => payload.comment)
    .catch((error) => error);
  }
};
