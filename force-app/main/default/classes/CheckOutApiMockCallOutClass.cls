public class CheckOutApiMockCallOutClass implements HttpCalloutMock{
    public HttpResponse respond(HTTPRequest req){
         
        String checkOutApiResp='{"payment_link": {"id": "PKVT6XGJZXYUP3NZ","version": 1,"order_id": "o4b7saqp4HzhNttf5AJxC0Srjd4F","url": "https://square.link/u/EXAMPLE","created_at": "2022-04-25T23:58:01Z"},"related_resources": {"orders": [{"id": "o4b7saqp4HzhNttf5AJxC0Srjd4F","location_id": "{LOCATION_ID}","source": {"name": "Test Online Checkout Application"},"line_items": [{"uid": "8YX13D1U3jO7czP8JVrAR","name": "Auto Detailing","quantity": "1","item_type": "ITEM","base_price_money": {"amount": 12500,"currency": "USD"},"variation_total_price_money": {"amount": 12500,"currency": "USD"},"gross_sales_money": {"amount": 12500,"currency": "USD"},"total_tax_money": {"amount": 0,"currency": "USD"},"total_discount_money": {"amount": 0,"currency": "USD"},"total_money": {"amount": 12500,"currency": "USD"}}],"fulfillments": [{"uid": "bBpNrxjdQxGQP16sTmdzi","type": "DIGITAL","state": "PROPOSED"}],"net_amounts": {"total_money": {"amount": 12500,"currency": "USD"},"tax_money": {"amount": 0,"currency": "USD"},"discount_money": {"amount": 0,"currency": "USD"},"tip_money": {"amount": 0,"currency": "USD"},"service_charge_money": {"amount": 0,"currency": "USD"}},"created_at": "2022-03-03T00:53:15.829Z","updated_at": "2022-03-03T00:53:15.829Z","state": "DRAFT","version": 1,"total_money": {"amount": 12500,"currency": "USD"},"total_tax_money": {"amount": 0,"currency": "USD"},"total_discount_money": {"amount": 0,"currency": "USD"},"total_tip_money": {"amount": 0,"currency": "USD"},"total_service_charge_money": {"amount": 0,"currency": "USD"}}]}}';
        
HttpResponse res = new HttpResponse();
res.setStatus('OK');
res.setStatusCode(200);
res.setBody(checkOutApiResp);
return res;
}    
}