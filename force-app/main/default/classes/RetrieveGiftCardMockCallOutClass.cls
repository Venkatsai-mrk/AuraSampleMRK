public class RetrieveGiftCardMockCallOutClass implements HttpCalloutMock{
			 public HttpResponse respond(HTTPRequest req){
         
       String retrieveGiftCard = '{"gift_card":{"id":"gftc:6944163553804e439d89adb47caf806a","type":"DIGITAL","gan_source":"SQUARE","state":"ACTIVE","balance_money":{"amount":5000,"currency":"USD"},"gan":"7783320001001635","created_at":"2021-05-20T22:26:54.000Z"}}';

        
HttpResponse res = new HttpResponse();
res.setStatus('OK');
res.setStatusCode(200);
res.setBody(retrieveGiftCard);
return res;
}    
}