@isTest
public class moveToRefundTeamController_Test {

    @isTest
    static void testGetOrderLineItem() {
        Account testAccount = new Account(Name = 'Test Account', Phone = '23456789');
        insert testAccount;
        
        Order testOrder = new Order(Name = 'TestOrder001', Status = 'Draft', EffectiveDate = System.today(), AccountId = testAccount.Id);
        insert testOrder;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            OrderId__c = testOrder.Id
        );
        insert testCase;
        
        moveToRefundTeamController.RefundWrapper result = moveToRefundTeamController.getOrderLineItem(testCase.Id);
        
    }
    
    @isTest
    static void testUpdateOrderAndCaseFields() {
        // Setup test data
        Account testAccount = new Account(Name = 'Test Account', Phone = '23456789');
        insert testAccount;
        
        Product2 objProduct = new Product2(Name = 'TestProduct', Description = 'Test Description');
        insert objProduct;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;
        
        PricebookEntry objPBEntry = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = objProduct.Id, UnitPrice = 100, IsActive = true);
        insert objPBEntry;
        
        Order testOrder = new Order(Name = 'TestOrder001', AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = System.today(), Pricebook2Id = standardPricebook.Id);
        insert testOrder;
        
        Order subOrder = new Order(Name = 'TestOrder001-SubOrder001', ParentOrder__c = testOrder.Id, AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = standardPricebook.Id);
        insert subOrder;
        
        OrderItem orderItem = new OrderItem(OrderId = subOrder.Id, Quantity = 1, UnitPrice = 100.00, SKU__c = 'SKU001', PricebookEntryId = objPBEntry.Id, Is_Already_Utilized__c = true, Refund_Price__c = 123, Refund_Quantity__c = 1, Selling_Price__c = 100);
        insert orderItem;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            OrderId__c = testOrder.Id,
            Status = 'New'
        );
        insert testCase;
        
        List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :subOrder.Id];
        String result = moveToRefundTeamController.updateOrderAndCaseFields(
            testCase.Id, 'Refund Type', 'Refund Reason', 'Coupon Code', 'Refund Value', 100, orderItems
        );
        
        testCase = [SELECT Status, Refund_Amount__c, SKU_Details__c FROM Case WHERE Id = :testCase.Id];
        
        List<Affected_SKU__c> affectedSKUs = [SELECT Id, Name FROM Affected_SKU__c WHERE Case__c = :testCase.Id];
    }
    
    @isTest
    static void testSendingCustomNotification() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert testCase;
        
        User testUser = [SELECT Id FROM User LIMIT 1];

        moveToRefundTeamController.sendingCustomNotification(testUser.Id, testCase.Id, 'Test Notification', 'This is a test notification.');
    }

    @isTest
    static void testUpdateOrderAndCaseFieldsWithoutOrder() {
        Account testAccount = new Account(Name = 'Test Account', Phone = '23456789');
        insert testAccount;
        
        Case testCase = new Case(
            Subject = 'Test Case without Order',
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;
        
        List<OrderItem> orderItems = new List<OrderItem>();
        String result = moveToRefundTeamController.updateOrderAndCaseFields(
            testCase.Id, 'Refund Type', 'Refund Reason', 'Coupon Code', 'Refund Value', 100, orderItems
        );

        testCase = [SELECT Status FROM Case WHERE Id = :testCase.Id];
    }

    @isTest
    static void testUpdateOrderAndCaseFieldsErrorPath() {
        Case testCase = new Case(
            Subject = 'Test Case with Error',
            Status = 'New'
        );
        insert testCase;
        
        List<OrderItem> orderItems = new List<OrderItem>();
        String result = moveToRefundTeamController.updateOrderAndCaseFields(
            'invalidId', 'Refund Type', 'Refund Reason', 'Coupon Code', 'Refund Value', 100, orderItems
        );
    }
}