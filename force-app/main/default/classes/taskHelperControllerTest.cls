@isTest(seeAllData= true)
private class taskHelperControllerTest {
    
    @isTest
    static void testFetchDependentPicklist() {
        Test.startTest();
        Map<String, List<String>> result = taskHelperController.fetchDependentPicklist();
        Test.stopTest();
        
    }
    
    @isTest
    static void testDependentFields() {
        Test.startTest();
        Map<String, List<String>> result = taskHelperController.dependentFields();
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetOrderItems() {
        
        Account testAccount = new Account(Name = 'Test Account', Phone = '12345678');
        insert testAccount;
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'Tesrtt';
        objProduct.Description = 'Tesrt';
        Insert objProduct;
        
        PriceBook2 pb2Standard = [Select Id from Pricebook2 where isStandard=true limit 1];
        
        PricebookEntry objPBEntry = new PricebookEntry();
        objPBEntry.Pricebook2Id =pb2Standard.id;
        objPBEntry.Product2Id = objProduct.id;
        objPBEntry.UnitPrice = 100;  
        objPBEntry.IsActive = true;
        Insert objPBEntry;
        
        /*Case testCase = new Case(Sub_Type__c = 'Full', Sub_Sub_Type__c = 'Full', Status = 'Open');
insert testCase;*/
        
        Order testOrder = new Order(Name='234452',AccountId = testAccount.Id, Status = 'Draft',EffectiveDate=system.today(),Pricebook2Id = pb2Standard.Id);
        insert testOrder;
        
        Order testOrder1 = new Order(Name='234452',AccountId = testAccount.Id, Status = 'Draft',EffectiveDate=system.today(),Pricebook2Id = pb2Standard.Id,ParentOrder__c = testOrder.Id);
        insert testOrder1;
        
        Test.startTest();
        List<OrderItem> result = taskHelperController.getOrderItems(testOrder.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateCaseFromCase() {
        
        Account testAccount = new Account(Name = 'Test Account', Phone='12345678');
        insert testAccount;
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'Tesrtt';
        objProduct.Description = 'Tesrt';
        Insert objProduct;
        
        PriceBook2 pb2Standard = [Select Id from Pricebook2 where isStandard=true limit 1];
        
        PricebookEntry objPBEntry = new PricebookEntry();
        objPBEntry.Pricebook2Id =pb2Standard.id;
        objPBEntry.Product2Id = objProduct.id;
        objPBEntry.UnitPrice = 100;  
        objPBEntry.IsActive = true;
        Insert objPBEntry;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;
        
        Order testOrder = new Order(Name='234452',AccountId = testAccount.Id, Status = 'Draft',EffectiveDate=system.today(),Pricebook2Id = pb2Standard.Id);
        insert testOrder;
        
        Order testOrder1 = new Order(Name='234452',AccountId = testAccount.Id, Status = 'Draft',EffectiveDate=system.today(),Pricebook2Id = pb2Standard.Id,ParentOrder__c = testOrder.Id);
        insert testOrder1;
        
        Task testTasks = new Task(WhatId = testCase.Id);
        insert testTasks;
        
        Test.startTest();
        taskHelperController.getCaseRecords();
        Case result = taskHelperController.createCaseFromCase('Subject', '234126', testTasks.Id, testOrder.Id);
        Test.stopTest();        
    }
}