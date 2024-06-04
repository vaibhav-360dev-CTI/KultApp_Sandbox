@isTest
public class ExampleCalloutMockTest {

    @isTest
    static void testHttpCalloutWithMock() {
        // Set the mock callout response
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());

        // Example endpoint for the callout
        String endpointUrl = 'https://example.com/api/resource';
        
        // Perform the HTTP GET callout using the DynamicHttpCallout class
        HttpResponse response;
        Test.startTest();
        response = DynamicHttpCallout.makeHttpGetCallout(endpointUrl, null, null);
        Test.stopTest();
        
        // Verify the response
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals(200, response.getStatusCode(), 'Status code should be 200');
        System.assertEquals('GREAT SCOTT', response.getBody(), 'Response body should match the mock response');
    }
    
    @isTest
    static void testHttpPostCalloutWithMock() {
        // Set the mock callout response
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());

        // Example endpoint for the callout
        String endpointUrl = 'https://example.com/api/resource';
        
        // Perform the HTTP POST callout using the DynamicHttpCallout class
        HttpResponse response;
        Test.startTest();
        response = DynamicHttpCallout.makeHttpPOSTCallout(endpointUrl, null, null);
        Test.stopTest();
        
        // Verify the response
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertEquals(200, response.getStatusCode(), 'Status code should be 200');
        System.assertEquals('GREAT SCOTT', response.getBody(), 'Response body should match the mock response');
    }
    
    @isTest
    static void testHttpDeleteCalloutWithMock() {
        // Set the mock callout response
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());

        // Example endpoint for the callout
        String endpointUrl = 'https://example.com/api/resource';
        
        // Perform the HTTP DELETE callout using the DynamicHttpCallout class
        HttpResponse response;
        Test.startTest();
        response = DynamicHttpCallout.makeHttpDeleteCallout(endpointUrl, null, null);
        Test.stopTest();
    }
}