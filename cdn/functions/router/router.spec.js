#!/usr/bin/env jest

const viewer_request = require("./router.js");

fixture_1 = {
  context: {
    distributionDomainName:'d123.cloudfront.net',
    eventType:'viewer-request',
  },
  viewer: {
    ip:'1.2.3.4'
  },
  request: {
    method: 'GET',
    uri: '/index.php',
    querystring: {},
    headers: {
      host: {
        value:'invalid.example'
      }
    },
    cookies: {}
  }
}

describe("origin_request", function() {
  test('fixture_1', function(done) {
    var res = viewer_request(fixture_1);

    console.log(res);

    expect(res).not.toBe(fixture_1.request);
    expect(res.statusCode).toBe(401);
    expect(Object.keys(res["headers"])).toStrictEqual(["www-authenticate"]);

    done();
  });
});
