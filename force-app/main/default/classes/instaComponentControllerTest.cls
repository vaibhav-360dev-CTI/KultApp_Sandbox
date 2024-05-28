@isTest(seeAllData=true)
public class instaComponentControllerTest { 
    
    @isTest
    static void testGetRepliesDetails() {
        
        // Create a test Case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        insert testCase;
        string caseId = testCase.id;

        // Create test data for the Post_Comments__c object
        Case_Communication__c commentRecord = new Case_Communication__c();
        commentRecord.Activity_ID__c = 'TestCommentId';
        commentRecord.Activity_Content__c = 'RepliesWrapper:[data=(ReplyData:[id=18229403821211947, text=@sagarikaranaa its AMAZING, timestamp=2023-07-30T19:15:50+0000, username=kavyajhunjhunwala])]';
        commentRecord.Case__c = caseId;
        insert commentRecord;
        
        // Set the mock for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the getRepliesDetails method with the test data
        Test.startTest();
        List<instaComponentController.ReplyWrapperRecords> replyList = instaComponentController.getRepliesDetails(commentRecord.Activity_ID__c);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseDetails() {
        // Create a test Case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        insert testCase;

        // Create a test Case_Communication__c record associated with the Case
        Case_Communication__c commentRecord = new Case_Communication__c();
        commentRecord.Activity_ID__c = 'TestCommentId';
        commentRecord.Activity_Author__c = 'Test Comment';
        commentRecord.Platform_URL__c = 'https://www.example.com/test-post-url';
        commentRecord.Activity_Created_DateTime__c = Datetime.now();
        commentRecord.Activity_Content__c = 'RepliesWrapper:[data=(ReplyData:[id=18229403821211947, text=@sagarikaranaa its AMAZING, timestamp=2023-07-30T19:15:50+0000, username=kavyajhunjhunwala])]';
        commentRecord.Case__c = testCase.Id;
        insert commentRecord;

        // Set the mock for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the getCaseDetails method with the test data
        Test.startTest();
        List<instaComponentController.instaWrapper> instaWrapperList = instaComponentController.getCaseDetails(testCase.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testReplyToComment() {
        // Create a test Case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        insert testCase;

        // Create a test Case_Communication__c record
        Case_Communication__c commentRecord = new Case_Communication__c();
        commentRecord.Activity_ID__c = 'TestCommentId';
        commentRecord.Activity_Content__c = null; // Simulating no replies
        commentRecord.Case__c = testCase.Id;
        commentRecord.Activity_Content__c = 'RepliesWrapper:[data=(ReplyData:[id=18229403821211947, text=@sagarikaranaa its AMAZING, timestamp=2023-07-30T19:15:50+0000, username=kavyajhunjhunwala])]';
        insert commentRecord;

        // Set the mock for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the replyToComment method with the test data
        Test.startTest();
        instaComponentController.replyToComment('TestCommentId', 'Test reply message');
        Test.stopTest();
    }
    
    @isTest
    static void testGetUpdateComments() {
        // Create a test Case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        insert testCase;

        // Create a test Case_Communication__c record
        Case_Communication__c commentRecord = new Case_Communication__c();
        commentRecord.Activity_ID__c = '18229403821211947';
        commentRecord.Activity_Content__c = null; // Simulating no replies
        commentRecord.Case__c = testCase.Id;
        insert commentRecord;

        Case CaseDetails = [SELECT Id, Subject, Post_Id__c, Description, Type_of_Post__c, Caption__c, POST_URL__c,
            (SELECT Activity_ID__c, Activity_Created_DateTime__c, Activity_Content__c, Activity_Author__c, Platform_URL__c
            FROM Case_Communications__r) FROM Case WHERE Id = :testCase.Id];

        // Set the mock for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the getCaseDetails method with the test data
        Test.startTest();
        List<instaComponentController.instaWrapper> instaWrapperList = instaComponentController.getCaseDetails(CaseDetails.Id);
        instaComponentController.getUpdatedComments(testCase.Id);
        Test.stopTest();
    }
}