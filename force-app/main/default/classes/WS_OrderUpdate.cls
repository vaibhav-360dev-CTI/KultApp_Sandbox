global class WS_OrderUpdate {

	public String order_id;
	public Boolean is_coupon_redeemed;
	public List<Order_details> order_details;

	public class Item_details {
		public String sku;
		public String status;
	}

	public class Order_details {
		public String sub_order_id;
		public String sub_order_status;
		public String awb_number;
		public String courier;
		public String expected_delivery_date;
		public String tracking_link;
		public List<Item_details> item_details;
	}
}