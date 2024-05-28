@isTest
public class InstagramMentionCreationBatchTest {
    @isTest
    static void testBatchExecution() {
        // Check if the RecordType exists
        RecordType caseRecordType;
        try {
            caseRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'Social_Media' LIMIT 1];
        } catch (System.QueryException e) {
            System.assert(false, 'RecordType "Social Media" not found.');
            return;
        }

        // Check if an Instagram_Api_Details__c record already exists
        Instagram_Api_Details__c fap;
        try {
            fap = [SELECT Id FROM Instagram_Api_Details__c LIMIT 1];
        } catch (System.QueryException e) {
            // Create and insert the Instagram_Api_Details__c record if it doesn't exist
            fap = new Instagram_Api_Details__c(
                CLIENT_ID__c = 'bccbckbcewbcje',
                CLIENT_SECRET__c = 'cbewciuewcw cweu ciw cwucw',
                REDIRECT_URI__c = 'bcewcbwecwueicwc c iwcw',
                accessToken__c = 'bxiueqbcubce ccwebcw cuew',
                basicUrl__c = 'bcwiuecewucwcuew cew cw cweuc',
                businessUserId__c = 'bcew ciwu ce ce cuec',
                next_Pagination_Post_Token__c = 'ncencencienciencnecne',
                next_Pagination_Mention_Token__c = 'uebfbbcuebcebcucbeubcuecue',
                next_pagination_hashtag_Token__c = 'jciece ci c e ce c',
                HashTag__c = 'ubcebwcubcuewcubcuewbcbew'
            );
            insert fap;
        }

        // Create and insert the Case record
        Case testCase = new Case(
            Subject = 'Test Case',
            Origin = 'Instagram',
            RecordTypeId = caseRecordType.Id,
            Brand__c = 'Hyphen',
            Post_Id__c = '17841405793087218'
        );
        insert testCase;

        // Create and insert the Case_Communication__c record
        Case_Communication__c testComment = new Case_Communication__c(
            Case__c = testCase.Id,
            Activity_Content__c = 'Test comment',
            Activity_ID__c = 'test_comment_id_123'
        );
        insert testComment;

        // Start the test, set the mock, and execute the batch
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramMentionCreationBatch batch = new InstagramMentionCreationBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Perform assertions based on the expected behavior
        // For example, you can query and assert the inserted/updated records
        List<Case_Communication__c> postComments = [SELECT Id, Activity_ID__c, Activity_Author__c FROM Case_Communication__c];
        List<Case> cases = [SELECT Id, Post_Id__c FROM Case];

    }
}