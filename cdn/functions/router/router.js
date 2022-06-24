function redirect(url) {
    var response = {
        statusCode: 307,
        statusDescription: 'Temporary Redirect',
        headers: {
            'location': {
              value: url
            }
        }
    };
    return response;
}

function return401() {
    var body = 'You are not authorised to enter';
    var response = {
        statusCode: 401,
        statusDescription: 'Unauthorised',
        headers: {
            'www-authenticate': {
              value: 'Basic'
            }
        }
    };
    return response;
}

function handler(event) {
    var request = event.request;
    var headers = request.headers;
    var headerKeys = Object.keys(headers);
    var uri = request.uri;

    var host = '';
    if (headerKeys.indexOf('host') > -1) {
        host = request.headers.host.value;
    } else if (headerKeys.indexOf(':authority') > -1) {
        host = request.headers[':authority'].value;
    }

    if (uri.match(/^\/.well[-_]known\/status(?:\.txt)?$/)) {
      request.uri = "/.well-known/status.txt";
      // file hosted in S3
      return request;
    }

    if (uri.match(/^\/.well[-_]known\/teapot$/)) {
      return {
          statusCode: 418,
          statusDescription: "I'm a teapot"
      };
    }

    if (uri.match(/^\/.well[-_]known\/hosting-provider(?:\.txt)?$/)) {
      request.uri = "/.well-known/hosting-provider.txt";
      // file hosted in S3
      return request;
    }

    if (host == "vulnerability-reporting.nonprod-service.security.gov.uk") {
      var basicAuth = 'Basic ${basicauthstring}';
      if (
        headerKeys.indexOf('authorization') == -1 ||
        request.headers['authorization'].value != basicAuth
      ) {
          return return401();
      }
    }

    /*if (
      host == "vulnerability-reporting.service.security.gov.uk" &&
      !uri.match(/^\/?(?:assets\/|coming-soon)/)
    ) {
      return redirect("https://vulnerability-reporting.service.security.gov.uk/coming-soon");
    }*/

    if (uri.match(/^(?:\/.well[-_]known)?\/security(?:\.txt)?$/)) {
      request.uri = "/.well-known/security.txt";
      // file hosted in S3
      return request;
    }

    if (
      host != "vulnerability-reporting.service.security.gov.uk" &&
      host != "vulnerability-reporting.nonprod-service.security.gov.uk"
    ) {
      return redirect("https://www.gov.uk");
    }

    if (uri.match(/^\/?(?:submit|submit2|acknowledgements|feedback|config|coming-soon)$/)) {
      request.uri += ".html";
      // file hosted in S3
      return request;
    }

    // file hosted in S3
    return request;
}

if (typeof(module) === "object") {
    module.exports = handler;
}
