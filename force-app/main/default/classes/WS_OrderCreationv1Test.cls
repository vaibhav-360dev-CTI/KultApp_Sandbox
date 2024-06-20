@isTest
public class WS_OrderCreationv1Test {

    @isTest
    static void testDoPost() {
        Test.startTest();

        // Create mock data
        List<WS_OrderCreation> orderList = new List<WS_OrderCreation>();

        WS_OrderCreation wsOrder = new WS_OrderCreation();
        wsOrder.data = new WS_OrderCreation.Data();
        wsOrder.data.order_id = 'ORD123';
        // wsOrder.data.order_date = System.now();
        wsOrder.data.payment_id = 'PAY123';
        wsOrder.data.payment_status = 'Paid';
        wsOrder.data.payment_type = 'Credit Card';
        wsOrder.data.amount = 100.00;
        wsOrder.data.coupon_code = 'DISCOUNT10';
        // wsOrder.data.coupon_discount = 10.00;
        wsOrder.data.is_coupon_redeemed = true;
        wsOrder.data.order_status = 'Pending';

        wsOrder.data.customer_details = new WS_OrderCreation.CustomerDetails();
        wsOrder.data.customer_details.name = 'John Doe';
        wsOrder.data.customer_details.email = 'john.doe@example.com';
        wsOrder.data.customer_details.phone_number = '1234567890';

        wsOrder.data.address_details = new WS_OrderCreation.AddressDetails();
        wsOrder.data.address_details.billing_address = new WS_OrderCreation.DeliveryAddress();
        wsOrder.data.address_details.billing_address.street = '123 Main St';
        wsOrder.data.address_details.billing_address.city = 'Metropolis';
        wsOrder.data.address_details.billing_address.state = 'NY';
        wsOrder.data.address_details.billing_address.country_code = 'US';
        wsOrder.data.address_details.billing_address.pin_code = '10001';

        wsOrder.data.address_details.shipping_address = new WS_OrderCreation.ShippingAddress();
        wsOrder.data.address_details.shipping_address.street = '123 Main St';
        wsOrder.data.address_details.shipping_address.city = 'Metropolis';
        wsOrder.data.address_details.shipping_address.state = 'NY';
        wsOrder.data.address_details.shipping_address.country_code = 'US';
        wsOrder.data.address_details.shipping_address.pin_code = '10001';
        wsOrder.data.address_details.shipping_address.phone_number = '0987654321';

        WS_OrderCreation.OrderDetails orderDetails = new WS_OrderCreation.OrderDetails();
        orderDetails.sub_order_id = 'SO123';
        orderDetails.sub_order_seller_name = 'Seller A';
        orderDetails.awb_number = 'AWB123456';
        orderDetails.courier = 'Courier XYZ';
        // orderDetails.expected_delivery_date = Date.today().addDays(5);
        orderDetails.Sub_order_status = 'Pending';
        orderDetails.tracking_link = 'http://tracking.com/awb123456';

        orderDetails.item_details = new List<WS_OrderCreation.ItemDetails>();

        WS_OrderCreation.ItemDetails itemDetails = new WS_OrderCreation.ItemDetails();
        itemDetails.sku = 'SKU123';
        itemDetails.variant_name = 'Variant A';
        itemDetails.brand = 'Brand X';
        // itemDetails.mrp = 50.00;
        itemDetails.selling_price = 45.00;
        itemDetails.quantity = 1;
        // itemDetails.refunded_price = 0.00;
        itemDetails.status = 'Pending';

        orderDetails.item_details.add(itemDetails);

        wsOrder.data.order_details = new List<WS_OrderCreation.OrderDetails>();
        wsOrder.data.order_details.add(orderDetails);

        orderList.add(wsOrder);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String endpoint = 'https://kultapp--kultapp.sandbox.my.salesforce.com/services/apexrest/OrderCreation';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(orderList));

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.assertEquals(200, res.getStatusCode(), 'Expected HTTP status code 200');

        Test.stopTest();
    }

}