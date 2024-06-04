@isTest
public class DynamicHttpCalloutTest {
    
    @testSetup
    static void setup() {
        // Setup test data if necessary
    }
    
    @isTest
    static void testMakeHttpGetCallout() {
        // Set mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, '{"status":"success"}'));

        // Make callout
        Test.startTest();
        HttpResponse response = DynamicHttpCallout.makeHttpGetCallout('https://test.com/api/resource', null, null);
        Test.stopTest();
        
        // Validate response
        System.assertEquals(200, response.getStatusCode());
        System.assertEquals('{"status":"success"}', response.getBody());
    }
    
    @isTest
    static void testMakeHttpPOSTCallout() {
        // Set mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(201, '{"status":"created"}'));

        // Make callout
        Test.startTest();
        HttpResponse response = DynamicHttpCallout.makeHttpPOSTCallout('https://test.com/api/resource', null, null);
        Test.stopTest();
        
        // Validate response
        System.assertEquals(201, response.getStatusCode());
        System.assertEquals('{"status":"created"}', response.getBody());
    }
    
    @isTest
    static void testMakeHttpDeleteCallout() {
        // Set mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(204, ''));

        // Make callout
        Test.startTest();
        HttpResponse response = DynamicHttpCallout.makeHttpDeleteCallout('https://test.com/api/resource', null, null);
        Test.stopTest();
        
        // Validate response
        System.assertEquals(204, response.getStatusCode());
        System.assertEquals('', response.getBody());
    }
    
    // Mock class to simulate HTTP responses
    private class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponse(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}