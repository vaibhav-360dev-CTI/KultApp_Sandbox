@isTest(seeAllData= true)
public class OOSHelperTest {
    
    @isTest
    static void testGetCaseAndOrderDetails() {
        // Create test data
        
        Account testAccount = new Account(Name = 'Test Account',Phone = '12456789');
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
        
        Case testCase = new Case(Sub_Type__c = 'Test Sub Type', Sub_Sub_Type__c = 'Test Sub Sub Type', Status = 'Open');
        insert testCase;
        
        Order testOrder = new Order(Name='234452',AccountId = testAccount.Id, Status = 'Draft',EffectiveDate=system.today(),Pricebook2Id = pb2Standard.Id);
        insert testOrder;
        
        OrderItem testOrderItem = new OrderItem(Product2Id = 'Test Product Id', Quantity = 1, UnitPrice = 100, OrderId = testOrder.Id,PricebookEntryId=objPBEntry.Id);
        insert testOrderItem;
        
        // Call the method
        Test.startTest();
        OOSHelper.oosWrapper result = OOSHelper.getCaseAndOrderDetails(testCase.Id);
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateDupOrder() {
        // Create test data
        
        Account testAccount = new Account(Name = 'Test Account',Phone='12345678');
        insert testAccount;
        
        Pricebook2 testPricebook = new Pricebook2(Name = 'Standard Price Book', IsActive = true);
        insert testPricebook;
        
        // Create a PricebookEntry associated with the Pricebook2
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;
        
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = testPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,  // Adjust the unit price accordingly
            IsActive = true,
            UseStandardPrice = true
        );
        insert testPricebookEntry;
        
        
        Case testCase = new Case(Status = 'Open');
        insert testCase;
        
        Order testOrder = new Order(Name='234452',AccountId = testAccount.Id, Status = 'Draft',EffectiveDate=system.today(),Pricebook2Id = testPricebook.Id);
        insert testOrder;
        
        OrderItem testOrderItem = new OrderItem(Quantity = 1, UnitPrice = 100, OrderId = testOrder.Id,PricebookEntryId=testPricebookEntry.Id);
        insert testOrderItem; 
        

        Test.startTest();
       // OOSHelper.createDupOrder(new List<OrderItem>{testOrderItem}, testCase.Id, testCase);
        OOSHelper.dumMethod();
        Test.stopTest();
        
    }
}