global class ElixirOEM_HttpMockCreateRecordsSuccess implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        // mock success body, we look for referenceId 'foo' and id 'bar' in test class
        // so if you change them here, change them in test class too
        res.setBody('{"hasErrors" : false, "results": [{"referenceId" : "foo", "id" : "bar"}]}');
        // status of 201 will ensure code accepts our response and not throw error
        res.setStatusCode(201);
        return res;
    }
}
