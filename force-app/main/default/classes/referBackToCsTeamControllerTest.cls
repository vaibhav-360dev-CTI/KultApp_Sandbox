@isTest(seeAllData = true)
public class referBackToCsTeamControllerTest {
    @istest 
    static void testClass(){
        
        Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Customer Service Executive']; 
        
        User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                    IsActive=true,Division='Rainmakers',
                                    LocaleSidKey='en_US', ProfileId = pro.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
        insert userInstant;
        
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
        
        Map<Id,Case> mapOfCase = new Map<Id,Case>();
        Case cse = new Case();
        cse.Origin = 'Bulk Upload';
        cse.Status = 'New';
        cse.AccountId = acc.Id;
        cse.OrderId__c = ord.Id;
        cse.ContactId = con.Id;
        cse.Inital_Commented_Date__c = system.today();
        cse.subject = 'Testing';
        cse.Refund_Type__c = 'Full';
        cse.Refund_Reasons__c = 'Customer Changed Mind';   
        cse.Refund_Reason__c = 'Testing';
        cse.Sub_Type__c = 'Order Related';
        cse.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse.Reason_For_Dealy__c = 'Customer Unreachable';
        cse.OwnerId = userInstant.Id;
        Insert cse;
        cse.Reason_For_Dealy__c = 'Lost in Transit';
        update cse;
        mapOfCase.put(cse.Id,cse);
        
        Map<Id,Case> mapOfCase1 = new Map<Id,Case>();
        Case cse1 = new Case();
        cse1.Origin = 'Bulk Upload';
        cse1.Status = 'New';
        cse1.AccountId = acc.Id;
        cse1.OrderId__c = ord.Id;
        cse1.ContactId = con.Id;
        cse1.Inital_Commented_Date__c = system.today();
        cse1.subject = 'Testing';
        cse1.Refund_Type__c = 'Full';
        cse1.Refund_Reasons__c = 'Customer Changed Mind';   
        cse1.Refund_Reason__c = 'Testing';
        cse1.Type = 'Order Related';
        cse1.Sub_Type__c = 'Order Related';
        cse1.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse1.Reason_For_Dealy__c = 'Lost in Transit';
        Insert cse1;
        cse1.Reason_For_Dealy__c = 'Incorrect Addresses';
        update cse1;
        mapOfCase1.put(cse1.Id,cse1);
        
        Map<Id,Case> mapOfCase2 = new Map<Id,Case>();
        Case cse2 = new Case();
        cse2.Origin = 'Bulk Upload';
        cse2.Status = 'New';
        cse2.AccountId = acc.Id;
        cse2.OrderId__c = ord.Id;
        cse2.ContactId = con.Id;
        cse2.Inital_Commented_Date__c = system.today();
        cse2.subject = 'Testing';
        cse2.Refund_Type__c = 'Special Case Refund';
        cse2.Refund_Reasons__c = 'Customer Changed Mind';   
        cse2.Refund_Reason__c = 'Testing';
        cse2.Type = 'Order Related';
        cse2.Sub_Type__c = 'Order Related';
        cse2.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse2.Reason_For_Dealy__c = 'Lost in Transit';
        cse2.Refer_Back_Reason__c = 'Send Update';
        cse2.Approval_Remarks__c = 'qwetyu';
        cse2.Rejection_Reason__c = 'qwtuirdx';
        cse2.Describe_Information_Needed__c = 'qwertyu';
        Insert cse2;
        cse2.Reason_For_Dealy__c = 'Customer Unreachable';
        update cse2;
        mapOfCase2.put(cse2.Id,cse2);
        
        Map<Id, Case> mapOfCase3 = new Map<Id, Case>();
        Case cse3 = new Case();
        cse3.Origin = 'Bulk Upload';
        cse3.Status = 'New';
        cse3.AccountId = acc.Id;
        cse3.OrderId__c = ord.Id;
        cse3.ContactId = con.Id;
        cse3.Inital_Commented_Date__c = system.today();
        cse3.subject = 'Testing';
        cse3.Refund_Type__c = 'Full';
        cse3.Refund_Reasons__c = 'Customer Changed Mind';
        cse3.Refund_Reason__c = 'Testing';
        cse3.Type = 'Order Related';
        cse3.Sub_Type__c = 'Order Related';
        cse3.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
        cse3.Reason_For_Dealy__c = 'Lost in Transit';
        cse3.Refer_Back_Reason__c = 'Send Update';
        cse3.Approval_Remarks__c = 'qwetyu';
        cse3.Rejection_Reason__c = 'qwtuirdx';
        cse3.Describe_Information_Needed__c = 'qwertyu';
        Insert cse3;
        cse3.Reason_For_Dealy__c = 'Customer Unreachable';
        update cse3;
        mapOfCase3.put(cse3.Id, cse3);
        
        
        Task newTask = new Task();
        newTask.Subject = 'Case has been assigned to Move to Refund Team';
        newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
        newTask.WhatId = cse.Id; 
        
        insert newTask;
        
        List<Case_Progress_Detail__c> listcpd = new List<Case_Progress_Detail__c>();
        Case_Progress_Detail__c cpd1 = new Case_Progress_Detail__c();
        cpd1.Status__c ='Open';
        cpd1.Current_Action__c = 'Case Update Sent';
        cpd1.Response_Time__c =System.Now();
        cpd1.Current_Action__c = 'Case Update Sent';
        cpd1.Case__c = cse.Id;       
        listcpd.add(cpd1);
        insert listcpd;
        
        List<Case_Progress_Detail__c> listcpd1 = new List<Case_Progress_Detail__c>();
        Case_Progress_Detail__c cpd2 = new Case_Progress_Detail__c();
        cpd2.Status__c ='Open';
        cpd2.Current_Action__c = 'Case Update Sent';
        cpd2.Response_Time__c =System.Now();
        cpd2.Current_Action__c = 'Case Update Sent';
        cpd2.Case__c = cse2.Id;       
        listcpd.add(cpd2);
        insert listcpd1;
        
        
        list<Account> lsacc = new list<Account>();
        Account acc1 = new Account();
        acc1.Name = 'Testing';
        acc1.Phone = '098765432123456';
        lsacc.add(acc1);
        insert lsacc;
        
        Refund_API_Details__c refundSettings = new Refund_API_Details__c();
        refundSettings.Endpoint__c = 'https://ops.dev.kult.in/api/v1/order/process_refund';
        refundSettings.Access_Token__c = 'Bearer dummy_access_token';
        //insert refundSettings;
        
        // Create Affected_SKU__c records
        Affected_SKU__c affectedSKU1 = new Affected_SKU__c(
            Case__c = cse2.Id, 
            Name = 'SKU001', 
            Order_Item__c = ordItm.Id
        );
        Affected_SKU__c affectedSKU2 = new Affected_SKU__c(
            Case__c = cse.Id, 
            Name = 'SKU002', 
            Order_Item__c = ordItm.Id
        );
        
        List<Affected_SKU__c> affSKUstoInsert = new List<Affected_SKU__c>();
        affSKUstoInsert.add(affectedSKU1);
        affSKUstoInsert.add(affectedSKU2);
        insert affSKUstoInsert;
        
        // Testing the methods
        Test.startTest();
        referBackToCsTeamController.getCaseById(cse.Id);
        referBackToCsTeamController.getCaseTeamAndType(cse.Id);
        referBackToCsTeamController.getCaseAndOrderDetails(cse.Id, 'Send Update', 200, 'qwetyu', 'qwtuirdx', cse2.Describe_Information_Needed__c, 200, 'resolution remarks', 'update desc', 'base64String', 'filename', 'awbNumber', 'focOrderId','Crash Issues',True);
        referBackToCsTeamController.getCaseAndOrderDetails(cse1.Id, 'Need More Info', 200, 'qwetyu', 'qwtuirdx', cse2.Describe_Information_Needed__c, 200, 'resolution remarks', 'update desc', 'base64String', 'filename', 'awbNumber', 'focOrderId','Crash Issues',True);
        referBackToCsTeamController.getCaseAndOrderDetails(cse2.Id, 'Send Update', 200, 'qwetyu', 'qwtuirdx', cse2.Describe_Information_Needed__c, 200, 'resolution remarks', 'update desc', 'base64String', 'filename', 'awbNumber', 'focOrderId','Crash Issues',True);
        referBackToCsTeamController.getCaseAndOrderDetails(cse.Id, 'Resolved', 200, 'qwetyu', 'qwtuirdx', cse2.Describe_Information_Needed__c, 200, 'resolution remarks', 'update desc', 'base64String', 'filename', 'awbNumber', 'focOrderId','Crash Issues',True);
        referBackToCsTeamController.getCaseAndOrderDetails(cse2.Id, 'Resolved', 200, 'qwetyu', 'qwtuirdx', cse2.Describe_Information_Needed__c, 200, 'resolution remarks', 'update desc', 'base64String', 'filename', 'awbNumber', 'focOrderId','Crash Issues',True);
        referBackToCsTeamController.getCaseAndOrderDetails(cse3.Id, 'Resolved', 200, 'qwetyu', 'qwtuirdx', cse2.Describe_Information_Needed__c, 200, 'resolution remarks', 'update desc', 'base64String', 'filename', 'awbNumber', 'focOrderId','Crash Issues',True);
        referBackToCsTeamController.deletecaseShares(cse.Id);
        referBackToCsTeamController.sendingCustomNotification(userInstant.Id, cse.Id, 'Test Class Title', 'Test Class Body', new List<String>{'anwarchikle2000@gmail.com'});
        referBackToCsTeamController.AccountCreatedConCreated(lsacc);
        Test.stopTest();
    } 
    
    @isTest
    static void testPostRefundRequest() {
        // Mock HTTP response for the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Get a Case Id for testing
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Call the method
        String result = CalloutRefundAPIClass.postRefundRequest(testCase.Id);
        
    }
    
    
    /* @istest 
static void testClass1(){
Profile pro = [SELECT Id,Name FROM Profile WHERE Name='WareHouse Team']; 

User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
IsActive=true,Division='Rainmakers',
LocaleSidKey='en_US', ProfileId = pro.Id,
TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
insert userInstant;

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

Map<Id,Case> mapOfCase = new Map<Id,Case>();
Case cse = new Case();
cse.Origin = 'Bulk Upload';
cse.Status = 'New';
cse.AccountId = acc.Id;
cse.OrderId__c = ord.Id;
cse.ContactId = con.Id;
cse.Inital_Commented_Date__c = system.today();
cse.subject = 'Testing';
cse.Refund_Type__c = 'Full';
cse.Refund_Reasons__c = 'Customer Changed Mind';   
cse.Refund_Reason__c = 'Testing';
cse.Sub_Type__c = 'Order Related';
cse.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
cse.Reason_For_Dealy__c = 'Customer Unreachable';
Insert cse;
cse.Reason_For_Dealy__c = 'Lost in Transit';
update cse;
mapOfCase.put(cse.Id,cse);

Map<Id,Case> mapOfCase1 = new Map<Id,Case>();
Case cse1 = new Case();
cse1.Origin = 'Bulk Upload';
cse1.Status = 'New';
cse1.AccountId = acc.Id;
//cse1.OrderId__c = ord.Id;
cse1.ContactId = con.Id;
cse1.Inital_Commented_Date__c = system.today();
cse1.subject = 'Testing';
cse1.Refund_Type__c = 'Full';
cse1.Refund_Reasons__c = 'Customer Changed Mind';   
cse1.Refund_Reason__c = 'Testing';
cse1.Type = 'Order Related';
cse1.Sub_Type__c = 'Order Related';
// cse1.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
cse1.Reason_For_Dealy__c = 'Lost in Transit';
Insert cse1;
cse1.Reason_For_Dealy__c = 'Incorrect Addresses';
update cse1;
mapOfCase1.put(cse1.Id,cse1);

Map<Id,Case> mapOfCase2 = new Map<Id,Case>();
Case cse2 = new Case();
cse2.Origin = 'Bulk Upload';
cse2.Status = 'New';
cse2.AccountId = acc.Id;
cse2.OrderId__c = ord.Id;
cse2.ContactId = con.Id;
cse2.Inital_Commented_Date__c = system.today();
cse2.subject = 'Testing';
cse2.Refund_Type__c = 'Full';
cse2.Refund_Reasons__c = 'Customer Changed Mind';   
cse2.Refund_Reason__c = 'Testing';
cse2.Type = 'Order Related';
cse2.Sub_Type__c = 'Order Related';
cse2.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
cse2.Reason_For_Dealy__c = 'Lost in Transit';
cse2.Refer_Back_Reason__c = 'Send Update';
cse2.Approval_Remarks__c = 'qwetyu';
cse2.Rejection_Reason__c = 'qwtuirdx';
cse2.Describe_Information_Needed__c = 'qwertyu';
Insert cse2;
cse2.Reason_For_Dealy__c = 'Customer Unreachable';
update cse2;
mapOfCase2.put(cse2.Id,cse2);

Task newTask = new Task();
newTask.Subject = 'Case has been assigned to Move to Refund Team';
newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
newTask.WhatId = cse.Id; 

insert newTask;

list<Account> lsacc = new list<Account>();
Account acc1 = new Account();
acc1.Name = 'Testing';
acc1.Phone = '098765432123456';
lsacc.add(acc1);
insert lsacc;

// Testing the methods
Test.startTest();
referBackToCsTeamController.getCaseById(cse.Id);
referBackToCsTeamController.getCaseTeamAndType(cse.Id);
referBackToCsTeamController.getCaseAndOrderDetails(cse.Id, cse2.Refer_Back_Reason__c, 200, cse2.Approval_Remarks__c, cse2.Rejection_Reason__c, cse2.Describe_Information_Needed__c, 200, 'resolution remarks', 'update desc', 'base64String', 'filename', 'awbNumber', 'focOrderId','Crash Issues',True);
referBackToCsTeamController.deletecaseShares(cse.Id);
referBackToCsTeamController.sendingCustomNotification(userInstant.Id, cse.Id, 'Test Class Title', 'Test Class Body', new List<String>{'anwarchikle2000@gmail.com'});
referBackToCsTeamController.AccountCreatedConCreated(lsacc);
Test.stopTest();
} 

@istest 
static void testClass2(){
Profile pro = [SELECT Id,Name FROM Profile WHERE Name='WareHouse Team']; 

User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
IsActive=true,Division='Rainmakers',
LocaleSidKey='en_US', ProfileId = pro.Id,
TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
insert userInstant;

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

Map<Id,Case> mapOfCase = new Map<Id,Case>();
Case cse = new Case();
cse.Origin = 'Bulk Upload';
cse.Status = 'New';
cse.AccountId = acc.Id;
cse.OrderId__c = ord.Id;
cse.ContactId = con.Id;
cse.Inital_Commented_Date__c = system.today();
cse.subject = 'Testing';
cse.Refund_Type__c = 'Full';
cse.Refund_Reasons__c = 'Customer Changed Mind';   
cse.Refund_Reason__c = 'Testing';
cse.Sub_Type__c = 'Order Related';
cse.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
cse.Reason_For_Dealy__c = 'Customer Unreachable';
Insert cse;
cse.Reason_For_Dealy__c = 'Lost in Transit';
update cse;
mapOfCase.put(cse.Id,cse);

Map<Id,Case> mapOfCase1 = new Map<Id,Case>();
Case cse1 = new Case();
cse1.Origin = 'Bulk Upload';
cse1.Status = 'New';
cse1.AccountId = acc.Id;
cse1.OrderId__c = ord.Id;
cse1.ContactId = con.Id;
cse1.Inital_Commented_Date__c = system.today();
cse1.subject = 'Testing';
cse1.Refund_Type__c = 'Full';
cse1.Refund_Reasons__c = 'Customer Changed Mind';   
cse1.Refund_Reason__c = 'Testing';
cse1.Type = 'Order Related';
cse1.Sub_Type__c = 'Order Related';
cse1.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
cse1.Reason_For_Dealy__c = 'Lost in Transit';
Insert cse1;
cse1.Reason_For_Dealy__c = 'Incorrect Addresses';
update cse1;
mapOfCase1.put(cse1.Id,cse1);

Map<Id,Case> mapOfCase2 = new Map<Id,Case>();
Case cse2 = new Case();
cse2.Origin = 'Bulk Upload';
cse2.Status = 'New';
cse2.AccountId = acc.Id;
cse2.OrderId__c = ord.Id;
cse2.ContactId = con.Id;
cse2.Inital_Commented_Date__c = system.today();
cse2.subject = 'Testing';
cse2.Refund_Type__c = 'Full';
cse2.Refund_Reasons__c = 'Customer Changed Mind';   
cse2.Refund_Reason__c = 'Testing';
cse2.Type = 'Order Related';
cse2.Sub_Type__c = 'Order Related';
cse2.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
cse2.Reason_For_Dealy__c = 'Lost in Transit';
cse2.Refer_Back_Reason__c = 'Resolved';
cse2.Approval_Remarks__c = 'qwetyu';
cse2.Rejection_Reason__c = 'qwtuirdx';
cse2.Describe_Information_Needed__c = 'qwertyu';
Insert cse2;
cse2.Reason_For_Dealy__c = 'Customer Unreachable';
update cse2;
mapOfCase2.put(cse2.Id,cse2);

Task newTask = new Task();
newTask.Subject = 'Case has been assigned to Move to Refund Team';
newTask.Description = 'Please Move To Refund Team case with case ID: ' + cse.Id;
newTask.WhatId = cse.Id; 

insert newTask;

list<Account> lsacc = new list<Account>();
Account acc1 = new Account();
acc1.Name = 'Testing';
acc1.Phone = '098765432123456';
lsacc.add(acc1);
insert lsacc;

// Testing the methods
Test.startTest();
referBackToCsTeamController.getCaseById(cse.Id);
referBackToCsTeamController.getCaseTeamAndType(cse.Id);
referBackToCsTeamController.getCaseAndOrderDetails(cse.Id, cse2.Refer_Back_Reason__c, 200, cse2.Approval_Remarks__c, cse2.Rejection_Reason__c, cse2.Describe_Information_Needed__c, 200, 'resolution remarks', 'update desc', 'base64String', 'filename', 'awbNumber', 'focOrderId','Crash Issues',True);
referBackToCsTeamController.deletecaseShares(cse.Id);
referBackToCsTeamController.sendingCustomNotification(userInstant.Id, cse.Id, 'Test Class Title', 'Test Class Body', new List<String>{'anwarchikle2000@gmail.com'});
referBackToCsTeamController.AccountCreatedConCreated(lsacc);
Test.stopTest();  

} 

@isTest
static void testClasses(){


Profile pro = [SELECT Id,Name FROM Profile WHERE Name='Customer Service Executive']; 

User userInstant = new User(Alias = 'standt', Email='sossfdc@cirrologix.com', 
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
IsActive=true,Division='Rainmakers',
LocaleSidKey='en_US', ProfileId = pro.Id,
TimeZoneSidKey='America/Los_Angeles', UserName='standardVarsha@testorg.com');
insert userInstant;

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

Map<Id,Case> mapOfCase = new Map<Id,Case>();
Case cse = new Case();
cse.Origin = 'Bulk Upload';
cse.Status = 'New';
cse.AccountId = acc.Id;
cse.OrderId__c = ord.Id;
cse.ContactId = con.Id;
cse.Inital_Commented_Date__c = system.today();
cse.subject = 'Testing';
cse.Refund_Type__c = 'Full';
cse.Refund_Reasons__c = 'Customer Changed Mind';   
cse.Refund_Reason__c = 'Testing';
cse.Sub_Type__c = 'Order Related';
cse.Sub_Sub_Type__c = 'Order Confirmation /Status Issues';
cse.Reason_For_Dealy__c = 'Customer Unreachable';
cse.OwnerId = userInstant.Id;
Insert cse;
cse.Reason_For_Dealy__c = 'Lost in Transit';
update cse;
mapOfCase.put(cse.Id,cse);

List<Case_Progress_Detail__c> listcpd = new List<Case_Progress_Detail__c>();
Case_Progress_Detail__c cpd1 = new Case_Progress_Detail__c();
cpd1.Status__c ='Open';
cpd1.Current_Action__c = 'Case Update Sent';
cpd1.Response_Time__c =System.Now();
cpd1.Current_Action__c = 'Case Update Sent';
cpd1.Case__c = cse.Id;       
listcpd.add(cpd1);
insert listcpd;

// Testing the methods
Test.startTest();
referBackToCsTeamController.getCaseTeamAndType(cse.Id);
Test.stopTest();
} */
}