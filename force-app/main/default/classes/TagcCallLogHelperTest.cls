@isTest
public class TagcCallLogHelperTest {

    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account', Phone = '1234567890');
        insert acc;

        Case cs = new Case(
            AccountId = acc.Id,
            SuppliedPhone = '1234567890',
            Contact_Number__c = '1234567890',
            Shipping_Mobile_No__c = '1234567890'
        );
        insert cs;

        Task task1 = new Task(
            Subject = 'Test call 1234567890',
            Exotel_CTI__Call_Direction__c = 'InBound',
            Exotel_CTI__From__c = '0987654321',
            Exotel_CTI__To__c = '1234567890',
            Exotel_CTI__Start_Time__c = 'yes',
            Exotel_CTI__End_Time__c = 'yes'
        );
        insert task1;

        Task task2 = new Task(
            Subject = 'Test call 1234567890',
            Exotel_CTI__Call_Direction__c = 'InBound',
            Exotel_CTI__From__c = '0987654321',
            Exotel_CTI__To__c = '1234567890',
            Exotel_CTI__Start_Time__c = 'No',
            Exotel_CTI__End_Time__c = 'No'
        );
        insert task2;
    }

    @isTest
    static void testTagCallLog() {
        // Retrieve the Case record created in the test setup
        Case cs = [SELECT Id FROM Case LIMIT 1];
        
        // Call the method to be tested
        List<Task> tasks = TagcCallLogHelper.tagCallLog(cs.Id);
    }

    @isTest
    static void testUpdateCaseOnTask() {
        Case cs = [SELECT Id FROM Case LIMIT 1];
        List<Task> tasks = [SELECT Id FROM Task WHERE Exotel_CTI__Call_Direction__c = 'InBound' LIMIT 2];

        List<String> taskIds = new List<String>();
        for (Task task : tasks) {
            taskIds.add(task.Id);
        }
        String result = TagcCallLogHelper.updateCaseOntask(cs.Id, taskIds);

        tasks = [SELECT Id, Case__c FROM Task WHERE Id IN :taskIds];
        for (Task task : tasks) {
            System.assertEquals(cs.Id, task.Case__c, 'Expected the task to be linked to the case');
        }
    }
}