@isTest
private class FBMessageWrapperTest {
    
    @testSetup
    static void setupData() {
        Meta_App_Credentials__c live = new Meta_App_Credentials__c();
        live.Access_Token__c='EAAKJz6xiZC6gBO2KIGlCVpLdEshQfphFxZAEsohWvd4tQ7Oz0l3XEa2Cl7P9V4KlKLF9IpAuXeBzh7YobZC7NCBTLcAuiMEwxMcFSvsaIGzwDh83Hz0dWAZCtpy8jQecKnMZAKziJZBfhHLx0LEWdxXP3LQ23SHcZCNZCcsLXUZCu3kq0ZCVo3T7IesseOZB';
        live.App_Secret__c='c35b532f78fa602cc906d82f83d6ba848j88';
        live.Name='live';
        live.Page_Name__c='Test Salesforce Integration';
        live.Webhook_Token__c='EAAKJz6xiZC6gBAEQ7Ub3pazJxFazWFUXEkbp2Hlg0W0EmblRJVhrLLr1WUwL81hqfSxRXJJ8otiGZAyQ66onZBoRFTOqdjZBKioZA5iy55N0rxyZBulbw1XVgu6ktZA0b0vs6uZAFG7SodcyHayN2id8WAktoJejpdCcaTLF9NwV6FkTvizWzYBZXUNUU';
        live.Source__c='Facebook';
        live.SObject_Record_Type__c='Social';
        live.Owner_Type__c='User';
        live.Owner_Type__c= UserInfo.getUserName();
        insert live;
    }
    
    @isTest
    static void testVerify() {
        //MetaWebhookListener.WEB_TOKEN = 'Your_Test_Web_Token';
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/webhooklistener';
        request.addParameter('hub.verify_token','EAAKJz6xiZC6gBAEQ7Ub3pazJxFazWFUXEkbp2Hlg0W0EmblRJVhrLLr1WUwL81hqfSxRXJJ8otiGZAyQ66onZBoRFTOqdjZBKioZA5iy55N0rxyZBulbw1XVgu6ktZA0b0vs6uZAFG7SodcyHayN2id8WAktoJejpdCcaTLF9NwV6FkTvizWzYBZC' );
        request.addParameter('hub.challenge', '12345');
        RestContext.request = request;
        //Integer challenge = MetaWebhookListener.verify();
        // System.assertEquals(12345, challenge);
    }
 
    @isTest
    static void testProcessMassage(){
        Case existingPost = new Case(
            Type_of_Post__c = 'Post',
            Origin = 'Facebook',
            Subject = 'Existing post',
            Post_Id__c = '6307588752695992',
            Description = 'This is an existing post.',
            // = '0126D000003Koa9QAC' ,// Use the test Record Type Id
            OwnerId = UserInfo.getUserId()
        );
        insert existingPost;
        
        Case_Communication__c postComments = new Case_Communication__c();
        postComments.Activity_ID__c='6307588752695992';
        postComments.Activity_Content__c='Hii im test';
        postComments.Case__c=existingPost.id;
        postComments.Activity_Created_DateTime__c=system.now();
        insert postComments;
        
        string newMessageAttch='{"object_c":"page","entry":[{"id":"103319499517877","time_c":1691598609924,"messaging":[{"sender":{"id":"6307588752695992"},"recipient":{"id":"103319499517877"},"timestamp":1691598609225,"message":{"mid":"m_l4tBfpHRQ_L3tetQEWpKUDkXdhsCETFtIVCp_p1na0c9mm3N8baoaHboUb9Bjk3iQSdFbeHP25kHVKV3RSfbeA","attachments":[{"type":"image","payload":{"url":"https://scontent.xx.fbcdn.net/v/t1.15752-9/364441076_960022621777348_1490944164088415253_n.jpg?_nc_cat=109&ccb=1-7&_nc_sid=58c789&_nc_ohc=QqeJl-OaQioAX9T6gzM&_nc_ad=z-m&_nc_cid=0&_nc_ht=scontent.xx&oh=03_AdRQ6wfoZC2Rj5SYwFsNZy_CKt-V5rhaMH3tlXhgW-I5NQ&oe=64FB25BC"}},{"type":"image","payload":{"url":"https://scontent.xx.fbcdn.net/v/t1.15752-9/363807297_306623695274269_2814077906410852488_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=58c789&_nc_ohc=lhzSQHvnavkAX-05Qyz&_nc_ad=z-m&_nc_cid=0&_nc_ht=scontent.xx&oh=03_AdR6e8CcB2nRAv5NkF3bQ7-NymrekwTquZqAjadkmRsrsg&oe=64FB236F"}}]}}]}]}}';
        FBPageCommentWrapper.parse(newMessageAttch);
        FBMessageWrapper.parse(newMessageAttch);
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/webhooklistener';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(newMessageAttch);
        
        
        RestResponse response = new RestResponse();
        
        RestContext.request = request;
        RestContext.response = response;
        
        //MetaWebhookListener.webhookListener();
        
        Test.startTest();
       
        newMessageAttch = '{"object_c":"page","entry":[{"id":"103319499517877","time_c":1691739155189,"messaging":[{"sender":{"id":"6307588752695992"},"recipient":{"id":"103319499517877"},"timestamp":1691739154822,"message":{"mid":"m_xi0pIwRizxp1N7KJVz9bLTkXdhsCETFtIVCp_p1na0dZP_uK8tdISKG9S2pnd2CoHm1AYkHm-FSqakn2-XHTLQ","text":"Hello","reply_to":{"mid":"m_Dw0Jd5Gf4gtnAhqYfHjJVDkXdhsCETFtIVCp_p1na0eiKpmMI6JnqAM0epyYSirECLeuGBIlhXDd8EYdOEEpOg"}}}]}]}}';
        request.requestBody = Blob.valueOf(newMessageAttch);
       // MetaWebhookListener.webhookListener();
        Test.stopTest();
        
    }
    
    // Define other test methods for different scenarios (edit post, new comment, etc.)
    
    private static String generateNewPostRequestBody() {
        string fornewPost='{"entry":[{"id":"103319499517877","time":1690800614,"changes":[{"value":{"from":{"id":"103319499517877","name":"Test Salesforce Integration"},"message":"Hi Test post from facebook","post_id":"103319499517877_106857975834754","created_time":1690800612,"item":"status","published":1,"verb":"add"},"field":"feed"}]}],"object":"page"}';
        return fornewPost;
    }
    
    
    
}