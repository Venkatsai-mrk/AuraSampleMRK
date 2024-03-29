public class CreatePaymentSquareMockCallOutClass implements HttpCalloutMock{
    public HttpResponse respond(HTTPRequest req){
         
     String createPaymentResp='{"payment":{"id": "R2B3Z8WMVt3EAmzYWLZvz7Y69EbZY","created_at": "2021-10-13T21:14:29.577Z","updated_at": "2021-10-13T21:14:30.504Z","amount_money": {"amount": 1000,"currency": "USD"},"app_fee_money": {"amount": 10,"currency": "USD"},"status": "COMPLETED","delay_duration": "PT168H","source_type": "CARD","card_details": {"status": "CAPTURED","card": {"card_brand": "VISA","last_4": "1111","exp_month": 11,"exp_year": 2022,"fingerprint": "sq-1-Hxim77tbdcbGejOejnoAklBVJed2YFLTmirfl8Q5XZzObTc8qY_U8RkwzoNL8dCEcQ","card_type": "DEBIT","prepaid_type": "NOT_PREPAID","bin": "411111"},"entry_method": "ON_FILE","cvv_status": "CVV_ACCEPTED","avs_status": "AVS_ACCEPTED","auth_result_code": "vNEn2f","statement_description": "SQ *EXAMPLE TEST GOSQ.C","card_payment_timeline": {"authorized_at": "2021-10-13T21:14:29.732Z","captured_at": "2021-10-13T21:14:30.504Z"}},"location_id": "L88917AVBK2S5","order_id": "pRsjRTgFWATl7so6DxdKBJa7ssbZY","reference_id": "123456","risk_evaluation": {"created_at": "2021-10-13T21:14:30.423Z","risk_level": "NORMAL"},"note": "Brief Description","customer_id": "W92WH6P11H4Z77CTET0RNTGFW8","total_money": {"amount": 1000,"currency": "USD"},"approved_money": {"amount": 1000,"currency": "USD"},"receipt_number": "R2B3","receipt_url": "https://squareup.com/receipt/preview/EXAMPLE_RECEIPT_ID","delay_action": "CANCEL","delayed_until": "2021-10-20T21:14:29.577Z","application_details": {"square_product": "ECOMMERCE_API","application_id": "sq0ids-TcgftTEtKxJTRF1lCFJ9TA"},"version_token": "TPtNEOBOa6Qq6E3C3IjckSVOM6b3hMbfhjvTxHBQUsB6o"}}'; 
        
HttpResponse res = new HttpResponse();
res.setStatus('OK');
res.setStatusCode(200);
res.setBody(createPaymentResp);
return res;
}    
}