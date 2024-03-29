public class GetPaymentInfoMockCallOutClass implements HttpCalloutMock{

    public HttpResponse respond(HTTPRequest req){
        
        String createTerminal = '{"payment":{"id":"bP9mAsEMYPUGjjGNaNO5ZDVyLhSZY","created_at":"2021-10-13T19:34:33.524Z","updated_at":"2021-10-13T19:34:34.339Z","amount_money":{"amount":555,"currency":"USD"},"status":"COMPLETED","delay_duration":"PT168H","source_type":"CARD","card_details":{"status":"CAPTURED","card":{"card_brand":"VISA","last_4":"1111","exp_month":11,"exp_year":2022,"fingerprint":"sq-1-Hxim77tbdcbGejOejnoAklBVJed2YFLTmirfl8Q5XZzObTc8qY_U8RkwzoNL8dCEcQ","card_type":"DEBIT","prepaid_type":"NOT_PREPAID","bin":"411111"},"entry_method":"KEYED","cvv_status":"CVV_ACCEPTED","avs_status":"AVS_ACCEPTED","auth_result_code":"2Nkw7q","statement_description":"SQ*EXAMPLETESTGOSQ.C","card_payment_timeline":{"authorized_at":"2021-10-13T19:34:33.680Z","captured_at":"2021-10-13T19:34:34.340Z"}},"location_id":"L88917AVBK2S5","order_id":"d7eKah653Z579f3gVtjlxpSlmUcZY","processing_fee":[{"effective_at":"2021-10-13T21:34:35.000Z","type":"INITIAL","amount_money":{"amount":34,"currency":"USD"}}],"note":"TestNote","total_money":{"amount":555,"currency":"USD"},"approved_money":{"amount":555,"currency":"USD"},"employee_id":"TMoK_ogh6rH1o4dV","receipt_number":"bP9m","receipt_url":"https://squareup.com/receipt/preview/bP9mAsEMYPUGjjGNaNO5ZDVyLhSZY","delay_action":"CANCEL","delayed_until":"2021-10-20T19:34:33.524Z","team_member_id":"TMoK_ogh6rH1o4dV","application_details":{"square_product":"VIRTUAL_TERMINAL","application_id":"sq0ids-Pw67AZAlLVB7hsRmwlJPuA"},"version_token":"56pRkL3slrzet2iQrTp9n0bdJVYTB9YEWdTNjQfZOPV6o"}}';
        
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(createTerminal);
        return res;
    } 
    
}