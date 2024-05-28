@isTest
public class instaDmLWCCompControllerTest {
    
    @isTest
    static void testGetInstaDmDetails() {
        // Create a test case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        testCase.User_Name__c = 'Test User';
        testCase.User_Id__c = 'user1';
        testCase.Post_Id__c = 'postId1';
        insert testCase;

        // Create a test Case_Communication__c record associated with the case
        Case_Communication__c commentRecord = new Case_Communication__c();
        commentRecord.Activity_Content__c = 'Test Comment';
        commentRecord.Activity_ID__c = 'TestCommentId';
        commentRecord.Case__c = testCase.Id;
        commentRecord.Activity_Author__c = 'Author1';
        commentRecord.Activity_User_ID__c = 'user1';
        commentRecord.Activity_Created_DateTime__c = Datetime.now();
        insert commentRecord;

        // Call the getInstaDmDetails method with the test data
        Test.startTest();
        List<instaDmLWCCompController.instaDMWrapper> result = instaDmLWCCompController.getInstaDmDetails(testCase.Id);
        Test.stopTest();

        // Add assertions to verify the results
        System.assertEquals(2, result.size(), 'There should be two instaDMWrapper records');
        System.assertEquals('Test Case Description', result[0].text, 'The first text should match the case description');
        System.assertEquals('Test Comment', result[1].text, 'The second text should match the comment content');
    }
    
    @isTest
    static void testSendMessage() {
        // Create a test case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        testCase.User_Name__c = 'Test User';
        testCase.User_Id__c = 'user1';
        insert testCase;

        // Set the mock for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the sendMessage method with the test data
        Test.startTest();
        instaDmLWCCompController.sendMessage('user1', 'Test message', testCase.Id);
        Test.stopTest();

        // Add assertions to verify the results
        List<Case_Communication__c> communications = [SELECT Id, Activity_Content__c, Activity_ID__c, Case__c FROM Case_Communication__c WHERE Case__c = :testCase.Id];
        System.assertEquals(1, communications.size(), 'There should be one Case_Communication__c record');
        System.assertEquals('Test message', communications[0].Activity_Content__c, 'The activity content should match the sent message');
    }
    
    @isTest
    static void testRefreshChat() {
        // Create a test case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        testCase.User_Name__c = 'Test User';
        testCase.User_Id__c = 'user1';
        insert testCase;

        // Set the mock for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the refreshChat method with the test data
        Test.startTest();
        String result = instaDmLWCCompController.refreshChat('user1', testCase.Id);
        Test.stopTest();

        // Add assertions to verify the results
        System.assertEquals('Success', result, 'The result should be "Success"');
    }

    @isTest
    static void testRemoveHTMLTags() {
        String input = '<p>This is a <strong>test</strong> message.</p>';
        String expectedOutput = 'This is a test message.';
       // String actualOutput = (String) Test.invokePrivate(instaDmLWCCompController.class, 'removeHTMLTags', new List<Object>{input});
    }

    // Mock HTTP Response Generator for sendMessage and refreshChat tests
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message_id": "mid.123456789"}');
            res.setStatusCode(200);
            return res;
        }
    }
}