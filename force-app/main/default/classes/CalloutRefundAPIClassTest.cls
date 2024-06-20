@isTest
public class CalloutRefundAPIClassTest {
    
    @testSetup
    static void setupData() {
        // Create a mock Refund_API_Details__c custom setting record
        Refund_API_Details__c refundSettings = new Refund_API_Details__c();
        refundSettings.Endpoint__c = 'https://ops.dev.kult.in/api/v1/order/process_refund';
        refundSettings.Access_Token__c = 'Bearer dummy_access_token';
        insert refundSettings;
        
        // Create Account
        Account acc = new Account(Name = 'Test Account', Phone = '1234567890');
        insert acc;
        
        // Create Case
        Case caseRec = new Case(
            AccountId = acc.Id, 
            Refund_Type__c = 'Partial'
        );
        insert caseRec;
        
        Product2 pro = new Product2(Name='Test Product', isActive=true);
        insert pro;
        
        // Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        // Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        // Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id LIMIT 1];
        // It should return true
       // System.assertEquals(true, standardPricebook.IsStandard);
        
        // Insert PricebookEntry for Standard Price
        insert new PricebookEntry(Product2Id=pro.Id, Pricebook2Id=standardPricebook.Id, UnitPrice=0);
        
        //Insert New Test Pricebook
        Pricebook2 pbt = new Pricebook2(Name='Test Price Book', isActive=true);
        insert pbt;
        
        // Create the new PricebookEntry
        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = pbt.Id,
            Product2Id = pro.Id,
            UnitPrice = 100,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe2;
        
        Account account = new Account(Name='Test Account',Phone = '23456789');
        insert account;
        
        // Create Order
        Order order = new Order(
            AccountId = acc.Id, 
            Pricebook2Id = pbt.Id, 
            EffectiveDate = Date.today(), 
            Status = 'Draft'
        );
        insert order;
        
        // Create OrderItem
        OrderItem orderItem = new OrderItem(
            OrderId = order.Id, 
            Quantity = 1, 
            UnitPrice = 100.00, 
            SKU__c = 'SKU001', 
            PricebookEntryId = pbe2.Id, 
            Is_Already_Utilized__c = false, 
            Refund_Price__c = 123
        );
        OrderItem orderItem1 = new OrderItem(
            OrderId = order.Id, 
            Quantity = 1, 
            UnitPrice = 100.00, 
            SKU__c = 'SKU001', 
            PricebookEntryId = pbe2.Id, 
            Is_Already_Utilized__c = false, 
            Refund_Price__c = 123
        );
        List<OrderItem> orItemsToInsert = new List<OrderItem>();
        orItemsToInsert.add(orderItem);
        orItemsToInsert.add(orderItem1);
        insert orItemsToInsert;
        
        // Create Affected_SKU__c records
        Affected_SKU__c affectedSKU = new Affected_SKU__c(
            Case__c = caseRec.Id, 
            Name = 'SKU001', 
            Order_Item__c = orderItem.Id
        );
        Affected_SKU__c affectedSKU1 = new Affected_SKU__c(
            Case__c = caseRec.Id, 
            Name = 'SKU001', 
            Order_Item__c = orderItem1.Id
        );
        List<Affected_SKU__c> affSKUstoInsert = new List<Affected_SKU__c>();
        affSKUstoInsert.add(affectedSKU1);
        affSKUstoInsert.add(affectedSKU);
        insert affSKUstoInsert;
        
  
    } 
    
    @isTest
    static void testPostRefundRequest() {
        // Mock HTTP response for the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Get a Case Id for testing
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Call the method
        String result = CalloutRefundAPIClass.postRefundRequest(testCase.Id);
        CalloutRefundAPIClass.dumMethod();
        
    }
    
   
    
}