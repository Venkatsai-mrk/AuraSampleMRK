public class getPaymentCardTypeParser{
	public cls_payment payment;
	public class cls_payment {
		public String id;	//X9RudCZhwF3VRDzVLvwVYsGOvaB
		public String created_at;	//2022-12-22T22:11:58.354Z
		public String updated_at;	//2022-12-22T22:12:03.126Z
		public cls_amount_money amount_money;
		public String status;	//COMPLETED
		public String source_type;	//CARD
		public cls_card_details card_details;
		public String location_id;	//LCBN1N814BG2W
		public String order_id;	//7hgsHeKfukvdQJC1G9ecsjreV
		public String terminal_checkout_id;	//1ET3o2SZxwaqO
		public cls_processing_fee[] processing_fee;
		public String customer_id;	//A1PHYE19M704NMB1FC2X0YGAGW
		public cls_total_money total_money;
		public cls_approved_money approved_money;
		public String employee_id;	//TMb577gm3AuUblyU
		public String receipt_number;	//X9Ru
		public String receipt_url;	//https://squareup.com/receipt/preview/X9RudCZhwF3VRDzVLvwVYsGOvaB
		public cls_device_details device_details;
		public String team_member_id;	//TMb577gm3AuUblyU
		public cls_application_details application_details;
		public String version_token;	//W89TWhnCl1euIsuV8Cpp8csvA1NppILY4bFMW95dcTL6o
	}
	class cls_amount_money {
		public Integer amount;	//697
		//public String currency;	//USD
	}
	public class cls_card_details {
		public String status;	//CAPTURED
		public cls_card card;
		public String entry_method;	//CONTACTLESS
		public String cvv_status;	//CVV_NOT_CHECKED
		public String avs_status;	//AVS_NOT_CHECKED
		public String auth_result_code;	//04756D
		public String application_identifier;	//A0000000031010
		public String application_name;	//CHASE VISA
		public String application_cryptogram;	//06ea5978ef617ee7
		public String verification_method;	//NONE
		public String verification_results;	//UNKNOWN
		public String statement_description;	//SQ *DAVAM AESTHETICS
		public cls_device_details device_details;
		public cls_card_payment_timeline card_payment_timeline;
	}
	 public class cls_card {
		public String card_brand;	//VISA
		public String last_4;	//7459
		public Integer exp_month;	//5
		public Integer exp_year;	//2026
		public String cardholder_name;	//CARDHOLDER/VISA
		public String fingerprint;	//sq-1-Uccy2meLDJ3ExpOXB62x1hFqmaGHmH98-jkP5FCZlpYnHaX1y4TiuEDmlPrezG4n4g
		public String card_type;	//CREDIT
		public String prepaid_type;	//NOT_PREPAID
		public String bin;	//438857
	}
	class cls_device_details {
		public String device_id;	//142CS149A6000209
		public String device_name;	//
		public String device_installation_id;	//c7f4d5a6-3d5e-4712-9063-3b3f507b6c05
	}
	class cls_card_payment_timeline {
		public String authorized_at;	//2022-12-22T22:11:58.598Z
		public String captured_at;	//2022-12-22T22:12:01.876Z
	}
	class cls_processing_fee {
		public String effective_at;	//2022-12-23T00:12:01.000Z
		public String type;	//INITIAL
		public cls_amount_money amount_money;
	}
	class cls_total_money {
		public Integer amount;	//27669
		//public String currency;	//USD
	}
	class cls_approved_money {
		public Integer amount;	//27669
		//public String currency;	//USD
	}
	class cls_application_details {
		public String square_product;	//TERMINAL_API
		public String application_id;	//terminal
	}
}