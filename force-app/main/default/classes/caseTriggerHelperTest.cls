@isTest(seeAllData = true)
public class caseTriggerHelperTest {
    @isTest
    static void testResetTypeAndSubtypeOnRecordTypeChange() {
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='WareHouse Team' LIMIT 1]; 
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true, Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha1234565432@testorg.com');
        insert userInstant;
        
        Account testAccount = new Account(Name = 'Test Account', Phone ='123456789');
        insert testAccount;
        
       Id RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media').getRecordTypeId();
        system.debug('RecordTypeId ::'+RecordTypeId);
        
        Contact con = new Contact();
        con.accountId = testAccount.Id;
        con.Email = 'new@contact.com';
        con.FirstName = 'Test';
        con.LastName = 'contact';
        Insert Con;
        
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
        OrderItem orderItem1 = new OrderItem(OrderId = subOrder.Id, Quantity = 1, UnitPrice = 100.00, SKU__c = 'SKU001', PricebookEntryId = objPBEntry.Id,Is_Already_Utilized__c = False,Refund_Price__c = 123);
        insert orderItem1;     
        
        Case cse = new Case(Origin = 'Bulk Upload', Status = 'New',RecordTypeId=RecordTypeId, AccountId = testAccount.Id, OrderId__c = testOrder.Id, ContactId = con.Id,
                            Subject = 'Testing', SKU_Details__c = 'testingqwerty', OwnerId = userInstant.Id);
        insert cse;
       Id recTypeId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Inbound Case').getRecordTypeId();
        system.debug('recTypeId ::'+recTypeId);
        Case cs = new Case();
        cs.id = cse.Id;
        cs.RecordTypeId = recTypeId;
        update cs;
        /*
        Map<Id, Case> oldMap = new Map<Id, Case>{cse.Id => cse};
        
        Test.startTest();
       		caseTriggerHelper.resetTypeAndSubtypeOnRecordTypeChange(new List<Case>{cse}, oldMap);
        Test.stopTest();
*/
        
    }

    @isTest
    static void testCreatedAffectedSKUs() {
        Account acc = new Account(Name = 'Test Account', phone = '213456789');
        insert acc;
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'Test';
        objProduct.Description = 'Test';
        Insert objProduct;
        
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        
        // First insert a price for the standard price book
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;
        
        Order ord = new order();
        ord.AccountId = acc.Id;
        ord.EffectiveDate = system.today();
        ord.Status = 'Draft';
        ord.Pricebook2Id = pb.id;
        ord.UTR_Number__c = '123456';
        Insert ord;        
        
        List<Case> cs = new List<Case>();
        Case cse = new Case(Origin = 'Bulk Upload', Status = 'New', AccountId = acc.Id, OrderId__c = ord.Id, SKU_Details__c = 'TestSKU;TestSKU2', OOS_Quantity__c = '1;2');
        cs.add(cse);
        insert cs;
         
        List<OrderItem> orItmList = new List<OrderItem>();        
        OrderItem ordItm = new OrderItem();
        ordItm.OrderId = ord.Id;
        ordItm.UnitPrice = 200;
        ordItm.PricebookEntryId = pbe.Id;
        ordItm.Quantity = 1;
        ordItm.SKU__c = 'TestSKU';
        orItmList.add(ordItm);
        Insert orItmList;
        
        Affected_SKU__c afs = new Affected_SKU__c();
        afs.Case__c = cse.Id;
        afs.Brand_Name__c = 'Test';
        afs.Order_Item__c = ordItm.Id;
        insert afs;
        
        Test.startTest();
        caseTriggerHelper.createdAffectedSKUs(cs);
        Test.stopTest();
    }

    @isTest
    static void testUpdateUserFieldsOnReassignment() {
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Customer Service Executive' LIMIT 1]; 
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true, Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha1234565432@testorg.com');
        insert userInstant;
        
        Account acc = new Account(Name = 'Testing', Phone = '098765432123456');
        insert acc;
        
        Contact con = new Contact(AccountId = acc.Id, Email = 'new@contact.com', FirstName = 'Test', LastName = 'contact');
        insert con;
        
        Case cse = new Case(Origin = 'Bulk Upload', Status = 'New', AccountId = acc.Id, ContactId = con.Id, OwnerId = userInstant.Id);
        insert cse;
        
        Case cseOld = cse.clone(false, true);
        cse.OwnerId = userInstant.Id;
        update cse;
        
        Map<Id, Case> oldMap = new Map<Id, Case>{cseOld.Id => cseOld};
        
        Test.startTest();
        caseTriggerHelper.updateUserFieldsOnReassignment(new List<Case>{cse}, oldMap);
        Test.stopTest();
        
        Case updatedCase = [SELECT CS_Team_Member__c FROM Case WHERE Id = :cse.Id];
        System.assertEquals(userInstant.Id, updatedCase.CS_Team_Member__c);
    }

    @isTest
    static void testSendEmailTemplateWithTemplate() {
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Customer Service Executive' LIMIT 1]; 
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing',FirstName='Banoj', LanguageLocaleKey='en_US',
                                    IsActive=true, Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha1234565432@testorg.com');
        insert userInstant;
        
        Account acc = new Account(Name = 'Testing', Phone = '098765432123456');
        insert acc;
        
        Contact con = new Contact(AccountId = acc.Id, Email = 'new@contact.com', FirstName = 'Test', LastName = 'contact');
        insert con;
        
        Case cse = new Case(Origin = 'Bulk Upload', Status = 'New', AccountId = acc.Id, ContactId = con.Id, 
                            OwnerId = userInstant.Id,Marketing_Team__c=userInstant.Id, 
                            Warehouse_Team_Member__c=userInstant.Id,Sub_Type__c='Order Related',
                            Subject='test subject',Sub_Sub_Type__c='Order Confirmation /Status Issues',CSE_Remarks__c='test remarks',
                           Refer_Back_Reason__c='Resolved',Approval_Remarks__c='test approval',Rejection_Reason__c='test reason',
                           Describe_Information_Needed__c='test description');
        insert cse;
        Map<Id, User> userMap = new Map<Id, User>{userInstant.Id => userInstant};
        
        Test.startTest();
        caseTriggerHelper.SendEmailTemplateWithTemplate(new List<Case>{cse}, userMap);
        Test.stopTest();
        
        // Add assertions as needed based on the email sending logic.
    }

    @isTest
    static void testSendingCustomNotification() {
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Customer Service Executive' LIMIT 1]; 
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true, Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha1234565432@testorg.com');
        insert userInstant;
        
        Account acc = new Account(Name = 'Testing', Phone = '098765432123456');
        insert acc;
        
        Contact con = new Contact(AccountId = acc.Id, Email = 'new@contact.com', FirstName = 'Test', LastName = 'contact');
        insert con;
        
        Case cse = new Case(Origin = 'Bulk Upload', Status = 'New', AccountId = acc.Id, ContactId = con.Id, OwnerId = userInstant.Id);
        insert cse;
        
        Test.startTest();
        caseTriggerHelper.sendingCustomNotification(userInstant.Id, cse.Id, 'Case Assigned', 'A case has been assigned to you.');
        Test.stopTest();
        
        // Add assertions as needed based on the notification logic.*/
    }

    @isTest
    static void testModifyEmailCases() {
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Customer Service Executive' LIMIT 1]; 
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true, Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha1234565432@testorg.com');
        insert userInstant;
        
        Account acc = new Account(Name = 'Testing', Phone = '098765432123456');
        insert acc;
        
        Contact con = new Contact(AccountId = acc.Id, Email = 'new@contact.com', FirstName = 'Test', LastName = 'contact');
        insert con;
        
        Case cse = new Case(Origin = 'Inbound Email', Status = 'New', AccountId = acc.Id, ContactId = con.Id, OwnerId = userInstant.Id, SuppliedEmail = 'new@contact.com');
        insert cse;
        
        Test.startTest();
        caseTriggerHelper.modifyEmailCases(new List<Case>{cse});
        caseTriggerHelper.dumMethod();
        Test.stopTest();
        
        Case updatedCase = [SELECT Communication_Mode__c FROM Case WHERE Id = :cse.Id];
      
    } 
       
}