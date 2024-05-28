@IsTest
private class AccessTokenUtilityTest {

    @IsTest
    static void testGetLongLivedUserAccessToken() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method to test
        AccessTokenUtility.getLongLivedUserAccessToken();
        
        // Retrieve the updated Instagram_Api_Details__c record
        Instagram_Api_Details__c updatedFap = Instagram_Api_Details__c.getOrgDefaults();
        
    }

    @IsTest
    static void testGetLongLivedPageAccessToken() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method to test
        AccessTokenUtility.getLongLivedPageAccessToken();
        
        // Retrieve the updated Instagram_Api_Details__c record
        Instagram_Api_Details__c updatedFap = Instagram_Api_Details__c.getOrgDefaults();
        
    }

    @IsTest
    static void testGetLongLivedAppAccessToken() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the method to test
        AccessTokenUtility.getLongLivedAppAccessToken();
        
        // Retrieve the updated Instagram_Api_Details__c record
        Instagram_Api_Details__c updatedFap = Instagram_Api_Details__c.getOrgDefaults();
        
        // Assert that the app access token has been updated (if uncommented in the original class)
        // System.assertEquals('mock_long_lived_access_token', updatedFap.App_Access_Token__c);
    }

    // Mock HTTP Response Generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"mock_long_lived_access_token"}');
            res.setStatusCode(200);
            return res;
        }
    }
}