@IsTest
private class FacebookApiResponseTest {

    @IsTest
    static void testFacebookApiResponseParsing() {
        // Create mock data for testing
        FacebookApiResponse.CommentMedia commentMedia = new FacebookApiResponse.CommentMedia();
        commentMedia.id = 'media_id_1';

        FacebookApiResponse.ReplyData replyData = new FacebookApiResponse.ReplyData();
        replyData.text = 'This is a reply';
        replyData.username = 'user_reply';
        replyData.id = 'reply_id_1';
        replyData.timestamp = '2024-05-26T00:00:00+0000';

        FacebookApiResponse.RepliesWrapper repliesWrapper = new FacebookApiResponse.RepliesWrapper();
        repliesWrapper.data = new List<FacebookApiResponse.ReplyData>{replyData};

        FacebookApiResponse.CommentData commentData = new FacebookApiResponse.CommentData();
        commentData.id = 'comment_id_1';
        commentData.like_count = 5;
        commentData.username = 'user_comment';
        commentData.user = 'User 1';
        commentData.media = commentMedia;
        commentData.replies = repliesWrapper;
        commentData.text = 'This is a comment';
        commentData.timestamp = '2024-05-26T00:00:00+0000';

        FacebookApiResponse.CommentsWrapper commentsWrapper = new FacebookApiResponse.CommentsWrapper();
        commentsWrapper.data = new List<FacebookApiResponse.CommentData>{commentData};

        FacebookApiResponse.DataWrapper dataWrapper = new FacebookApiResponse.DataWrapper();
        dataWrapper.media_url = 'http://example.com/media.jpg';
        dataWrapper.comments_count = 10;
        dataWrapper.permalink = 'http://example.com/permalink';
        dataWrapper.caption = 'This is a caption';
        dataWrapper.media_type = 'image';
        dataWrapper.shortcode = 'shortcode_1';
        dataWrapper.timestamp = '2024-05-26T00:00:00+0000';
        dataWrapper.username = 'user_1';
        dataWrapper.comments = commentsWrapper;
        dataWrapper.id = 'data_id_1';

        FacebookApiResponse.CursorsWrapper cursorsWrapper = new FacebookApiResponse.CursorsWrapper();
        cursorsWrapper.before = 'before_cursor';
        cursorsWrapper.after = 'after_cursor';

        FacebookApiResponse.PagingWrapper pagingWrapper = new FacebookApiResponse.PagingWrapper();
        pagingWrapper.cursors = cursorsWrapper;

        FacebookApiResponse facebookApiResponse = new FacebookApiResponse();
        facebookApiResponse.data = new List<FacebookApiResponse.DataWrapper>{dataWrapper};
        facebookApiResponse.paging = pagingWrapper;

        // Assertions to verify the parsing
        System.assertNotEquals(null, facebookApiResponse.data);
        System.assertEquals(1, facebookApiResponse.data.size());
        System.assertEquals('http://example.com/media.jpg', facebookApiResponse.data[0].media_url);
        System.assertEquals(10, facebookApiResponse.data[0].comments_count);
        System.assertEquals('http://example.com/permalink', facebookApiResponse.data[0].permalink);
        System.assertEquals('This is a caption', facebookApiResponse.data[0].caption);
        System.assertEquals('image', facebookApiResponse.data[0].media_type);
        System.assertEquals('shortcode_1', facebookApiResponse.data[0].shortcode);
        System.assertEquals('2024-05-26T00:00:00+0000', facebookApiResponse.data[0].timestamp);
        System.assertEquals('user_1', facebookApiResponse.data[0].username);
        System.assertNotEquals(null, facebookApiResponse.data[0].comments);
        System.assertEquals(1, facebookApiResponse.data[0].comments.data.size());
        System.assertEquals('comment_id_1', facebookApiResponse.data[0].comments.data[0].id);
        System.assertEquals(5, facebookApiResponse.data[0].comments.data[0].like_count);
        System.assertEquals('user_comment', facebookApiResponse.data[0].comments.data[0].username);
        System.assertEquals('User 1', facebookApiResponse.data[0].comments.data[0].user);
        System.assertNotEquals(null, facebookApiResponse.data[0].comments.data[0].media);
        System.assertEquals('media_id_1', facebookApiResponse.data[0].comments.data[0].media.id);
        System.assertNotEquals(null, facebookApiResponse.data[0].comments.data[0].replies);
        System.assertEquals(1, facebookApiResponse.data[0].comments.data[0].replies.data.size());
        System.assertEquals('reply_id_1', facebookApiResponse.data[0].comments.data[0].replies.data[0].id);
        System.assertEquals('This is a reply', facebookApiResponse.data[0].comments.data[0].replies.data[0].text);
        System.assertEquals('user_reply', facebookApiResponse.data[0].comments.data[0].replies.data[0].username);
        System.assertEquals('2024-05-26T00:00:00+0000', facebookApiResponse.data[0].comments.data[0].replies.data[0].timestamp);
        System.assertNotEquals(null, facebookApiResponse.paging);
        System.assertNotEquals(null, facebookApiResponse.paging.cursors);
        System.assertEquals('before_cursor', facebookApiResponse.paging.cursors.before);
        System.assertEquals('after_cursor', facebookApiResponse.paging.cursors.after);
    }
}