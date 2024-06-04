@isTest
public class moveToRefundTeamController_Test {
    
    @isTest
    static void testGetOrderLineItem() {
        // Fetch the case for test
        Account testAccount1 = new Account(Name = 'Test Account',Phone = '23456789');
        insert testAccount1;
       
        Order testOrder1 = new Order(Name = 'TestOrder001', Status = 'Draft', EffectiveDate = System.today(),AccountId = testAccount1.Id );
        insert testOrder1;
        
          Case testCase1 = new Case(
            Subject = 'Test Case',
            Status = 'New',
            OrderId__c =  testOrder1.Id 
              
        );
        insert testCase1;
        
       // Case testCase = [SELECT Id,Status FROM Case Where ID = :testCase1.Id LIMIT 1];
        
        // Call the method
        moveToRefundTeamController.RefundWrapper result = moveToRefundTeamController.getOrderLineItem(testCase1.Id);
        
    }
    
    @isTest
    static void testUpdateOrderAndCaseFields() {
        // Fetch the case and order items for test
       // Case testCase = [SELECT Id FROM Case LIMIT 1];
        //List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :testCase.OrderId__c LIMIT 1];
        List<OrderItem> orderItems = new List<OrderItem>();
        
        Account testAccount = new Account(Name = 'Test Account',Phone = '23456789');
        insert testAccount;
        
        Product2 objProduct = new Product2(Name = 'TestProduct', Description = 'Test Description');
        insert objProduct;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        
        // Retrieve the standard price book
           // Pricebook2 standardPriceBook = [SELECT Id FROM Pricebook2 WHERE Id=:pb2Standard.Id LIMIT 1];
            //Id standardPriceBookId = standardPriceBook.Id;
        
       // PriceBook2 pb2Standard = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
       // Id standardPriceBookId = pb2Standard.Id;
        
        PricebookEntry objPBEntry = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = objProduct.Id, UnitPrice = 100, IsActive = true);
        insert objPBEntry;
        
        Order testOrder = new Order(Name = 'TestOrder001', AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = System.today(), Pricebook2Id = standardPricebook.Id);
        insert testOrder;
        
        Order subOrder = new Order(Name = 'TestOrder001-SubOrder001', ParentOrder__c = testOrder.Id, AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = Date.today(), Pricebook2Id = standardPricebook.Id);
        insert subOrder;
        
        OrderItem orderItem = new OrderItem(OrderId = subOrder.Id, Quantity = 1, UnitPrice = 100.00, SKU__c = 'SKU001', PricebookEntryId = objPBEntry.Id,Is_Already_Utilized__c = false,Refund_Price__c = 123);
        insert orderItem;
        orderItems.add(orderItem);
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            OrderId__c = testOrder.Id,
            Status = 'New'
        );
        insert testCase;
        Case cs = [Select Id,Subject,AccountId,Status FROM Case Where ID = :testCase.Id];
        cs.Subject = 'Test';
        cs.AccountId = testAccount.Id;
        update cs;
        
        /*Case_Progress_Detail__c cpd = new Case_Progress_Detail__c();
        cpd.WH_Team_Remarks__c = 'Test1';
        cpd.CS_Remarks__c = 'refundReason';
        cpd.Status__c = 'In Progress'; 
        cpd.Current_Action__c = 'Moved to Refund Team';
        cpd.Case__c = cs.Id;
        insert cpd;*/
        
        //CaseShare csh = new CaseShare();
        //csh.Id = cs.Id;
        //csh.CaseAccessLevel = 'Edit';
        
        // Call the method
        String result = moveToRefundTeamController.updateOrderAndCaseFields(
            testCase.Id, 'Refund Type', 'Refund Reason', 'Coupon Code', 'Refund Value', 100, orderItems
        );
        moveToRefundTeamController.dumMethod();
        
    }
    
    @isTest
    static void testSendingCustomNotification() {
        // Fetch the case for test
         Case testCase2 = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert testCase2;
        
        //Case testCase= [SELECT Id,Status FROM Case Where ID = :testCase2.Id LIMIT 1];
        
        
        // Fetch a user to send notification
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        // Call the method
        moveToRefundTeamController.sendingCustomNotification(testUser.Id, testCase2.Id, 'Test Notification', 'This is a test notification.');
        
        // No assertion required as this method does not return a value
        // Check the debug logs for verification  
       
    }
}