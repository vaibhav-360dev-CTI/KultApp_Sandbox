@isTest(seeAllData = true)
public class createdAffectedSKUsTesr {
    @isTest
    static void testResetTypeAndSubtypeOnRecordTypeChange1() { 
        User use = [SELECt Id,Name FRom User LIMIT 1];
        Order ord = [SELECT Id FROM Order LIMIT 1];
        Account acc = new Account(Name = 'Testing', Phone = '098765432123456');
        insert acc;
        
        Contact con = new Contact(AccountId = acc.Id, Email = 'new@contact.com', FirstName = 'Test', LastName = 'contact');
        insert con;
        
        
        Product2 objProduct = new Product2(Name = 'TestProduct', Description = 'Test Description');
        insert objProduct;
        
        PriceBook2 pb2Standard = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Id standardPriceBookId = pb2Standard.Id;
        
        PricebookEntry objPBEntry = new PricebookEntry(Pricebook2Id = standardPriceBookId, Product2Id = objProduct.Id, UnitPrice = 100, IsActive = true);
        insert objPBEntry;
        
        Order testOrder = new Order(Name = 'TestOrder001',ParentOrder__c=ord.id, AccountId = acc.Id, Status = 'Draft', EffectiveDate = System.today(), Pricebook2Id = standardPriceBookId);
        insert testOrder;
        
        Case cse = new Case(Marketing_Team__c	 = use.id,Warehouse_Team_Member__c	=use.id,RefundTeamMember__c=use.id,Origin = 'Bulk Upload',SKU_Details__c='Test1',OOS_Quantity__c ='2', Status = 'New', AccountId = acc.Id, ContactId = con.Id, OwnerId = use.Id,OrderId__c=testOrder.id);
        insert cse;
        
      //  OrderItem orderItem = new OrderItem( Quantity = 1,OrderId=cse.Order__c, UnitPrice = 100.00, SKU__c = 'SKU001', PricebookEntryId = objPBEntry.Id,Is_Already_Utilized__c = False,Refund_Price__c = 123);
      //  insert orderItem;
    }
}