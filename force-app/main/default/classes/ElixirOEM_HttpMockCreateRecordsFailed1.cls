global class ElixirOEM_HttpMockCreateRecordsFailed1 implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        // mock error body
        res.setBody('{"hasErrors": true,"results": [{"referenceId": "a111m000001d4G3AAI","errors": [{"statusCode": "INVALID_CROSS_REFERENCE","message": "invalid cross reference","fields": []}]}]}');
        // createRecords will only excpet 201 status code, and will throw error for 200
        res.setStatusCode(200);
        return res;
    }
}