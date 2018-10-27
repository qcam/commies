import {assert} from "chai";
import nock from "nock";
import Backend from "./backend";
import config from "../config";

describe("fetchComments", () => {
  it("returns comments by the given link ID", () => {
    const linkID = "42";
    const mockedComment = {
      id: 1024,
      content: "Foo and bar are good friends",
      inserted_at: "2018-01-01T00:00:00.000z",
      user: {name: "foo"}
    };

    const resp_headers = {"access-control-allow-origin": "*"};
    const resp_body = JSON.stringify({comments: [mockedComment]});

    nock(config.backend.endpoint)
      .get(`/links/${linkID}/comments`)
      .reply(200, resp_body, resp_headers);

    return Backend.fetchComments(linkID).then((comments) => {
      assert.deepEqual(comments, [mockedComment]);
    });
  });

  it("handles erroneous HTTP calls", () => {
    const linkID = "42";
    const resp_headers = {"access-control-allow-origin": "*"};
    const resp_body = JSON.stringify({errors: ["not found"]});

    nock(config.backend.endpoint)
      .get(`/links/${linkID}/comments`)
      .reply(404, resp_body, resp_headers);

    return Backend.fetchComments(linkID).catch((payload) => {
      assert.deepEqual(payload, {errors: ["not found"]});
    });
  });
});
