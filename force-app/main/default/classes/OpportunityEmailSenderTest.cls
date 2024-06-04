@isTest
public class OpportunityEmailSenderTest {
	@isTest
    static void testClass(){
        Account acc = new Account();
        acc.Name= 'test';
        acc.Phone = '21345789';
        acc.Email__c = 'samalbanoj253@gmail.com';
        insert acc;
        
        Opportunity opp =new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = System.Today();
        opp.StageName = 'Qualification';
        opp.AccountId= acc.Id;
        insert opp;
        
        OpportunityEmailSender.sendEmailOnOpportunity(opp.Id);
    }
}