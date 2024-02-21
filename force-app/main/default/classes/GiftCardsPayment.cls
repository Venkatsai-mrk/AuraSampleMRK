public class GiftCardsPayment {
	public String ganNumber;
    public String giftCardId;
    public String customerId;
    
    public static void retrieveGiftCard(String ganNumber){
       
        
        /*Http h = new Http();
        HttpRequest req = new HttpRequest();        
        HttpResponse res = new HttpResponse();
        String endpoint = ElixirEHR_Square_Utility.fetchSquareCreds() + '/gift-cards/from-gan';
        req.setEndpoint(endpoint);       
        // Set Method Type
        req.setMethod('POST');
        req.setTimeout(10000);         
        //    req.setBody(serializedBody);
        req.setHeader('Square-Version', '2022-12-14');
        req.setHeader('Content-Type', 'application/json');       
        String accessToken = ElixirEHR_Square_Utility.fetchSquareToken();
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('gan',ganNumber);
        gen.writeEndObject();
        res = h.send(req);
        if(res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            ExceptionLog.logHTTPtransaction(String.valueOf(res.getStatusCode()), req.getBody(), res.getBody(), endpoint,'retrieveGiftCard','POST');
        }
        else {      
            system.debug(res.getBody());  
            ExceptionLog.logHTTPtransaction(String.valueOf(res.getStatusCode()), req.getBody(), res.getBody(), endpoint,'retrieveGiftCard','POST');
        }  */   
    }
    
    
    
    public static void linkGiftCard(String giftCardId,String customerId){
        
       /* Http h = new Http();
        HttpRequest req = new HttpRequest();        
        HttpResponse res = new HttpResponse();
        String endpoint = ElixirEHR_Square_Utility.fetchSquareCreds() + '/gift-cards/'+ giftCardId +'/link-customer';
        req.setEndpoint(endpoint);       
        // Set Method Type
        req.setMethod('POST');
        req.setTimeout(10000);         
        //    req.setBody(serializedBody);
        req.setHeader('Square-Version', '2022-12-14');
        req.setHeader('Content-Type', 'application/json');       
        String accessToken = ElixirEHR_Square_Utility.fetchSquareToken();
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('customer_id',customerId);
        gen.writeEndObject();
        res = h.send(req);
        if(res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            ExceptionLog.logHTTPtransaction(String.valueOf(res.getStatusCode()), req.getBody(), res.getBody(), endpoint,'linkGiftCard','POST');
        }
        else {      
            system.debug(res.getBody());  
            ExceptionLog.logHTTPtransaction(String.valueOf(res.getStatusCode()), req.getBody(), res.getBody(), endpoint,'linkGiftCard','POST');
        } */   
    }
}