@isTest
public class followUpTriggerHelperTest {
	@isTest
    static void testClass(){
        //followUpTriggerHelper.dumMethod();
        List<Follow_Up_Request__c> listofFol = new List<Follow_Up_Request__c>();
        case testcase = new case();
        testcase.Status = 'New';
        testcase.Subject = 'Test Case';
        insert testcase;
        
        Follow_Up_Request__c fol = new Follow_Up_Request__c();
        fol.Follow_Up_Status__c  = 'Open';
        fol.Case__c = testcase.Id;
        listofFol.add(fol);
        insert listofFol;
        
        List<Follow_Up_Request__c> listofFol1 = new List<Follow_Up_Request__c>();
        case testcase1 = new case();
        testcase.Status = 'New';
        testcase.Subject = 'Test Case';
        insert testcase1;
        
        Follow_Up_Request__c fol1 = new Follow_Up_Request__c();
        fol.Follow_Up_Status__c  = 'Responded';
        fol.Case__c = testcase1.Id;
        listofFol1.add(fol1);
        insert listofFol1;
        
        followUpTriggerHelper.updateCaseOnFollowUpCreation(listofFol);
        followUpTriggerHelper.updateCaseOnFollowUpUpdation(listofFol);
        followUpTriggerHelper.OnInsertOrUpdateLastResponseOnCase(listofFol);
         followUpTriggerHelper.OnInsertOrUpdateLastResponseOnCase(listofFol1);

        
    }
}