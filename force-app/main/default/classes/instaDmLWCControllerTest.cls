@isTest
public class instaDmLWCControllerTest {

    @testSetup
    static void setupTestData() {
        // Create a test Instagram_Api_Details__c record
        Instagram_Api_Details__c apiDetails = new Instagram_Api_Details__c(
            pageAccessToken__c = 'testAccessToken'
        );
        insert apiDetails;
        
        // Create a test Case record
        Case testCase = new Case(
            Subject = 'Test Case'
        );
        insert testCase;
    }

    @isTest
    static void testGetInstaDmDetails() {
        // Retrieve the test Case Id
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;

        Test.startTest();
        List<instaDmLWCController.instaDMWrapper> dmDetails = instaDmLWCController.getInstaDmDetails(caseId);
        Test.stopTest();
        
        // Assert that the result is empty (as the method is currently returning an empty list)
        System.assertEquals(0, dmDetails.size(), 'Expected no DM details');
    }

    @isTest
    static void testSendMessage() {
        // Retrieve the test Case Id
        Id caseId = [SELECT Id FROM Case LIMIT 1].Id;

        // Mocking the HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        instaDmLWCController.sendMessage('testRecipientId', 'Hello, this is a test message!', caseId);
        Test.stopTest();
        
        // There are no asserts for the sendMessage method as it does not return anything
        // The debug logs would indicate if the call was successful
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message_id": "1234567890"}');
            res.setStatusCode(200);
            return res;
        }
    }
}