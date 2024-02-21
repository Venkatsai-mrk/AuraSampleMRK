public class CreateCardQueueable implements Queueable,Database.AllowsCallouts {
    public String paymentId;
    public String customerId;
    public CreateCardQueueable(String paymentId, String customerId){
        this.paymentId = paymentId;
        this.customerId = customerId;
    }
    public void execute(QueueableContext context){
       /* Http h = new Http();
        HttpRequest req = new HttpRequest();        
        HttpResponse res = new HttpResponse();
        String endpoint = ElixirEHR_Square_Utility.fetchSquareCreds() + '/cards';
        req.setEndpoint(endpoint);       
        req.setMethod('POST');
        req.setTimeout(10000);  
        req.setHeader('Square-Version', ElixirEHR_Square_Utility.fetchSquareVersion());
        req.setHeader('Content-Type', 'application/json');       
        String accessToken = ElixirEHR_Square_Utility.fetchSquareToken();
        req.setHeader('Authorization', 'Bearer ' + accessToken); 

        CardsBody cardsWrapper = new CardsBody();
        cardsWrapper.idempotency_key = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        cardsWrapper.source_id = paymentId;

        cls_card  cls = new cls_card();
        cls.cardholder_name = 'Amelia Earhart';
        cls.customer_id = ElixirEHR_Square_Utility.fetchCustomerId(customerId);
        cardsWrapper.card = cls;

        List<Account> accList = [SELECT Id, name,BillingCountry,BillingPostalCode,BillingCity,BillingStreet from Account where Id =:customerId];
        cls_billing_address billing_address_wrapped = new cls_billing_address();
        billing_address_wrapped.country =  accList[0].BillingCountry;
        billing_address_wrapped.postal_code =  accList[0].BillingPostalCode;
        billing_address_wrapped.locality =  accList[0].BillingCity;
        billing_address_wrapped.address_line_1 =  accList[0].BillingStreet;
        cls.billing_address = billing_address_wrapped;

        String jsonData = JSON.serialize(cardsWrapper);
        req.setBody(jsonData);
        res = h.send(req);
        if(res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            String jsonString = res.getBody();
            ExceptionLog.logHTTPtransaction(String.valueOf(res.getStatusCode()), req.getBody(), res.getBody(), endpoint,'CreateCardQueueable','POST');
            CreateCardParser cardWrapper = (CreateCardParser) JSON.deserialize(jsonString, CreateCardParser.class);
            if(cardWrapper!=null){
                //Create Payment Information record
                String cardId = cardWrapper.card.Id;
                Payment_Information__c paymentInfo  = new Payment_Information__c(); 
                paymentInfo.Source_Id__c = cardId;
                paymentInfo.ElixirSuite__Account__c = customerId;
                paymentInfo.First_Name_on_Card__c = cardWrapper.card.cardholder_name;
                paymentInfo.ElixirSuite__Credit_Card_Company__c    = cardWrapper.card.card_brand;
                paymentInfo.ElixirSuite__Expiration_Month__c    = String.valueOf(cardWrapper.card.exp_month);
                paymentInfo.ElixirSuite__Expiration_Year__c    =  String.valueOf(cardWrapper.card.exp_year);
                paymentInfo.ElixirSuite__Card_Type__c = String.valueOf(cardWrapper.card.card_type);
                paymentInfo.ElixirSuite__Credit_Card_Number__c  = String.valueOf(cardWrapper.card.last_4);
                List<RecordType> recordTypes = [SELECT Id FROM RecordType 
                WHERE sObjectType='ElixirSuite__Payment_Information__c'
                AND DeveloperName='Credit_Card'];
                paymentInfo.RecordTypeId  = recordTypes[0].Id;
                //paymentInfo.ElixirSuite__Street_Address__c    = cardWrapper..address_line_1;
                //paymentInfo.ElixirSuite__City__c    = cardWrapper.billing_address.locality;
                //paymentInfo.ElixirSuite__Country__c    = cardWrapper.billing_address.country;
                //paymentInfo.ElixirSuite__Postal_Zip_Code__c    = cardWrapper.billing_address.postal_code;
                if(Schema.sObjectType.Payment_Information__c.isCreateable() &&
                  Schema.sObjectType.Payment_Information__c.fields.RecordTypeId.isCreateable() &&
                  Schema.sObjectType.Payment_Information__c.fields.ElixirSuite__Credit_Card_Number__c.isCreateable() &&
                  Schema.sObjectType.Payment_Information__c.fields.ElixirSuite__Card_Type__c.isCreateable() &&
                  Schema.sObjectType.Payment_Information__c.fields.ElixirSuite__Expiration_Year__c.isCreateable() &&
                  Schema.sObjectType.Payment_Information__c.fields.ElixirSuite__Expiration_Month__c.isCreateable() &&
                  Schema.sObjectType.Payment_Information__c.fields.ElixirSuite__Credit_Card_Company__c.isCreateable() &&
                  Schema.sObjectType.Payment_Information__c.fields.First_Name_on_Card__c.isCreateable() &&
                  Schema.sObjectType.Payment_Information__c.fields.ElixirSuite__Account__c.isCreateable() &&
                  Schema.sObjectType.Payment_Information__c.fields.Source_Id__c.isCreateable()){
                insert paymentInfo;
                }          
            }
        else {      
            system.debug(res.getBody());  
            ExceptionLog.logHTTPtransaction(String.valueOf(res.getStatusCode()), req.getBody(), res.getBody(), endpoint,'CreateCardQueueable','POST');
        }    
        }*/
    }
    public class CardsBody{
        public String idempotency_key;    //4935a656-a929-4792-b97c-8848be85c27c
        public String source_id;    //cnon:uIbfJXhXETSP197M3GB
        public cls_card card;     
    }
    class cls_card {
        public cls_billing_address billing_address;
        public String cardholder_name;    //Amelia Earhart
        public String customer_id;    //VDKXEEKPJN48QDG3BGGFAK05P8
        public String reference_id;    //user-id-1
    }
    class cls_billing_address {
        public String address_line_1;    //500 Electric Ave
        public String address_line_2;    //Suite 600
        public String locality;    //New York
        public String administrative_district_level_1;    //NY
        public String postal_code;    //10003
        public String country;    //US
    }
}