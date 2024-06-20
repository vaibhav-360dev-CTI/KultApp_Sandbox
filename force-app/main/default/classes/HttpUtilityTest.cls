@isTest
public class HttpUtilityTest {
    
    @isTest
    static void testSingletonInstance() {
        HttpUtility instance1 = HttpUtility.getInstance();
        HttpUtility instance2 = HttpUtility.getInstance();
        
    }
    
    // @isTest
    // static void testSendRequest() {
    //     // Mock the Neemans_Configuration__c custom setting
    //     IntegrationLogConfig__c neemansConfig = new IntegrationLogConfig__c(
    //         Enable_Integration_Logger__c = true
    //     );
    //     insert neemansConfig;

    //     // Mock the HTTP response
    //     HttpResponse mockResponse = new HttpResponse();
    //     mockResponse.setHeader('Content-Type', 'application/json');
    //     mockResponse.setBody('{"status": "success"}');
    //     mockResponse.setStatusCode(200);
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
    //     String endPoint = 'https://api.example.com/endpoint';
    //     String token = 'mockToken';
    //     String body = '{"data": "sample"}';
    //     String methodType = 'POST';
        
    //     Test.startTest();
    //     HttpResponse response = HttpUtility.sendRequest(endPoint, token, body, methodType);
    //     Test.stopTest();
    // }
    
    // @isTest
    // static void testHttpReqHelper() {
    //     // Mock the HTTP response
    //     HttpResponse mockResponse = new HttpResponse();
    //     mockResponse.setHeader('Content-Type', 'application/json');
    //     mockResponse.setBody('{"status": "success"}');
    //     mockResponse.setStatusCode(200);
        
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
    //     // Mock the Neemans_Configuration__c custom setting
    //     Neemans_Configuration__c neemansConfig = new Neemans_Configuration__c(
    //         Enable_Callouts_Logger__c = true
    //     );
    //     insert neemansConfig;

    //     // Create a mock Integration_Log__c record
    //     Integration_Log__c log = new Integration_Log__c(
    //         HTTP_Method__c = 'GET',
    //         EndPoint__c = 'https://api.example.com/endpoint',
    //         Status__c = 'Completed'
    //     );
    //     insert log;
        
    //     Map<String, String> headerMap = new Map<String, String>{'Authorization' => 'Bearer mockToken'};
    //     String method = 'POST';
    //     String jsonBody = '{"data": "sample"}';
    //     String endPoint = 'https://api.example.com/endpoint';
    //     Id integrationLogId = log.Id;
        
    //     Test.startTest();
    //     String responseBody = HttpUtility.getInstance().httpReqHelper(headerMap, method, jsonBody, endPoint, integrationLogId);
    //     Test.stopTest();
        
    // }
    
    @isTest
    static void testCreateServiceLogger() {
        // Mock the Neemans_Configuration__c custom setting
        IntegrationLogConfig__c neemansConfig = new IntegrationLogConfig__c(
            Enable_Integration_Logger__c = true
        );
        insert neemansConfig;

        String reqBody = '{"request": "data"}';
        String resBody = '{"response": "data"}';
        String endPoint = 'https://api.example.com/endpoint';
        String method = 'POST';
        Integer statusCode = 200;
        DateTime startDatetime = DateTime.now();
        DateTime endDatetime = DateTime.now().addMinutes(1);
        String referenceId = 'mockRefId';
        
        Test.startTest();
        HttpUtility.getInstance().createServiceLogger(null,reqBody, resBody, endPoint, method, statusCode, startDatetime, endDatetime, referenceId, 'SERVICE');
        Test.stopTest();
        
    }
    
    // @isTest
    // static void testCreateAuditLog() {
    //     String requestBody = '{"data": "sample"}';
    //     String type = APIConstants.API_SEARCHORDER;
        
    //     Test.startTest();
    //     Id logId = HttpUtility.getInstance().CreateAuditLog(requestBody, type);
    //     Test.stopTest();
    // }

    @isTest
    static void testCreateLog() {
        // Mock HttpRequest and HttpResponse
        HttpRequest mockRequest = new HttpRequest();
        mockRequest.setEndpoint('https://api.example.com/endpoint');
        mockRequest.setBody('{"request": "data"}');
        
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setHeader('Content-Type', 'application/json');
        mockResponse.setBody('{"status": "success"}');
        mockResponse.setStatusCode(200);
        
        // Create a new Integration_Log__c record
        Integration_Log__c logger = new Integration_Log__c(
            HTTP_Method__c = 'POST',
            EndPoint__c = 'https://api.example.com/endpoint',
            Status__c = 'Completed'
        );

        Test.startTest();
        HttpUtility.getInstance().createLog(logger, mockRequest, mockResponse);
        Test.stopTest();
        
    }
    
    // Mock HttpCalloutMock class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse mockResponse;
        
        public MockHttpResponseGenerator(HttpResponse response) {
            this.mockResponse = response;
        }
        
        public HttpResponse respond(HttpRequest request) {
            return mockResponse;
        }
    }
}