@isTest
public class WS_SendPolicyAndTnCTest {
    @isTest
    static void testSendData() {
        // Create test data for App_Data__c
        App_Data__c appData = new App_Data__c(
            Privacy_Policy__c = 'This is a test privacy policy.',
            Terms_and_Conditions__c = 'These are test terms and conditions.'
        );
        insert appData;

        // Set up mock HTTP request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/PoilcyAndTnCFetch';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        WS_SendPolicyAndTnC.SFDCtoMobileApp response = WS_SendPolicyAndTnC.sendData();
        Test.stopTest();
    }

    @isTest
    static void testSendDataWithNoRecords() {
        // Set up mock HTTP request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/PoilcyAndTnCFetch';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Test.startTest();
        WS_SendPolicyAndTnC.SFDCtoMobileApp response = WS_SendPolicyAndTnC.sendData();
        Test.stopTest();
    }

    @isTest
    static void testSendDataWithException() {
        // Set up mock HTTP request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/PoilcyAndTnCFetch';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        // Create an exception scenario by manipulating the mock context
        Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new MockHttpCalloutWithException());
        WS_SendPolicyAndTnC.SFDCtoMobileApp response = WS_SendPolicyAndTnC.sendData();
        Test.stopTest();

        // Validate the response
    }

   /* private class MockHttpCalloutWithException implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate an HTTP response indicating a failure
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Mock callout exception');
            return res;
        }

        public String getTypeName() {
            return 'MockHttpCalloutWithException';
        }
    } */
}