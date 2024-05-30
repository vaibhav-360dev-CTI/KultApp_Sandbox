@istest(seeAllData = false)
public class CallLogTriggerHelperTest {
    @istest
    public static void collectEmailOrPhoneOfCallLogs(){
        
        List<Call_Logs_Custom__c> clgList= new List<Call_Logs_Custom__c>();
        List<Case> caselist =new List<Case>();
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
        
        
        Case cse = new Case();
        cse.Origin = 'Bulk Upload';
        cse.Status = 'New';
        cse.AccountId = acc.Id;
        cse.ContactId = con.Id;
        Insert cse;
 
        Call_Logs_Custom__c clg = new Call_Logs_Custom__c();
        clg.Phone__c = '9025244424';
        clg.Email__c = 'banoj253@gmail.com';
        Insert clg;
        Datetime myDate = Datetime.newInstance(2024, 04, 1, 12, 30, 2);
        Test.setCreatedDate(clg.Id, myDate);
        Call_Logs_Custom__c clgq = [Select Id,Name,IsDeleted,CreatedDate,Phone__c,Contact__c,OwnerId,Case__c ,Email__c,Status__c FROM  Call_Logs_Custom__c WHERE ID=: clg.Id LIMIT 1];
        System.debug('CreatedDate====>'+clgq.CreatedDate);
        clgq.Contact__c = con.Id;
        clgq.Case__c = cse.Id;
        clgq.Status__c = 'Missed';
        update clgq;
        clgList.add(clgq);
        CallLogTriggerHelper.collectEmailOrPhoneOfCallLogs(clgList);  
        clgList.clear();
        Call_Logs_Custom__c clgq1 = [Select Id,Name,IsDeleted,CreatedDate,Phone__c,Contact__c,OwnerId,Case__c ,Email__c,Status__c FROM  Call_Logs_Custom__c WHERE ID=: clg.Id LIMIT 1];
        clgq1.Contact__c = con.Id;
        clgq1.Case__c = cse.Id;
        clgq1.Status__c = 'In-progress';
        update clgq1;
        clgList.add(clgq1);
        
        /*Call_Logs_Custom__c clg1 = new Call_Logs_Custom__c();
        clg.Phone__c = '9025244424';
        clg.Email__c = 'banoj253@gmail.com';
        //clg.CreatedDate = System.Now();
        Insert clg1;
        Datetime myDate1 = Datetime.newInstance(2024, 04, 1, 12, 30, 2);
        Test.setCreatedDate(clg1.Id, myDate1);
        Call_Logs_Custom__c clgq1 = [Select Id,Name,IsDeleted,CreatedDate,Phone__c,Contact__c,Case__c ,Email__c,Status__c,OwnerId FROM  Call_Logs_Custom__c WHERE Id=:clg1.Id Limit 1];
        //System.debug('CreatedDate====>'+clgq1.CreatedDate);
            
        clgq1.Contact__c = con.Id;
        clgq1.Case__c = cse.Id;
        clgq1.Status__c = 'In-progress';
        //update clg1;
        clgList.add(clgq1);*/
        update clgList;                                           
       CallLogTriggerHelper.collectEmailOrPhoneOfCallLogs(clgList);  
       
    }
}