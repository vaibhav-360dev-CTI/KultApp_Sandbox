@isTest(seeAllData= true)
private class TaskHelperControllerTest {
    
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
        
        Account testAccount = new Account(Name = 'Test Account');
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
        Test.startTest();
        Case result = taskHelperController.createCaseFromCase('Subject', 'Contact Number', 'Record Id', 'Order Id');
        Test.stopTest();
        
    }
}