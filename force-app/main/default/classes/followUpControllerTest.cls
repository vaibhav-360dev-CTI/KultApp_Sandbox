@isTest
public class followUpControllerTest {
    @isTest
    static void testClass(){
        //followUpController.dumMethod();
        Profile p = [SELECT Id FROM Profile WHERE Name='WareHouse Team' LIMIT 1];
        
        User testUser = new User(Alias = 'standt', Email='dipesh@test.com',
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                                 UserName='dipe12345678sh.m@kult.app');
        insert testUser;
        
        set<Id> cseId = new set<Id>();
        Case testCase = new Case(Status= 'New', Subject = 'Test Case');
        insert testCase;
        cseId.add(testCase.Id);
        system.debug('testCase.Id=============>'+testCase.Id);


		Case testCase1 = new Case(Status= 'New', Subject = 'Test Case');
        insert testCase1;		
        
        Case_Progress_Detail__c cpd = new Case_Progress_Detail__c();
        cpd.WH_Team_Remarks__c = 'Test1';
        cpd.CS_Remarks__c = 'refundReason';
        cpd.Status__c = 'In Progress'; 
        cpd.Case__c = testCase.Id;
        insert cpd;
        
        Case_Progress_Detail__c cpd1 = new Case_Progress_Detail__c();
        cpd1.WH_Team_Remarks__c = 'Test1';
        cpd1.CS_Remarks__c = 'refundReason';
        cpd1.Status__c = 'Open'; 
        cpd1.Case__c = testCase1.Id;
        insert cpd1;

        system.runAs(testUser){            
            System.debug('Current User============> ' + UserInfo.getUserName());
            System.debug('Current Profile=============>' + UserInfo.getProfileId());
        }
        followUpController.sendFollowUp(testCase.Id,'remarks');
        followUpController.sendFollowUpWithAttachment(testCase.Id,'remarks','Banoj file','hi','Debug Logs Content Type');
        followUpController.sendFollowUpResponse(testCase.Id,'remarks');
        followUpController.checkFollowUpStatu(testCase1.Id);
        followUpController.checkFollowUpStatu(testCase.Id);
        
    }
}