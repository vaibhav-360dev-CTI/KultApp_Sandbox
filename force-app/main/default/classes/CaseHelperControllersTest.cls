@isTest(seeAllData = true)
public class CaseHelperControllersTest {
    @isTest
    static void testClass(){
        
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='WareHouse Team']; 
        Map<Id,User> userMap = new Map<Id,User>();
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha1234565432@testorg.com');
        insert userInstant;
        userMap.put(userInstant.Id,userInstant);
        
        Account acc = new Account();
        acc.Name = 'Testing';
        acc.Phone = '098765432123456';
        Insert acc;
        
        Contact con = new Contact();
        con.accountId = acc.Id;
        con.Email = 'new@contact.com';
        con.FirstName = 'Test';
        con.LastName = 'contact';
        Insert Con;                
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'Tesrtt';
        objProduct.Description = 'Tesrt';
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
        
        List<OrderItem> orItmList = new List<OrderItem>();        
        OrderItem ordItm = new OrderItem();
        ordItm.OrderId = ord.Id;
        ordItm.UnitPrice = 200;
        ordItm.PricebookEntryId = pbe.Id;
        ordItm.Quantity = 1;
        ordItm.SKU__c = 'Test';
        orItmList.add(ordItm);
        Insert orItmList;
        
        Map<Id,Case> oldMapOfCase = new Map<Id,Case>();        
        Case cse = new Case();
        cse.Status = 'New';        
        cse.OrderId__c = ord.Id;
        cse.ContactId = con.Id;
        cse.subject = 'Testing';
        cse.Sub_Type__c = 'Order Related';
        cse.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse.Re_Opening_Reason__c = 'qwertyuioi';
        cse.Contact_Number__c = '1245678765';
        cse.OutBound_PinCode_not_Serviceable__c = false;
        cse.InBound_PinCode_not_Serviceable__c = false;
        cse.OutBound_Dealy_In_Delivery__c = false;
        cse.Inbound_Dealy_In_Delivery__c = false;
        cse.Reason_for_RTO__c = 'Code verified cancellation';
        cse.Category__c = 'Query';
        cse.RTO_Reso__c = 'Initiate Refund';
        cse.Describe_Information_Needed__c = 'Yes';
        Insert cse;
        cse.OutBound_PinCode_not_Serviceable__c = true;
        cse.InBound_PinCode_not_Serviceable__c = true;
        cse.OutBound_Dealy_In_Delivery__c = true;
        cse.Inbound_Dealy_In_Delivery__c =  true;
        cse.Reason_for_RTO__c = 'WhatsApp verified cancellation';
        update cse;
        oldMapOfCase.put(cse.Id,cse);
        
        List<String> cseListString = new List<String>();
        List<Case> cseList = new List<Case>();
        Case cse1 = new Case();
        
        cse1.Status = 'New';
        cse1.AccountId = acc.Id;
        cse1.OrderId__c = ord.Id;
        cse1.ContactId = con.Id;
        cse1.subject = 'Testing';
        cse1.Sub_Type__c = 'Order Related';
        cse1.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse1.Re_Opening_Reason__c = 'qwertyuioi';
        cse1.Contact_Number__c = '1245678765';
        cseList.add(cse1);
        
        Case cse2 = new Case();
        cse2.Status = 'New';
        cse2.AccountId = acc.Id;
        cse2.OrderId__c = ord.Id;
        cse2.ContactId = con.Id;
        cse2.subject = 'Testing';
        cse2.Sub_Type__c = 'Order Related';
        cse2.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse2.Re_Opening_Reason__c = 'qwertyuioi';
        cse2.Contact_Number__c = '1245678765';
        cseList.add(cse2);
        Insert cseList;
        
        for (Case c : cseList) {
            Case cs = new Case();
            cs.Id = c.Id;
            cs.Status = 'Closed';
        }
        update cseList;
        cseListString.add(cseList[0].id);
        
        Task newTask = new Task();
        newTask.Subject = 'Case has been assigned to Move to Refund Team';
        newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
        newTask.WhatId = cse.Id; 
        
        insert newTask;
        
        
        CaseHelperControllers.dependentFields();
        CaseHelperControllers.reOpenCase(cse.Id,cse.Re_Opening_Reason__c);
        CaseHelperControllers.fetchDependentPicklist();
        CaseHelperControllers.getRelatedCases(cse.Id);
        CaseHelperControllers.mergeSelectedCases(cse.Id,cseList);        
        //CaseHelperControllers.sendEmailToContactOwnerAndSendNotificationToOMSTeam(new List<Case>{cse},oldMapOfCase);
        CaseHelperControllers.courierRelatedCase(cse.Id);
        CaseHelperControllers.updateCaseAndOrder(cse.Id);
        CaseHelperControllers.sendNotificationToOrderManagementTeam(cse.Id);
        CaseHelperControllers.getProfileBasedUserList();
        CaseHelperControllers.showAllCaseData(cse.Id);
        //CaseHelperControllers.UpdateCaseRecord(cse.Id,cse.OrderId__c);
        CaseHelperControllers.getAllRelatedOrderItems(cse.OrderId__c);
        CaseHelperControllers.getOrderItems(cse.OrderId__c); 
        CaseHelperControllers.getCaseFieldSetListForCourierIssue();
        CaseHelperControllers.createChildCase('Tech','Order Related','Order Confirmation /Status Issues',acc.Id,con.id,'Case has been assigned to Move to Refund Team','1245678765',cse.Id,userInstant.Id);
        //CaseHelperControllers.createCaseUnderAccount(cse.Id,'Tech','Order Related','Order Confirmation /Status Issues','Case has been assigned to Move to Refund Team','Yes',cse.OrderId__c,'Query');
        CaseHelperControllers.mergeCaseBasedOnAccIdConIdEmailIdPhoneNumberInstagram(cse.Id);
        CaseHelperControllers.mergeDuplicateCases(cseListString);
        CaseHelperControllers.closeCase(cse.Id);
    }
    
    
    @isTest
    static void testClass1(){
        
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Customer Service Executive' Limit 1]; 
        
        Map<Id,User> userMap = new Map<Id,User>();
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha1234565432@testorg.com');
        insert userInstant;
        userMap.put(userInstant.Id,userInstant);
        
        Account acc = new Account();
        acc.Name = 'Testing';
        acc.Phone = '098765432123456';
        Insert acc;
        
        Contact con = new Contact();
        con.accountId = acc.Id;
        con.Email = 'new@contact.com';
        con.FirstName = 'Test';
        con.LastName = 'contact';
        Insert Con;
        
        
        
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'Tesrtt';
        objProduct.Description = 'Tesrt';
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
        
        List<OrderItem> orItmList = new List<OrderItem>();        
        OrderItem ordItm = new OrderItem();
        ordItm.OrderId = ord.Id;
        ordItm.UnitPrice = 200;
        ordItm.PricebookEntryId = pbe.Id;
        ordItm.Quantity = 1;
        ordItm.SKU__c = 'Test';
        orItmList.add(ordItm);
        Insert orItmList;
        
        List<Id> ordLinItmList = new List<Id>();
        for (OrderItem oi : orItmList) {
            ordLinItmList.add(oi.Id);
        }
        
        Map<Id,Case> oldMapOfCase = new Map<Id,Case>();
        
        Case cse = new Case();
        cse.Status = 'New';
        
        cse.OrderId__c = ord.Id;
        cse.ContactId = con.Id;
        cse.subject = 'Testing';
        cse.Sub_Type__c = 'Order Related';
        cse.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse.Re_Opening_Reason__c = 'qwertyuioi';
        cse.Contact_Number__c = '1245678765';
        cse.OutBound_PinCode_not_Serviceable__c = false;
        cse.InBound_PinCode_not_Serviceable__c = false;
        cse.OutBound_Dealy_In_Delivery__c = false;
        cse.Inbound_Dealy_In_Delivery__c = false;
        cse.Reason_for_RTO__c = 'Code verified cancellation';
        cse.Category__c = 'Query';
        cse.RTO_Reso__c = 'Initiate Refund';
        Insert cse;
        cse.OutBound_PinCode_not_Serviceable__c = true;
        cse.InBound_PinCode_not_Serviceable__c = true;
        cse.OutBound_Dealy_In_Delivery__c = true;
        cse.Inbound_Dealy_In_Delivery__c =  true;
        cse.Reason_for_RTO__c = 'WhatsApp verified cancellation';
        update cse;
        oldMapOfCase.put(cse.Id,cse);
        
        
        List<Case> cseList = new List<Case>();
        Case cse1 = new Case();
        
        cse1.Status = 'New';
        cse1.AccountId = acc.Id;
        cse1.OrderId__c = ord.Id;
        cse1.ContactId = con.Id;
        cse1.subject = 'Testing';
        cse1.Sub_Type__c = 'Order Related';
        cse1.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse1.Re_Opening_Reason__c = 'qwertyuioi';
        cse1.Contact_Number__c = '1245678765';
        Insert cse1;
        cseList.add(cse1);
        
        
        
        Task newTask = new Task();
        newTask.Subject = 'Case has been assigned to Move to Refund Team';
        newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
        newTask.WhatId = cse.Id;         
        insert newTask;
        
        Test.startTest();
        CaseHelperControllers.getAllProfileNames();
        CaseHelperControllers.manualCaseShare(cse.Id,userInstant.Id);
        CaseHelperControllers.getCaseRec(cse.Id);
        CaseHelperControllers.getCaseRecordTypes();
        CaseHelperControllers.getCaseFieldSetListss();
        CaseHelperControllers.getCaseFieldSetList();
        CaseHelperControllers.getAllCaseFields();
        CaseHelperControllers.getRecrdTypeId(cse.Id);
        CaseHelperControllers.getRecrdTypeIdChat();
        CaseHelperControllers.caseRecord(cse.Id);
        CaseHelperControllers.getCaseRecord(cse.Id);
        CaseHelperControllers.getCaseRecords();
        CaseHelperControllers.getAllRT();
        CaseHelperControllers.createCaseInLiveChatTranscript('Tech','Order Related','Order Confirmation /Status Issues',cse.AccountId,cse.ContactId,newTask.Subject,cse.Contact_Number__c,cse.Id,userInstant.Id,cse.OrderId__c); 
       // CaseHelperControllers.returnToOrigin(cse.Id,'Code verified cancellation','Initiate Refund');
        CaseHelperControllers.updateStatusfield(cse.Id,'New');
        CaseHelperControllers.loadcasestatus(cse.Id);
        CaseHelperControllers.createCaseFromContact('Test','1234567890',cse.Id,ord.Id);
        CaseHelperControllers.createCaseFromAccount('Test','1234567890',cse.Id,ord.Id);
        CaseHelperControllers.createCaseFromAccount(null,null,null,null);
        CaseHelperControllers.getOrderIfItHasLineItems(cse.Id);
        CaseHelperControllers.updateSKUdetailsAndCreateRecordOfSKU(cse.Id,ord.Id,ordLinItmList,orItmList);
        CaseHelperControllers.getRecentProgress(cse.Id);
        CaseHelperControllers.updateRecentProgress(cse.Id,'Yes');
        Test.stopTest();
        
    }
    
  /* @isTest
    static void testReturnToOrigin() {
        Account acc = new Account(Name = 'Testing', Phone = '098765432123456');
        insert acc;
        
        Contact con = new Contact(AccountId = acc.Id, Email = 'new@contact.com', FirstName = 'Test', LastName = 'contact');
        insert con;
        
        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Product2 prod = new Product2(Name = 'TestProduct', IsActive = true);
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert pbe;
        
        Order ord = new Order(AccountId = acc.Id, EffectiveDate = system.today(), Status = 'Draft', Pricebook2Id = standardPB.Id);
        insert ord;
        List<User> CsTeamUserList = [SELECT Id,Name,Profile.Name,Email From User Where Profile.Name =:'Customer Service Executive' AND Name Like '%Aisha%' LIMIT 1];
        
        Case cse1 = [SELECT id,OwnerId FROM Case where OwnerId =:CsTeamUserList[0].id LIMIT 1];  
        //List<Case> cse1 = [SELECT id,OwnerId FROM Case where OwnerId =:CsTeamUserList LIMIT 1]; 
        Test.startTest();
        CaseHelperControllers.returnToOrigin(cse1.Id, 'Code verified cancellation', 'Initiate Refund');
        CaseHelperControllers.createCaseFromContact('Test','1234567890',cse1.Id,ord.Id);
        Test.stopTest();
    } */
    
    @IsTest
    static void testUpdateRecentProgress() {

        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            Alias = 'bano',
            Email = 'banoj@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = pro.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'banoj@example.com'
        );
        insert testUser;

        Account testAccount = new Account(Name = 'Test Account',Phone='234567');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;

        Case testCase = new Case(
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Subject = 'Test Case',
            Status = 'New'
        );
        insert testCase;
        Case_Progress_Detail__c testProgressDetail = new Case_Progress_Detail__c(
            Case__c = testCase.Id,
            Current_Action__c = 'Requested more Info from CS Team',
            CS_Remarks__c = 'Initial Remark',
            Status__c = 'Resolved'
        );
        insert testProgressDetail;

        Test.startTest();
        String result = CaseHelperControllers.updateRecentProgress(testCase.Id, 'Updated Remark');
        Test.stopTest();

        Case_Progress_Detail__c updatedProgressDetail = [SELECT Id, CS_Remarks__c, Status__c, Responded_By__c, Response_Time__c
                                                         FROM Case_Progress_Detail__c WHERE Id = :testProgressDetail.Id];
        System.debug('Updated Case Progress Detail: ' + updatedProgressDetail);

        Case updatedCase = [SELECT Id, more_Info_Requested__c, Last_Response__c FROM Case WHERE Id = :testCase.Id];
        System.debug('Updated Case: ' + updatedCase);

    }
    

    @IsTest
    static void testCreateCaseFromAccount() {
        // Create test user
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            Alias = 'tester',
            Email = 'Pratik@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = pro.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'pratk@example.com'
        );
        insert testUser;

        // Create test account
        Account testAccount = new Account(Name = 'Test Account',Phone='1234567');
        insert testAccount;

        // Create test order
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Status = 'Draft',
            EffectiveDate = Date.today()
        );
        insert testOrder;

        // Set the context user
        System.runAs(testUser) {
            Test.startTest();
            Case newCaseWithOrder = CaseHelperControllers.createCaseFromAccount('Test Subject', '1234567890', testAccount.Id, testOrder.Id);
            Test.stopTest();

            List<Case> createdCaseWithOrder = [SELECT Id, AccountId, Subject, Contact_Number__c, OrderId__c, Status, OwnerId 
                                         FROM Case WHERE Id = :newCaseWithOrder.Id];
            System.debug('Created Case with Order: ' + createdCaseWithOrder);

            Case newCaseWithoutOrder = CaseHelperControllers.createCaseFromAccount('Test Subject', '1234567890', testAccount.Id, null);
            Case createdCaseWithoutOrder = [SELECT Id, AccountId, Subject, Contact_Number__c, Status, OwnerId 
                                            FROM Case WHERE Id = :newCaseWithoutOrder.Id];
            System.debug('Created Case without Order: ' + createdCaseWithoutOrder);
        }
    }
    
    
     @IsTest
    static void testCreateChildCase() {
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            Alias = 'Banoj',
            Email = 'Anwar1234@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = pro.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'Anwar123@example.com'
        );
        insert testUser;

        Account testAccount = new Account(Name = 'Test Account',Phone = '12345567');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id
        );
        insert testContact;

        RecordType parentRt = [SELECT Id FROM RecordType WHERE Name = 'Inbound Case' LIMIT 1];
        Case parentCase = new Case(
            RecordTypeId = parentRt.Id,
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Subject = 'Parent Case',
            Status = 'New'
        );
        insert parentCase;

        System.runAs(testUser) {
            Test.startTest();
            String result = CaseHelperControllers.createChildCase(
                'Inbound Case', 'Order Related', 'Order Confirmation /Status Issues', 
                testAccount.Id, testContact.Id, 'Child Case', '1234567890', parentCase.Id, testUser.Id
            );
            Test.stopTest();

            System.assertEquals('SUCCESS', result);

            List<Case> childCases = [SELECT Id, RecordTypeId, AccountId, ContactId, Subject, Contact_Number__c, Status, OwnerId, ParentId 
                                     FROM Case WHERE ParentId = :parentCase.Id];
            System.assertEquals(1, childCases.size());

            Case createdChildCase = childCases[0];
            System.assertEquals(testAccount.Id, createdChildCase.AccountId);
            System.assertEquals(testContact.Id, createdChildCase.ContactId);
            System.assertEquals('Child Case', createdChildCase.Subject);
            System.assertEquals('1234567890', createdChildCase.Contact_Number__c);
            System.assertEquals('New', createdChildCase.Status);
            //System.assertEquals(testUser.Id, createdChildCase.OwnerId);
            System.assertEquals(parentCase.Id, createdChildCase.ParentId);
        }
    }

}