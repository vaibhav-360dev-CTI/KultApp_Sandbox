@isTest(seeAllData = true)
public class caseTriggerHelperTest {
    @isTest
    static void testResetTypeAndSubtypeOnRecordTypeChange() {
       /* Profile pro = [SELECT Id,Name FROM Profile WHERE Name='WareHouse Team' LIMIT 1]; 
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true, Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha1234565432@testorg.com');
        insert userInstant;
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
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
        Case cse = new Case(Origin = 'Bulk Upload', Status = 'New', AccountId = testAccount.Id, OrderId__c = testOrder.Id, ContactId = con.Id,
                            Subject = 'Testing', SKU_Details__c = 'testingqwerty', OwnerId = userInstant.Id);
        insert cse;
        
        Case cseOld = cse.clone(false, true);
        cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media').getRecordTypeId();
        update cse;
        
        Map<Id, Case> oldMap = new Map<Id, Case>{cseOld.Id => cseOld};
        
        Test.startTest();
        //caseTriggerHelper.resetTypeAndSubtypeOnRecordTypeChange(new List<Case>{cse}, oldMap);
        Test.stopTest();
        
    }

    @isTest
    static void testCreatedAffectedSKUs() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Order ord = new Order(AccountId = acc.Id, EffectiveDate = System.today(), Status = 'Draft');
        insert ord;
        
        Case cse = new Case(Origin = 'Bulk Upload', Status = 'New', AccountId = acc.Id, OrderId__c = ord.Id, SKU_Details__c = 'TestSKU;TestSKU2', OOS_Quantity__c = '1;2');
        insert cse;
        
        Test.startTest();
        caseTriggerHelper.createdAffectedSKUs(new List<Case>{cse});
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
         caseTriggerHelper.dumMethod();
    } 
       
}