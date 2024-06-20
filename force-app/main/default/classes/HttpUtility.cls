public without sharing class HttpUtility {
    static final String NO_RESPONSE = 'NO_RESPONSE';
    static final String HTTP_ERROR = 'ERROR WHILE MAKING REQUEST';
    static IntegrationLogConfig__c intLogCon;
    
    public static HttpUtility httpUtilityInstance;
    
    public HttpUtility() {
    }
    
    public static HttpUtility getInstance() {
        if (httpUtilityInstance == null) {
            httpUtilityInstance = new HttpUtility();
            intLogCon = IntegrationLogConfig__c.getInstance();
        }
        return httpUtilityInstance;
    }
    
    // public static HttpResponse sendRequest(String endPoint, String token, String body, String methodType) {
    //     Neemans_Configuration__c neemansObj =  Neemans_Configuration__c.getInstance();
    //     try {
    //         Http http = new Http();
    //         HttpRequest request = new HttpRequest();
    //         request.setEndpoint(endPoint);
    //         request.setMethod(methodType);
    //         request.setBody(body);
    //         request.setHeader('Content-Type', 'application/json');
    //         request.setHeader('Authorization', 'Bearer ' + token);
    //         HttpResponse response;
    //         if (neemansObj != null && neemansObj.Enable_Callouts_Logger__c) {
    //             response = http.send(request);
    //         }
    //         return response;
    //     } catch (Exception e) {
    //         System.debug('ERROR :: ' + e.getMessage() + ' AT LINE NUMBER :: ' + e.getLineNumber());
    //         HandleBusinessException.captureError('HTTPUtility', 'sendRequest', e);
    //         return null;
    //     }
    // }
    
    // public String httpReqHelper(Map<String,String> headerMap, String method, String jsonBody, String endPoint, Id integrationLogId) {
        
    //     HttpRequest httpRequest = new HttpRequest();
    //     httpRequest.setEndpoint(endpoint);
    //     httpRequest.setMethod(method);
    //     if(method != 'GET')
    //         httpRequest.setBody(jsonBody);
    //     if(intLogCon.Request_TimeOut__c != null)
    //         httpRequest.setTimeout(Integer.valueOf(intLogCon.Request_TimeOut__c));
        
    //     System.debug('httpReqHelper Endpoint : '+httpRequest.getEndpoint());
        
    //     if(!headerMap.isEmpty()){
    //         for(String key : headerMap.keySet()){
    //             httpRequest.setHeader(key,headerMap.get(key)); 
    //         }
    //     }
        
    //     try {
    //         Http http = new Http();
    //         HTTPResponse response = http.send(httpRequest);
    //         system.debug('response==> '+response);
    //         System.debug('Response Status: ' + response.getStatus());
    //         System.debug('Response Status Code: ' + response.getStatusCode());
    //         System.debug('Response Body: ' + response.getBody());
    //         Integer maxLength = 32768;
            
    //         if(integrationLogId != null){
    //             Integration_Log__c logger = new Integration_Log__c();
    //             logger.Id = integrationLogId;
    //             logger.HTTP_Method__c = APIConstants.HTTP_GET;
    //             logger.EndPoint__c = endPoint;
    //             logger.Status__c = APIConstants.INT_LOG_COMPLETED;
    //             if(response.getStatusCode() != 200 || response.getStatusCode() != 201){
    //                 logger.Response_Status_Code__c = 400;
    //             }else{
    //                 logger.Response_Status_Code__c = response.getStatusCode();
    //             }
    //             String responseBody = response.getBody();
    //             if(responseBody.length() > maxLength){
    //                 logger.Response_Body__c = responseBody.substring(0, maxLength);
    //             }else{
    //                 logger.Response_Body__c = responseBody;
    //             }
    //             update logger;
    //         }
            
    //         System.debug('httpReqHelper --- response.getBody() '+ response.getBody());
    //         if(response.getStatusCode() == 200 || response.getStatusCode() == 201)
    //             return response.getBody();
    //         return NO_RESPONSE;
    //     }
    //     catch (Exception e) {
    //         System.debug('httpReqHelper --- e-message '+ e.getMessage());
    //         System.debug('httpReqHelper --- e-line-no '+ e.getLineNumber());
    //         HandleBusinessException.captureError('HttpUtility', 'httpReqHelper', e);
    //         return HTTP_ERROR;
    //     }
        
    // }
    
    @TestVisible
    private void createLog(Integration_Log__c logger, HttpRequest httpReq, HttpResponse httpRes) {
        if(httpReq != null) {
            logger.Request_Body__c = httpReq.getBody();
            logger.EndPoint__c = httpReq.getEndPoint();
        }
        if(httpRes != null) {
            if(httpRes.getBody().length() > 32768)
                logger.Response_Body__c = httpRes.getBody().substring(0,32767);
            else
                logger.Response_Body__c = httpRes.getBody();
            logger.Response_Status_Code__c = httpRes.getStatusCode();
        }
        insert logger;
    }
    
    @TestVisible
    public Id createServiceLogger(Id integrationLogId, String reqBody, String resBody, String endPoint, String method, Integer statusCode, DateTime startDatetime, DateTime endDateTime, String refferenceId, String serviceType) {
        
        try {
            if (intLogCon != null && intLogCon.Enable_Integration_Logger__c) {
                Integration_Log__c logger = new Integration_Log__c();
                if(integrationLogId != null){
                    logger.Id = integrationLogId;
                }else{
                    system.debug('New Integration Log');
                }
                logger.HTTP_Method__c = method;
                logger.Integration_Type__c = serviceType;
                logger.Request_Body__c = reqBody;
                logger.Response_Body__c = resBody;
                logger.EndPoint__c = endPoint;
                logger.Response_Status_Code__c = statusCode;
                logger.Start_Date_And_Time__c = startDatetime;
                logger.End_Date_And_Time__c = endDateTime;
                logger.Reference_Id__c = refferenceId;
                upsert logger;
                System.debug('logger.Id -- ' + logger.Id + logger);
                return logger.Id;
            }
            return null;
        } catch (DMLException e) {
            System.debug('--- e-message ' + e.getMessage());
            System.debug('--- e-line-no ' + e.getLineNumber());
            return null;
        }
    }
    
    // public Id CreateAuditLog(String requestBody,String type) {
    //     system.debug('requestBody String==>'+requestBody);
    //     try {
    //         if (requestBody != null) {
                
    //             Integration_Log__c logger = new Integration_Log__c();
                
    //             if(type == APIConstants.API_SEARCHORDER){
    //                 SearchSalesOrderController.dateWrapper dateWrp = (SearchSalesOrderController.dateWrapper)JSON.deserialize(requestBody, SearchSalesOrderController.dateWrapper.class);
    //                 logger.Start_Date_And_Time__c = dateWrp.fromDate;
    //                 logger.End_Date_And_Time__c = dateWrp.toDate;
    //                 system.debug('dateWrp==>'+dateWrp);
    //             }
                
    //             logger.Status__c = APIConstants.INT_LOG_INITIATED;
    //             logger.Integration_Type__c = APIConstants.HTTP_CALLOUT;
    //             logger.Request_Body__c = requestBody;
                
    //             insert logger;
    //             System.debug('logger.Id -- ' + logger.Id);
    //             return logger.Id;
    //         }
    //         return null;
    //     } catch (DMLException e) {
    //         System.debug('--- e-message ' + e.getMessage());
    //         System.debug('--- e-line-no ' + e.getLineNumber());
    //         HandleBusinessException.captureError('HttpUtility', 'httpReqHelper', e);
    //         return null;
    //     }
    // }
}