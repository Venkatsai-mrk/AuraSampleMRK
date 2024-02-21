global class ElixirOEM_HttpMockFormExists implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        // totalSize 1 means, 1 section of form was found
        res.setBody('{"totalSize": 1}');
        res.setStatusCode(200);
        return res;
    }
}
