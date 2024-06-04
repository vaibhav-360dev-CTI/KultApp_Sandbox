@isTest
public class CallLogHelperTest {
    
    @isTest
    static void testCallLogGenerate() {
        // Setup Test Data
        List<Call_Logs_Custom__c> callLogs = new List<Call_Logs_Custom__c>();
        
        // Call Log with Phone and Email
        callLogs.add(new Call_Logs_Custom__c(
            Phone__c = '1234567890',
            Email__c = 'test1@example.com',
            Status__c = 'Missed'
        ));
        
        // Call Log with Phone only
        callLogs.add(new Call_Logs_Custom__c(
            Phone__c = '0987654321',
            Status__c = 'In-progress'
        ));
        
        // Call Log with Email only
        callLogs.add(new Call_Logs_Custom__c(
            Email__c = 'test2@example.com',
            Status__c = 'Missed'
        ));
        
        // Insert call logs
        insert callLogs;
        
        // Insert existing contact to check the update path
        Contact existingContact = new Contact(
            FirstName = 'Existing',
            LastName = 'Contact',
            Phone = '1234567890',
            Email = 'existing@example.com'
        );
        insert existingContact;
        
        // Run the method
        Test.startTest();
        CallLogHelper.CallLogGenerate(callLogs);
        Test.stopTest();
    }
}