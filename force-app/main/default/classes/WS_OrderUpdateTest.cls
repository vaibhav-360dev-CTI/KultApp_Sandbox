@isTest
public class WS_OrderUpdateTest {
    @isTest
    static void testWSOrderUpdate() {
        // Create instance of WS_OrderUpdate
        WS_OrderUpdate orderUpdate = new WS_OrderUpdate();
        orderUpdate.order_id = '12345';
        orderUpdate.is_coupon_redeemed = true;

        // Create instance of Order_details
        WS_OrderUpdate.Order_details orderDetails = new WS_OrderUpdate.Order_details();
        orderDetails.sub_order_id = 'sub123';
        orderDetails.sub_order_status = 'Shipped';
        orderDetails.awb_number = 'awb123';
        orderDetails.courier = 'DHL';
        orderDetails.expected_delivery_date = '2024-06-15';
        orderDetails.tracking_link = 'http://trackinglink.com';

        // Create instance of Item_details
        WS_OrderUpdate.Item_details itemDetails = new WS_OrderUpdate.Item_details();
        itemDetails.sku = 'sku123';
        itemDetails.status = 'Delivered';

        // Add Item_details to Order_details
        orderDetails.item_details = new List<WS_OrderUpdate.Item_details>();
        orderDetails.item_details.add(itemDetails);

        // Add Order_details to WS_OrderUpdate
        orderUpdate.order_details = new List<WS_OrderUpdate.Order_details>();
        orderUpdate.order_details.add(orderDetails);

    }
}