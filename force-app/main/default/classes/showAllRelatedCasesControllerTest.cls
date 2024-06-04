@isTest
public class showAllRelatedCasesControllerTest {
    
    @isTest
    static void testGetCaseList() {
        // Create LiveChatVisitor record
        Account testAccount = new Account(Name = 'Test Account',Phone = '23456789');
        insert testAccount;
        
        //Order testOrder = new Order(Name = 'TestOrder001', AccountId = testAccount.Id, Status = 'Draft');
        //insert testOrder;
         Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
           // OrderId__c = testOrder.Id,
            Status = 'New'
        );
        Insert testCase;
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        
        insert visitor;

        // Create LiveChatTranscript record
        LiveChatTranscript chatTranscript = new LiveChatTranscript(
            LiveChatVisitorId = visitor.Id,
            CaseId = testCase.Id
        );
        insert chatTranscript;

        // Create Case record
       

        Test.startTest();
        // Test scenario 1: chatTranscripId starts with '570'
        List<Case> caseList1 = showAllRelatedCasesController.getCaseList(chatTranscript.Id);
        // Perform assertions for caseList1
        
        // Test scenario 2: chatTranscripId starts with '500'
        List<Case> caseList2 = showAllRelatedCasesController.getCaseList(testCase.Id);
        // Perform assertions for caseList2
        
        // Test scenario 3: chatTranscripId starts with '00T'
        Task testTask = new Task(Case__c = testCase.Id, Subject = 'Test Task');
        insert testTask;
        List<Case> caseList3 = showAllRelatedCasesController.getCaseList(testTask.Id);
        // Perform assertions for caseList3

        Test.stopTest();
    }
}