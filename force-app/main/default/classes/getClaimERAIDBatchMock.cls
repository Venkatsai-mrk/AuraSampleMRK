@isTest
global class getClaimERAIDBatchMock implements HttpCalloutMock{
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            return response;
        }
}