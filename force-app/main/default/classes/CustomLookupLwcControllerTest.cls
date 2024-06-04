@isTest(SeeAllData = true)
public class CustomLookupLwcControllerTest {
 
     @isTest
    static void testGetOrderLineItem() {
        list<Account> acclists = new list<Account>();
        Account accs = new account();
        accs.Name = 'Testing';
        accs.phone ='21345678';
        insert accs;  
        System.debug('accs======>'+accs);
        Test.startTest();
        List<sObject> result = CustomLookupLwcController.getLookupValues('Test', 'Account', 'Name != null', 'Name', 10);
        Test.stopTest();
    }
      @isTest
    static void testGetInitRecord() {
        Account acc = new Account(Name = 'Test Account',Phone='12345678');
        insert acc;       
        Test.startTest();
        sObject result = CustomLookupLwcController.getInitRecord(acc.Id, 'Account', 'Name');
        Test.stopTest();
    }
    
    @isTest
    static void testGetRecentlyCreatedRecords() {
        list<Account> acclist = new list<Account>();
        Account acc = new account();
        acc.Name = 'Testing';
        acc.phone ='21345678';
        Test.startTest();
        List<sObject> result = CustomLookupLwcController.gerRecentlyCreatedRecords('acclist', 'Name', 'Name != null', 1);
        Test.stopTest();
    }

}