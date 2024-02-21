public class GetTerminalCheckOutMockCallOutClass implements HttpCalloutMock{
    public HttpResponse respond(HTTPRequest req){
         
        String getTerminalResp ='{"checkout": {"id": "08YceKh7B3ZqO","amount_money": {"amount": 2610,"currency": "USD"},"reference_id": "id11572","note": "A brief note","device_options": {"device_id": "dbb5d83a-7838-11ea-bc55-0242ac130003","tip_settings": {"allow_tipping": false},"skip_receipt_screen": false},"status": "IN_PROGRESS","created_at": "2020-04-06T16:39:32.545Z","updated_at": "2020-04-06T16:39:323.001Z","app_id": "APP_ID","deadline_duration": "PT10M"}}';
HttpResponse res = new HttpResponse();
res.setStatus('OK');
res.setStatusCode(200);
res.setBody(getTerminalResp);
return res;
}    
}