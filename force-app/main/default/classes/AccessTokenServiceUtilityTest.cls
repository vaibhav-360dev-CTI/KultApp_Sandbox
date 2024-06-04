@isTest
public class AccessTokenServiceUtilityTest {

    @testSetup
    static void setupTestData() {
        // Create a test Instagram_Api_Details__c record
        Instagram_Api_Details__c apiDetails = new Instagram_Api_Details__c(
            CLIENT_ID__c = 'testClientId',
            CLIENT_SECRET__c = 'testClientSecret',
            REDIRECT_URI__c = 'https://test.com/callback',
            accessToken__c = 'testAccessToken'
        );
        insert apiDetails;
    }

    @isTest
    static void testGetPageAccessToken() {
        // Mock the HTTP response for the page access token request
        Test.setMock(HttpCalloutMock.class, new MockPageAccessTokenResponse());

        Test.startTest();
        String pageAccessToken = AccessTokenServiceUtility.getPageAccessToken('Test Page');
        Test.stopTest();

        // Verify the page access token
        System.assertEquals('mockPageAccessToken', pageAccessToken, 'The page access token should be correct');
        
        // Verify that the custom setting was updated
        Instagram_Api_Details__c settings = Instagram_Api_Details__c.getOrgDefaults();
        System.assertEquals('mockPageAccessToken', settings.pageAccessToken__c, 'The page access token in the custom setting should be updated');
    }

    @isTest
    static void testGetAppAccessToken() {
        Test.startTest();
        String appAccessToken = AccessTokenServiceUtility.getAppAccessToken();
        Test.stopTest();

        // Verify the app access token
        Instagram_Api_Details__c settings = Instagram_Api_Details__c.getOrgDefaults();
        String expectedAppAccessToken = settings.CLIENT_ID__c + '|' + settings.CLIENT_SECRET__c;
        System.assertEquals(expectedAppAccessToken, appAccessToken, 'The app access token should be correct');
    }

    @isTest
    static void testGetUserAccessToken() {
        // Mock the HTTP response for the user access token request
        Test.setMock(HttpCalloutMock.class, new MockUserAccessTokenResponse());

        // Simulate setting the authorization code in the current page's parameters
        Test.setCurrentPageReference(new PageReference('/testPage'));
        ApexPages.currentPage().getParameters().put('code', 'testAuthCode');

        Test.startTest();
        String userAccessToken = AccessTokenServiceUtility.getUserAccessToken();
        Test.stopTest();

        // Verify the user access token
        System.assertEquals('mockUserAccessToken', userAccessToken, 'The user access token should be correct');
    }

    private class MockPageAccessTokenResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data": [{"id": "123456", "name": "Test Page", "access_token": "mockPageAccessToken", "tasks": []}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class MockUserAccessTokenResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token": "mockUserAccessToken"}');
            res.setStatusCode(200);
            return res;
        }
    }
}