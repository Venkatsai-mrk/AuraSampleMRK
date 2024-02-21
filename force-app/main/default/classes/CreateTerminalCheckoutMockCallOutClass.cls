public class CreateTerminalCheckoutMockCallOutClass implements HttpCalloutMock{
    public HttpResponse respond(HTTPRequest req){
         
       String createTerminal = '{"checkout": {"id": "AxBOAO75cOkqO","amount_money": {"amount": 1,"currency": "USD"},"device_options": {"device_id": "142CS149A6000209","collect_signature": false,"tip_settings": {"allow_tipping": false},"skip_receipt_screen": false},"status": "CANCELED","created_at": "2022-12-21T03:01:52.594Z","updated_at": "2022-12-21T10:15:48.312Z","app_id": "sq0idp-6RmOjVKT6UlxnjsIPZdN-w","deadline_duration": "PT5M","cancel_reason": "SELLER_CANCELED","location_id": "LCBN1N814BG2W","payment_type": "CARD_PRESENT","payment_options": {"autocomplete": true}}}';
        
HttpResponse res = new HttpResponse();
res.setStatus('OK');
res.setStatusCode(200);
res.setBody(createTerminal);
return res;
}    
}