public class ListPaymentParser{
	public cls_payments[] payments;
	public class cls_payments {
		public String id;	//bP9mAsEMYPUGjjGNaNO5ZDVyLhSZY
		public String created_at;	//2021-10-13T19:34:33.524Z
		public String updated_at;	//2021-10-13T19:34:37.261Z
		public String status;	//COMPLETED
		public String delay_duration;	//PT168H
		public String source_type;	//CARD
		public cls_card_details card_details;
		public String location_id;	//L88917AVBK2S5
		public String order_id;	//d7eKah653Z579f3gVtjlxpSlmUcZY
		public cls_processing_fee[] processing_fee;
		public String note;	//Test Note
		public String employee_id;	//TMoK_ogh6rH1o4dV
		public String receipt_number;	//bP9m
		public String receipt_url;	//https://squareup.com/receipt/preview/bP9mAsEMYPUGjjGNaNO5ZDVyLhSZY
		public String delay_action;	//CANCEL
		public String delayed_until;	//2021-10-20T19:34:33.524Z
		public String team_member_id;	//TMoK_ogh6rH1o4dV
		public cls_application_details application_details;
		public String version_token;	//vguW2km0KpVCdAXZcNTZ438qg5LlVPTP4HO5OpiHNfa6o
	}
	class cls_card_details {
		public String status;	//CAPTURED
		public cls_card card;
		public String entry_method;	//KEYED
		public String cvv_status;	//CVV_ACCEPTED
		public String avs_status;	//AVS_ACCEPTED
		public String auth_result_code;	//2Nkw7q
		public String statement_description;	//SQ *EXAMPLE TEST GOSQ.C
		public cls_card_payment_timeline card_payment_timeline;
	}
	class cls_card {
		public String card_brand;	//VISA
		public String last_4;	//1111
		public Integer exp_month;	//11
		public Integer exp_year;	//2022
		public String fingerprint;	//sq-1-Hxim77tbdcbGejOejnoAklBVJed2YFLTmirfl8Q5XZzObTc8qY_U8RkwzoNL8dCEcQ
		public String card_type;	//DEBIT
		public String prepaid_type;	//NOT_PREPAID
		public String bin;	//411111
	}
	class cls_card_payment_timeline {
		public String authorized_at;	//2021-10-13T19:34:33.680Z
		public String captured_at;	//2021-10-13T19:34:34.340Z
	}
	class cls_processing_fee {
		public String effective_at;	//2021-10-13T21:34:35.000Z
		public String type;	//INITIAL
	}
	class cls_application_details {
		public String square_product;	//VIRTUAL_TERMINAL
		public String application_id;	//sq0ids-Pw67AZAlLVB7hsRmwlJPuA
	}
}