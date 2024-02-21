@isTest
global class ClaimsPostRequestNightlyMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
         HttpResponse response = new HttpResponse();
         return response;
    }
}