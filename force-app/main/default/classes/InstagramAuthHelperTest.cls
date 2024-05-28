@isTest
private class InstagramAuthHelperTest {

    // Mock HTTP Callout class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if (req.getEndpoint().contains('/media')) {
                res.setBody('{"data":[{"id":"17841405793087218","username":"example_user","timestamp":"2023-07-29T12:34:56+0000","caption":"This is an amazing photo!","media_type":"IMAGE","media_url":"https://www.example.com/image.jpg","permalink":"https://www.instagram.com/p/ABC123/","comments_count":5,"comments":{"data":[{"id":"17851087209098192","text":"Awesome!","username":"user1","timestamp":"2023-07-29T12:40:00+0000"},{"id":"17851087209098193","text":"Great shot!","username":"user2","timestamp":"2023-07-29T12:42:30+0000"},{"id":"17851087209098194","text":"Beautiful!","username":"user3","timestamp":"2023-07-29T12:45:15+0000"},{"id":"17851087209098195","text":"Nice!","username":"user4","timestamp":"2023-07-29T12:50:20+0000"},{"id":"17851087209098196","text":"Love it!","username":"user5","timestamp":"2023-07-29T13:00:00+0000"}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/p/ABC123/comments?cursor=cursor_after"}}},{"id":"17841405793087219","username":"another_user","timestamp":"2023-07-29T14:30:45+0000","caption":"Sunset vibes!","media_type":"VIDEO","media_url":"https://www.example.com/video.mp4","permalink":"https://www.instagram.com/p/XYZ456/","comments_count":2,"comments":{"data":[{"id":"17851087209098197","text":"Amazing video!","username":"user6","timestamp":"2023-07-29T14:40:00+0000"},{"id":"17851087209098198","text":"Beautiful sunset!","username":"user7","timestamp":"2023-07-29T14:45:30+0000"}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/p/XYZ456/comments?cursor=cursor_after"}}}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/user123/media?cursor=cursor_after"}}');
            } else if (req.getEndpoint().contains('/tags')) {
                res.setBody('{"data":[{"id":"17841405793087220","username":"example_user","timestamp":"2023-07-29T12:34:56+0000","caption":"This is a tagged photo!","media_type":"IMAGE","media_url":"https://www.example.com/tagged_image.jpg","permalink":"https://www.instagram.com/p/TAG123/","comments_count":3,"comments":{"data":[{"id":"17851087209098199","text":"Nice tag!","username":"user1","timestamp":"2023-07-29T12:40:00+0000"},{"id":"17851087209098200","text":"Interesting!","username":"user2","timestamp":"2023-07-29T12:42:30+0000"},{"id":"17851087209098201","text":"Cool!","username":"user3","timestamp":"2023-07-29T12:45:15+0000"}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/p/TAG123/comments?cursor=cursor_after"}}}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/user123/tags?cursor=cursor_after"}}');
            } else if (req.getEndpoint().contains('ig_hashtag_search')) {
                res.setBody('{"data":[{"id":"17841405793087221"}]}');
            } else if (req.getEndpoint().contains('/recent_media')) {
                res.setBody('{"data":[{"id":"17841405793087222","username":"example_user","timestamp":"2023-07-29T12:34:56+0000","caption":"This is a hashtagged photo!","media_type":"IMAGE","media_url":"https://www.example.com/hashtagged_image.jpg","permalink":"https://www.instagram.com/p/HASH123/","comments_count":2,"comments":{"data":[{"id":"17851087209098202","text":"Hashtagged!","username":"user1","timestamp":"2023-07-29T12:40:00+0000"},{"id":"17851087209098203","text":"Nice post!","username":"user2","timestamp":"2023-07-29T12:42:30+0000"}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/p/HASH123/comments?cursor=cursor_after"}}}],"paging":{"cursors":{"before":"cursor_before","after":"cursor_after"},"next":"https://www.instagram.com/user123/hashtag?cursor=cursor_after"}}');
            }
            return res;
        }
    }
    
    @isTest
    static void testGetAllPostsFromInstaForUserId() {
        // Set up the mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Insert Instagram_Api_Details__c record
        Instagram_Api_Details__c apiDetails = new Instagram_Api_Details__c(
            CLIENT_ID__c = 'client_id',
            CLIENT_SECRET__c = 'client_secret',
            REDIRECT_URI__c = 'redirect_uri',
            accessToken__c = 'access_token',
            basicUrl__c = 'https://graph.facebook.com/',
            businessUserId__c = 'business_user_id',
            HashTag__c = 'test_hashtag'
        );
        insert apiDetails;
        
        // Execute the method
        Test.startTest();
        InstagramAuthHelper.getAllPostsFromInstaForUserId();
        Test.stopTest();
        
        // Verify results
        List<Case> caseList = [SELECT Id, Subject, Description FROM Case WHERE Origin = 'Instagram'];
        System.assertEquals(2, caseList.size(), 'There should be 2 Cases created');
        
        List<Case_Communication__c> commentList = [SELECT Id, Activity_Content__c FROM Case_Communication__c];
        System.assertEquals(7, commentList.size(), 'There should be 7 Case Communications created');
    }
    
    @isTest
    static void testGetAllMentionsFromInstaForUserId() {
        // Set up the mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Insert Instagram_Api_Details__c record
        Instagram_Api_Details__c apiDetails = new Instagram_Api_Details__c(
            CLIENT_ID__c = 'client_id',
            CLIENT_SECRET__c = 'client_secret',
            REDIRECT_URI__c = 'redirect_uri',
            accessToken__c = 'access_token',
            basicUrl__c = 'https://graph.facebook.com/',
            businessUserId__c = 'business_user_id',
            HashTag__c = 'test_hashtag'
        );
        insert apiDetails;
        
        // Execute the method
        Test.startTest();
        InstagramAuthHelper.getAllMentionsFromInstaForUserId();
        Test.stopTest();
        
        // Verify results
        List<Case> caseList = [SELECT Id, Subject, Description FROM Case WHERE Origin = 'Instagram' AND Type_of_Post__c = 'Mentions'];
        System.assertEquals(1, caseList.size(), 'There should be 1 Mention Case created');
        
        List<Case_Communication__c> commentList = [SELECT Id, Activity_Content__c FROM Case_Communication__c];
        System.assertEquals(3, commentList.size(), 'There should be 3 Case Communications created for the mention');
    }
    
    @isTest
    static void testGetPostDetailsByHashTagId() {
        // Set up the mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Insert Instagram_Api_Details__c record
        Instagram_Api_Details__c apiDetails = new Instagram_Api_Details__c(
            CLIENT_ID__c = 'client_id',
            CLIENT_SECRET__c = 'client_secret',
            REDIRECT_URI__c = 'redirect_uri',
            accessToken__c = 'access_token',
            basicUrl__c = 'https://graph.facebook.com/',
            businessUserId__c = 'business_user_id',
            HashTag__c = 'test_hashtag'
        );
        insert apiDetails;
        
        // Execute the method
        Test.startTest();
        InstagramAuthHelper.getPostDetailsByHashTagId();
        Test.stopTest();
        
        // Verify results
        List<Case> caseList = [SELECT Id, Subject, Description FROM Case WHERE Origin = 'Instagram' AND Type_of_Post__c = 'HashTags'];
        System.assertEquals(1, caseList.size(), 'There should be 1 Hashtag Case created');
    }
    
    @isTest
    static void testGetHashtagIdFromInsta() {
        // Set up the mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Insert Instagram_Api_Details__c record
        Instagram_Api_Details__c apiDetails = new Instagram_Api_Details__c(
            CLIENT_ID__c = 'client_id',
            CLIENT_SECRET__c = 'client_secret',
            REDIRECT_URI__c = 'redirect_uri',
            accessToken__c = 'access_token',
            basicUrl__c = 'https://graph.facebook.com/',
            businessUserId__c = 'business_user_id',
            HashTag__c = 'test_hashtag'
        );
        insert apiDetails;
        
        // Execute the method
        Test.startTest();
        String hashTagId = InstagramAuthHelper.getHashtagIdFromInsta('test_hashtag');
        Test.stopTest();
        
        // Verify result
        System.assertEquals('17841405793087221', hashTagId, 'The Hashtag ID should be 17841405793087221');
    }
}