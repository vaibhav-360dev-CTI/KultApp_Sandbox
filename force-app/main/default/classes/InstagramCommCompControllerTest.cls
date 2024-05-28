@isTest
public class InstagramCommCompControllerTest {
    
    @IsTest
    public static  void getRepliesDetails(){  
        Case caseRec = new Case();
        caseRec.Post_Id__c = '17841405793087218';
        caseRec.Brand__c='Hyphen';
        caseRec.Origin = 'Instagram';
        caseRec.Post_Case_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=18005859431113949, text=WRITE YOUR COMMENTS.. @letshyphen ?, timestamp=2024-02-06T15:27:36+0000, username=letshyphen], ReplyData:[id=17851844472131983, text=@letshyphen WRITE YOUR COMMENTS.. ?, timestamp=2024-02-06T15:11:44+0000, username=letshyphen], ReplyData:[id=18124096786335712, text=@sweetlife.2003 Yes, absolutely! We have our RETINAL RESET SERUM - BEGINNER FRIENDLY crafted just for you. Order Now!💜, timestamp=2024-02-05T13:37:13+0000, username=letshyphen], ReplyData:[id=18051495988562719, text=@sweetlife.2003 yes you can, timestamp=2024-02-05T12:46:25+0000, username=kiyarapershadi])]';
        insert caserec;
        
        InstagramCommCompController.getRepliesDetails(caserec.Id);
        InstagramCommCompController.getUpdatedComments(caserec.Id);
        InstagramCommCompController.getMediaIdFromCommentId(caserec.Post_Id__c,caserec);
        InstagramCommCompController.getMediaDetailsFromMediaId('17841405793087218',caserec);
    }
    @IsTest
    public static  void getRepliesDetailsv2(){  
        Case caseRec = new Case();
        caseRec.Post_Id__c = '17841405793087218';
        caseRec.Brand__c='Hyphen';
        caseRec.Origin = 'Instagram';
        //caseRec.Post_Case_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=18005859431113949, text=WRITE YOUR COMMENTS.. @letshyphen ?, timestamp=2024-02-06T15:27:36+0000, username=letshyphen], ReplyData:[id=17851844472131983, text=@letshyphen WRITE YOUR COMMENTS.. ?, timestamp=2024-02-06T15:11:44+0000, username=letshyphen], ReplyData:[id=18124096786335712, text=@sweetlife.2003 Yes, absolutely! We have our RETINAL RESET SERUM - BEGINNER FRIENDLY crafted just for you. Order Now!💜, timestamp=2024-02-05T13:37:13+0000, username=letshyphen], ReplyData:[id=18051495988562719, text=@sweetlife.2003 yes you can, timestamp=2024-02-05T12:46:25+0000, username=kiyarapershadi])]';
        insert caserec;
        
        InstagramCommCompController.getRepliesDetails(caserec.Id);
        
    }
    @IsTest
    public static void replyToCommentOnInsta(){  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramCommCompController.replyToCommentOnInsta('17841405793087218','All is gooood');
        Test.stopTest();
    }
}