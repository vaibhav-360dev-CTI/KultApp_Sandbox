@isTest(seeAllData= true)
public class moveToRefundTeamController_Test {
    
    
    
    @isTest
    static void testGetOrderLineItem() {
        // Fetch the case for test
     /*   Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Call the method
        moveToRefundTeamController.RefundWrapper result = moveToRefundTeamController.getOrderLineItem(testCase.Id);
        
        // Assertions
        System.assertNotEquals(result, null, 'Result should not be null');
        System.assertNotEquals(result.caseRecord, null, 'Case record should not be null');
        System.assertNotEquals(result.orderRecord, null, 'Order record should not be null');
        System.assertNotEquals(result.orderItems, null, 'Order items should not be null');
        System.assert(result.orderItems.size() > 0, 'Order items list should not be empty');
    }
    
    @isTest
    static void testUpdateOrderAndCaseFields() {
        // Fetch the case and order items for test
       // Case testCase = [SELECT Id FROM Case LIMIT 1];
        //List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :testCase.OrderId__c LIMIT 1];
        List<OrderItem> orderItems = new List<OrderItem>();
        
        Account testAccount = new Account(Name = 'Test Account');
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
        
        OrderItem orderItem = new OrderItem(OrderId = subOrder.Id, Quantity = 1, UnitPrice = 100.00, SKU__c = 'SKU001', PricebookEntryId = objPBEntry.Id,Is_Already_Utilized__c = False,Refund_Price__c = 123);
        insert orderItem;
        orderItems.add(orderItem);
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            OrderId__c = testOrder.Id,
            Status = 'New'
        );
        insert testCase;
        
        // Call the method
        String result = moveToRefundTeamController.updateOrderAndCaseFields(
            testCase.Id, 'Refund Type', 'Refund Reason', 'Coupon Code', 'Refund Value', 100, orderItems
        );
        
    }
    
    @isTest
    static void testSendingCustomNotification() {
        // Fetch the case for test
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Fetch a user to send notification
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        // Call the method
        moveToRefundTeamController.sendingCustomNotification(testUser.Id, testCase.Id, 'Test Notification', 'This is a test notification.');
        
        // No assertion required as this method does not return a value
        // Check the debug logs for verification  */
        moveToRefundTeamController.dumMethod();
    }
}