#!/usr/bin/env jest

const viewer_request = require("./router.js");

fixture_nonprod = {
  context: {
    distributionDomainName:'d123.cloudfront.net',
    eventType:'viewer-request',
  },
  viewer: {
    ip:'1.2.3.4'
  },
  request: {
    method: 'GET',
    uri: '/index.html',
    headers: {
      host: {
        value: 'vulnerability-reporting.nonprod-service.security.gov.uk'
      }
    }
  }
}

fixture_prod = {
  context: {
    distributionDomainName:'d123.cloudfront.net',
    eventType:'viewer-request',
  },
  viewer: {
    ip:'1.2.3.4'
  },
  request: {
    method: 'GET',
    uri: '/',
    headers: {
      host: {
        value: 'vulnerability-reporting.service.security.gov.uk'
      }
    }
  }
}

describe("origin_request", function() {
  test('nonprod', function(done) {
    var res = viewer_request(fixture_nonprod);

    expect(res).not.toBe(fixture_nonprod.request);
    expect(res.statusCode).toBe(401);
    expect(Object.keys(res["headers"])).toStrictEqual(["www-authenticate"]);

    done();
  });

  test('prod', function(done) {
    var res = viewer_request(fixture_prod);

    expect(res).toBe(fixture_prod.request);
    done();
  });
});
