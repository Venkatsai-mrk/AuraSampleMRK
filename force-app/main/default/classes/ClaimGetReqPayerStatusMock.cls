@isTest
global class ClaimGetReqPayerStatusMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        return response;
    }
}