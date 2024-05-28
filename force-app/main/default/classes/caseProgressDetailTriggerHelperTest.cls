@IsTest(SeeAllData=true)

public class caseProgressDetailTriggerHelperTest {
    @isTest
    static void testClass(){
        //caseProgressDetailTriggerHelper.dumMethod();
        Profile prorec = [SELECT Id, Name FROM Profile WHERE Name ='WareHouse Team' LIMIT 1]; 
        User salesALsUser = new User(
            Username = 'testuser@salesals.com', 
            FirstName = 'Test', 
            LastName = 'User', 
            Email = 'testuser@salesals.com', 
            Alias = 'testuser', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US', 
            ProfileId = prorec.Id
        );
        // User use = [sELECT Id,Name,ProfileId FROM User where ProfileId =:prorec.Id LIMIT 1];
        Case cs = new Case();
        cs.Status = 'New';
        insert cs;
        List<Case_Progress_Detail__c> caseObjList = new List<Case_Progress_Detail__c>();
        Case_Progress_Detail__c caseObj = new Case_Progress_Detail__c();
        caseObj.WH_Team_Remarks__c = 'Test';
        caseObj.Status__c = 'Responded'; 
        caseObj.Case__c = cs.Id;
        insert caseObj;
        caseObjList.add(caseObj);
        
        caseObj.WH_Team_Remarks__c = 'eeee';
        update caseObj;
        
        caseProgressDetailTriggerHelper.sendNotificationToCSTeam(caseObjList);
    }
    
    
}