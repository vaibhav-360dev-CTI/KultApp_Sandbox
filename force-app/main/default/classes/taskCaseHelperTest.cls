@isTest(seeAllData= true)
public class taskCaseHelperTest {
    @isTest
    static void testDumMethod() {
        
        Account testAccount = new Account(Name = 'Test Account',Phone ='23456789');
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
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            OrderId__c = testOrder.Id,
            Origin = 'Inbound Missed Call',
            Status = 'New'
        );
        insert testCase;
        
        Case testCase1 = new Case(
            Subject = 'Test Case',
            OrderId__c = testOrder.Id,
            Origin = 'Inbound Missed Call',
            Status = 'New'
        );
        insert testCase1;
        
        Task testTasks = new Task(WhatId = testCase.Id,Subject = 'Missed Call');
        insert testTasks;
        
        Task testTasks1 = new Task(WhatId = testCase.Id,Subject = 'Outgoing Call');
        insert testTasks1;
        
        Test.startTest();
        taskCaseHelper.getTaskOfCaseBasedOnAccountId(testCase.id);
        Test.stopTest();
    }
    
    @isTest
    static void testDumMethod1() {
        
        Account testAccount = new Account(Name = 'Test Account',Phone='2134567');
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
        
        Case testCase1 = new Case(
            Subject = 'Test Case',
            OrderId__c = testOrder.Id,
            Origin = 'Inbound Missed Call',
            Status = 'New'
        );
        insert testCase1;
        
        Test.startTest();
        taskCaseHelper.getTaskOfCaseBasedOnAccountId(testCase1.id);
        Test.stopTest();
    }
}