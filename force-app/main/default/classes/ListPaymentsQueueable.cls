public class ListPaymentsQueueable implements Queueable,Database.AllowsCallouts {
    @testVisible
    private static Boolean doChainJob = true;
    public String squareOrderId;
    public String customerId;
    public ListPaymentsQueueable(String squareOrderId, String customerId){
        this.squareOrderId = squareOrderId;
        this.customerId = customerId;
    }
    public void execute(QueueableContext context) {
       /* Http h = new Http();
        HttpRequest req = new HttpRequest();        
        HttpResponse res = new HttpResponse();
        String endpoint = ElixirEHR_Square_Utility.fetchSquareCreds() + '/payments';
        req.setEndpoint(endpoint);       
        req.setMethod('GET');
        req.setTimeout(10000); 
		req.setHeader('Square-Version', ElixirEHR_Square_Utility.fetchSquareVersion());        
        req.setHeader('Content-Type', 'application/json');       
        String accessToken = ElixirEHR_Square_Utility.fetchSquareToken();
        req.setHeader('Authorization', 'Bearer ' + accessToken);  
        JSONGenerator gen = JSON.createGenerator(true);
        endpoint+='?location_id='+ElixirEHR_Square_Utility.fetchLocation();
        endpoint+='&sort_order=DESC';
        endpoint+='&limit=100';
        res = h.send(req);
        if(res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            ExceptionLog.logHTTPtransaction(String.valueOf(res.getStatusCode()), req.getBody(), res.getBody(), endpoint,'ListPaymentsQueueable','GET');
            String jsonString = res.getBody();
            ListPaymentParser paymentWrapper = (ListPaymentParser) JSON.deserialize(jsonString, ListPaymentParser.class);
            if(paymentWrapper!=null){
                for(ListPaymentParser.cls_payments payment :paymentWrapper.payments){
                    if(payment.order_id == squareOrderId){
                        String paymentId = payment.Id;    
                        if(doChainJob) { 
                        system.enqueueJob(new CreateCardQueueable(paymentId, customerId));
                        break;
                        }
                    }
                }
            }
        }
        else {        
            ExceptionLog.logHTTPtransaction(String.valueOf(res.getStatusCode()), req.getBody(), res.getBody(), endpoint,'ListPaymentsQueueable','GET');
        }*/
    }
}