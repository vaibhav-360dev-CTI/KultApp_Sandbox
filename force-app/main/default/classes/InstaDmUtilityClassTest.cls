@IsTest
private class InstaDmUtilityClassTest {
    
    @TestSetup
    static void setup() {
        // Insert a mock Instagram_Api_Details__c record
        Instagram_Api_Details__c apiDetails = new Instagram_Api_Details__c(
            CLIENT_ID__c = 'mockClientId',
            CLIENT_SECRET__c = 'mockClientSecret',
            REDIRECT_URI__c = 'http://mockRedirectUri',
            accessToken__c = 'mockAccessToken',
            pageAccessToken__c = 'mockPageAccessToken',
            basicUrl__c = 'https://graph.facebook.com/v11.0/',
            Page_Id__c = 'mockPageId',
            businessUserId__c = 'mockBusinessUserId'
        );
        insert apiDetails;
    }
    
    @IsTest
    static void testGetAllDmMessages() {
        
        // Insert a mock Case record
        Case mockCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media').getRecordTypeId(),
            User_ID__c = 'mockUserId',
            Origin = 'Facebook',
            Subject = 'Mock Case Subject'
        );
        insert mockCase;
        
        // Insert a mock Post_Comments__c record
        Case_Communication__c mockComment = new Case_Communication__c(
            Case__c = mockCase.Id,
            Activity_Content__c = 'Mock comment',
            Activity_ID__c = 'mockCommentId',
            Activity_Author__c = 'Mock User',
            Activity_User_ID__c = 'mockUserId',
            Activity_Type__c = 'DM'
        );
        insert mockComment;
        
        Test.startTest();
        
        // Call the method
        String result = InstaDmUtilityClass.getAllDmMessages();
        
        // Assertions
        //System.assertEquals('Success', result, 'The method should return Success.');
        
        // Additional assertions to check records created/updated
        List<Case> cases = [SELECT Id FROM Case WHERE Origin = 'Facebook'];
        //System.assert(cases.size() > 0, 'Cases should be created or updated.');
        
        List<Case_Communication__c> comments = [SELECT Id FROM Case_Communication__c];
        //System.assert(comments.size() > 0, 'Post_Comments__c records should be created.');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAllDmMessagesv2() {
        
        // Insert a mock Case record
        Case mockCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media').getRecordTypeId(),
            User_ID__c = '25002797006001335',
            Origin = 'Facebook',
            Subject = 'Mock Case Subject'
        );
        insert mockCase;
        
        // Insert a mock Post_Comments__c record
        Case_Communication__c mockComment = new Case_Communication__c(
            Case__c = mockCase.Id,
            Activity_Content__c = 'Mock comment',
            Activity_ID__c = 'mockCommentId',
            Activity_Author__c = 'Mock User',
            Activity_User_ID__c = '25002797006001335',
            Activity_Type__c = 'DM'
        );
        insert mockComment;
        
        Test.startTest();
        
        // Call the method
        String result = InstaDmUtilityClass.getAllDmMessages();
        
        // Assertions
        //System.assertEquals('Success', result, 'The method should return Success.');
        
        // Additional assertions to check records created/updated
        List<Case> cases = [SELECT Id FROM Case WHERE Origin = 'Facebook'];
        //System.assert(cases.size() > 0, 'Cases should be created or updated.');
        
        List<Case_Communication__c> comments = [SELECT Id FROM Case_Communication__c];
        //System.assert(comments.size() > 0, 'Post_Comments__c records should be created.');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAllDmMessagesv3() {
        
        // Insert a mock Case record
        Case mockCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media').getRecordTypeId(),
            User_ID__c = '25002797006001334',
            Origin = 'Facebook',
            Subject = 'Mock Case Subject'
        );
        insert mockCase;
        
        // Insert a mock Post_Comments__c record
        Case_Communication__c mockComment = new Case_Communication__c(
            Case__c = mockCase.Id,
            Activity_Content__c = 'Mock comment',
            Activity_ID__c = 'mockCommentId',
            Activity_Author__c = 'Mock User',
            Activity_User_ID__c = '250027970060013354',
            Activity_Type__c = 'DM'
        );
        insert mockComment;
        
        Test.startTest();
        
        // Call the method
        String result = InstaDmUtilityClass.getAllDmMessages();
        
        // Assertions
        //System.assertEquals('Success', result, 'The method should return Success.');
        
        // Additional assertions to check records created/updated
        List<Case> cases = [SELECT Id FROM Case WHERE Origin = 'Facebook'];
        //System.assert(cases.size() > 0, 'Cases should be created or updated.');
        
        List<Case_Communication__c> comments = [SELECT Id FROM Case_Communication__c];
        //System.assert(comments.size() > 0, 'Post_Comments__c records should be created.');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGetDmMessagesForUser() {
        
        // Insert a mock Case record
        Case mockCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Social Media').getRecordTypeId(),
            User_ID__c = '25002797006001335',
            Origin = 'Facebook',
            Subject = 'Mock Case Subject'
        );
        insert mockCase;
        
        // Insert a mock Post_Comments__c record
        Case_Communication__c mockComment = new Case_Communication__c(
            Case__c = mockCase.Id,
            Activity_Content__c = 'Mock comment',
            Activity_ID__c = 'mockCommentId',
            Activity_Author__c = 'Mock User',
            Activity_User_ID__c = '25002797006001335',
            Activity_Type__c = 'DM'
        );
        insert mockComment;
        
        Test.startTest();
        
        // Get an existing Case Id for testing
        Case existingCase = [SELECT Id FROM Case LIMIT 1];
        String caseId = existingCase.Id;
        String recipientId = 'mockUserId';
        
        // Call the method
        String result = InstaDmUtilityClass.getDmMessagesForUser(recipientId, caseId);
        InstaDmUtilityClass.getDateTime('2024-04-23T10:58:48');
        // Assertions
        //System.assertEquals('Success', result, 'The method should return Success.');
        
        // Additional assertions to check records created/updated
        List<Case_Communication__c> comments = [SELECT Id FROM Case_Communication__c WHERE Case__c = :caseId];
        
        Test.stopTest();
    }
    
    @IsTest
    static void testDeserialization() {
        // The JSON string
        String jsonResponse = '{ "data": [ { "message_count": 43, "messages": { "data": [ { "message": "Perfecto.. ❣️❣️", "id": "m_zk_yX77f4wfo19RXbt7T3GeWoab2xwE0I2Q6gkqWrzCdyXNrkAf38P4LU_lFvCUEf2Yw2HvBqVJEJIGWQW8Eqw", "thread_id": "t_7896332630396959", "created_time": "2024-04-23T10:59:40+0000", "from": { "name": "Shubham Kumar", "email": "25002797006001335@facebook.com", "id": "25002797006001335" } }, { "message": "107238405785525 107238405785525 107238405785525", "id": "m_C-_JjfOriV58DkQXwRGzkWeWoab2xwE0I2Q6gkqWrzA3OzjEe46qLiLW5IU2OJ2wdhoINz30Gs9eAtk04mD6Kg", "thread_id": "t_7896332630396959", "created_time": "2024-04-23T10:58:48+0000", "from": { "name": "Lets Hyphen", "email": "107238405785525@facebook.com", "id": "107238405785525" } }, { "message": "Hello team..", "id": "m_6qn9EjvEUpphaBw2YefT52eWoab2xwE0I2Q6gkqWrzB9YkCk_DyROCBKNZ3vhp_6dXJNUN96VZoEhKkInpYUNQ", "thread_id": "t_7896332630396959", "created_time": "2024-04-23T10:54:19+0000", "from": { "name": "Shubham Kumar", "email": "25002797006001335@facebook.com", "id": "25002797006001335" } } ], "paging": { "cursors": { "before": "QVFIUnBad2RkVWZAWQTBxVlBNb2tmMnFkNXctS0s1dlVMdVNzSENzZAXdVc1ZAuZAi1WLWdOc0lZAWUdVRlQtWVZA6TkhDNWlyR19ndFdZAeXhTLUtMLUFkY0Qzam1ETEp3ZAWdSOUtpQzBNLTFKQ1Q0ODNrdW5zbzZAST3FiR3UwcDY4MGVWMlJN", "after": "QVFIUlVvTG01LS1FRE5ubG8zMUx2ODdHUm0yeUh0NDBPN2NreWJSZAmU5TE5iVmRSRUROX0hjRUNhVF83VE52RldDN1RGT2UySGxiR29Ram9JQmtpQjRBMzg3NjlXSHVONWl5VXQwN3dDa1hTNVdvb0RTNnhsWmxtLUw4TzlDQlpEcTk3" }, "next": "https://graph.facebook.com/v17.0/t_7896332630396959/messages?access_token=EAAVh021BZCJsBO3TBwMISFowlLGSsfxd8ccxiJXxsWnuFBPmA8DjEBdAMKZA9eLxNo5Osq3o32TpMTyTZC9GY2Indd3uEzZAs3uw80UtjQcyJUsIRPRO8LtfvCJefKJ4y4ZBXo0edQI6skkJEZBYAqnQKK3uydnZAIkGdgQqz7jQ1RbTLqZBS7UtXsiD2DktMqlwLs552hPRZALaZBuRdPuAHBZBqUcR6eW4UGj9gZDZD&pretty=0&fields=message%2Cid%2Cthread_id%2Ccreated_time%2Cfrom&limit=25&after=QVFIUlVvTG01LS1FRE5ubG8zMUx2ODdHUm0yeUh0NDBPN2NreWJSZAmU5TE5iVmRSRUROX0hjRUNhVF83VE52RldDN1RGT2UySGxiR29Ram9JQmtpQjRBMzg3NjlXSHVONWl5VXQwN3dDa1hTNVdvb0RTNnhsWmxtLUw4TzlDQlpEcTk3" } }, "id": "t_7896332630396959", "can_reply": true, "senders": { "data": [ { "name": "Shubham Kumar", "email": "25002797006001335@facebook.com", "id": "25002797006001335" }, { "name": "Lets Hyphen", "email": "107238405785525@facebook.com", "id": "107238405785525" } ] } } ]}';
        
        // Replace "from" with "fromDetails" in the JSON string
        jsonResponse = jsonResponse.replaceAll('"from"', '"fromDetails"');

        // Deserialize the JSON string into the wrapper class
        InstaDMWrapper wrapperInstance = (InstaDMWrapper) JSON.deserialize(jsonResponse, InstaDMWrapper.class);

        // Assertions to verify the deserialization
        System.assertNotEquals(null, wrapperInstance);
        System.assertEquals(1, wrapperInstance.data.size());

        InstaDMWrapper.Data conversation = wrapperInstance.data[0];
        System.assertEquals('t_7896332630396959', conversation.id);
        System.assertEquals(43, conversation.message_count);

        InstaDMWrapper.MessageData message1 = conversation.messages.data[0];
        System.assertEquals('Perfecto.. ❣️❣️', message1.message);
        System.assertEquals('Shubham Kumar', message1.fromDetails.name);

        InstaDMWrapper.MessageData message2 = conversation.messages.data[1];
        System.assertEquals('107238405785525 107238405785525 107238405785525', message2.message);
        System.assertEquals('Lets Hyphen', message2.fromDetails.name);

        InstaDMWrapper.MessageData message3 = conversation.messages.data[2];
        System.assertEquals('Hello team..', message3.message);
        System.assertEquals('Shubham Kumar', message3.fromDetails.name);
    }
}