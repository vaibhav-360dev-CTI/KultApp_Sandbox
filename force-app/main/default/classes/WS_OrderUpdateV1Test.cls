@isTest(seeAllData= true)
public class WS_OrderUpdateV1Test {

    @isTest
    static void testUpdateOrders_Success() {
        // Setup test data
        Account testAccount = new Account(Name = 'Test Account', Phone= '213467890');
        insert testAccount;
        
        Product2 objProduct = new Product2(Name = 'TestProduct', Description = 'Test Description');
        insert objProduct;
        
        PriceBook2 pb2Standard = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Id standardPriceBookId = pb2Standard.Id;
        
        PricebookEntry objPBEntry = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = objProduct.Id, UnitPrice = 100, IsActive = true);
        insert objPBEntry;
        
        Order testOrder = new Order(Name = 'TestOrder001', AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = System.today(), Pricebook2Id = standardPriceBookId);
        insert testOrder;
        
        Order subOrder = new Order(Name = 'TestOrder001-SubOrder001', ParentOrder__c = testOrder.Id, AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = standardPriceBookId);
        insert subOrder;
        
        OrderItem orderItem = new OrderItem(OrderId = subOrder.Id, Quantity = 1, UnitPrice = 100.00, SKU__c = 'SKU001', PricebookEntryId = objPBEntry.Id);
        insert orderItem;

        // Create request body
        String requestBody = '[{"order_id": "TestOrder001", "is_coupon_redeemed": true, "order_details": [{"sub_order_id": "SubOrder001", "awb_number": "AWB001", "courier": "CourierService", "expected_delivery_date": "2024-05-25", "sub_order_status": "Delivered", "tracking_link": "http://trackinglink.com", "item_details": [{"sku": "SKU001", "status": "Shipped"}]}]}]';
        
        // Create RestRequest
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Call the method
        Test.startTest();
        List<WS_OrderUpdateV1.ResponseBody> response = WS_OrderUpdateV1.updateOrders();
        Test.stopTest();
        
    }

    @isTest
    static void testUpdateOrders_Error() {
        // Setup test data with missing order_id
        String requestBody = '[{"order_id": null, "is_coupon_redeemed": true, "order_details": [{"sub_order_id": "SubOrder001", "awb_number": "AWB001", "courier": "CourierService", "expected_delivery_date": "2024-05-25", "sub_order_status": "Delivered", "tracking_link": "http://trackinglink.com", "item_details": [{"sku": "SKU001", "status": "Shipped"}]}]}]';
        
        // Create RestRequest
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Call the method
        Test.startTest();
        List<WS_OrderUpdateV1.ResponseBody> response = WS_OrderUpdateV1.updateOrders();
        Test.stopTest();
        
    }

    @isTest
    static void testUpdateOrders_ExceptionHandling() {
        // Simulate exception by sending invalid JSON
        String requestBody = '[{"order_id": "TestOrder001", "is_coupon_redeemed": true, "order_details": [{"sub_order_id": "SubOrder001", "awb_number": "AWB001", "courier": "CourierService", "expected_delivery_date": "invalid-date", "sub_order_status": "Delivered", "tracking_link": "http://trackinglink.com", "item_details": [{"sku": "SKU001", "status": "Shipped"}]}]}]';
        
        // Create RestRequest
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        

        // Call the method
        Test.startTest();
        List<WS_OrderUpdateV1.ResponseBody> response = WS_OrderUpdateV1.updateOrders();
        Test.stopTest();
        
    }
    
    @isTest
    static void testOrderUpdate() {
        WS_OrderUpdate.Order_details orderDetail = new WS_OrderUpdate.Order_details();
        orderDetail.sub_order_id = '123';
        orderDetail.sub_order_status = 'Shipped';
        orderDetail.awb_number = 'AWB123';
        orderDetail.courier = 'XYZ Courier';
        orderDetail.expected_delivery_date = '2024-05-25';
        orderDetail.tracking_link = 'http://tracking.link/123';
        
        WS_OrderUpdate.Item_details itemDetail = new WS_OrderUpdate.Item_details();
        itemDetail.sku = 'SKU123';
        itemDetail.status = 'In transit';
        
        orderDetail.item_details = new List<WS_OrderUpdate.Item_details>{itemDetail};
        
        WS_OrderUpdate orderUpdate = new WS_OrderUpdate();
        orderUpdate.order_id = 'O123';
        orderUpdate.is_coupon_redeemed = true;
        orderUpdate.order_details = new List<WS_OrderUpdate.Order_details>{orderDetail};

        Test.startTest();
       // WS_OrderUpdateV1.dumMethod();
        Test.stopTest();
    }
}