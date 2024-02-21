public class LinkGiftCardMockCallOutClass implements HttpCalloutMock{
  			 public HttpResponse respond(HTTPRequest req){
         
       String linkGiftCard = '{"gift_card":{"id":"gftc:71ea002277a34f8a945e284b04822edb","type":"DIGITAL","gan_source":"SQUARE","state":"ACTIVE","balance_money":{"amount":2500,"currency":"USD"},"gan":"7783320005440920","created_at":"2021-03-25T05:13:01Z","customer_ids":["GKY0FZ3V717AH8Q2D821PNT2ZW"]}}';

        
HttpResponse res = new HttpResponse();
res.setStatus('OK');
res.setStatusCode(200);
res.setBody(linkGiftCard);
return res;
}    
}