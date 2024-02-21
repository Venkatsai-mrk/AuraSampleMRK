public class GetTerminalCheckOutParser{
    public cls_checkout checkout;
    public class cls_checkout {
        public String id;    //1ET3o2SZxwaqO
        public cls_amount_money amount_money;
        public cls_device_options device_options;
        public String status;    //COMPLETED
        public String[] payment_ids;
        public String created_at;    //2022-12-22T22:11:52.705Z
        public String updated_at;    //2022-12-22T22:12:03.063Z
        public String app_id;    //terminal
        public String deadline_duration;    //PT5M
        public String order_id;    //q6hUNpl0Uh7fzutrx13aJFSJmsQZY
        public String location_id;    //LCBN1N814BG2W
        public String payment_type;    //CARD_PRESENT
        public String team_member_id;    //TMb577gm3AuUblyU
        public cls_payment_options payment_options;
    }
   public class cls_amount_money {
        public Integer amount;    //27669
    }
    public class cls_device_options {
        public String device_id;    //142CS149A6000209
        public cls_tip_settings tip_settings;
        public boolean skip_receipt_screen;
        public boolean show_itemized_cart;
    }
    public class cls_tip_settings {
        public boolean allow_tipping;
    }
    public class cls_payment_options {
        public boolean autocomplete;
    }
}