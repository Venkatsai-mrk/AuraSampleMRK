global class ElixirOEM_HttpMockCreateRecordsFailed implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        // mock error body
        res.setBody('[{"errorCode" : "foo", "message" : "bar"}]');
        // createRecords will only excpet 201 status code, and will throw error for 200
        res.setStatusCode(200);
        return res;
    }
}
