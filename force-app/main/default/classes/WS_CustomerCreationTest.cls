@isTest
public class WS_CustomerCreationTest {
    @isTest
    static void testCreateAccount() {
        // Prepare test data
        WS_CustomerCreation.OMSToSFDCAccount testAccount = new WS_CustomerCreation.OMSToSFDCAccount();
        testAccount.uuid = '12345';
        testAccount.phone_number = '1234567890';
        testAccount.email_id = 'test@example.com';
        testAccount.name = 'Test User';
        testAccount.is_deleted = false;
        
        List<WS_CustomerCreation.OMSToSFDCAccount> requestBody = new List<WS_CustomerCreation.OMSToSFDCAccount>{testAccount};
        
        // Serialize request body to JSON
        String requestBodyJson = JSON.serialize(requestBody);
        
        // Set up mock HTTP request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CustomerCreation';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBodyJson);
        RestContext.request = req;
        RestContext.response = res;
        
        // Call the method
        Test.startTest();
        List<WS_CustomerCreation.ResponseBody> response = WS_CustomerCreation.createAccount();
        Test.stopTest();
        
     
        
        // Validate the account in the database
        Account createdAccount = [SELECT Id, Name, Phone, Email__c, UUID__c, Is_Deleted__c FROM Account WHERE UUID__c = :testAccount.uuid LIMIT 1];
    }
    
    @isTest
    static void testCreateAccountWithErrors() {
        // Prepare test data with missing required fields
        WS_CustomerCreation.OMSToSFDCAccount testAccount = new WS_CustomerCreation.OMSToSFDCAccount();
        testAccount.uuid = '12345';
        
        List<WS_CustomerCreation.OMSToSFDCAccount> requestBody = new List<WS_CustomerCreation.OMSToSFDCAccount>{testAccount};
        
        // Serialize request body to JSON
        String requestBodyJson = JSON.serialize(requestBody);
        
        // Set up mock HTTP request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CustomerCreation';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBodyJson);
        RestContext.request = req;
        RestContext.response = res;
        
        // Call the method
        Test.startTest();
        List<WS_CustomerCreation.ResponseBody> response = WS_CustomerCreation.createAccount();
        Test.stopTest();
    }
}