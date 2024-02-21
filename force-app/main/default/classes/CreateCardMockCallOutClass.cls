public class CreateCardMockCallOutClass implements HttpCalloutMock{
    public HttpResponse respond(HTTPRequest req){
        
        String createCardResp ='{"card": {"id": "ccof:uIbfJXhXETSP197M3GB","billing_address": {"address_line_1": "500 Electric Ave","address_line_2": "Suite 600","locality": "New York","administrative_district_level_1": "NY","postal_code": "10003","country": "US"},"fingerprint": "ex-p-cs80EK9Flz7LsCMv-szbptQ_ssAGrhemzSTsPFgt9nzyE6t7okiLIQc-qw_quqKX4Q","bin": "411111","card_brand": "VISA","card_type": "CREDIT","cardholder_name": "Amelia Earhart","customer_id": "VDKXEEKPJN48QDG3BGGFAK05P8","enabled": true,"exp_month": 11,"exp_year": 2022,"last_4": "1111","merchant_id": "6SSW7HV8K2ST5","prepaid_type": "NOT_PREPAID","reference_id": "user-id-1","version": 1}}';           
        
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(createCardResp);
        return res;
    }    
}