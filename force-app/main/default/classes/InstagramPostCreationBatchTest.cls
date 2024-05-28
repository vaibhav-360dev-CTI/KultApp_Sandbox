@isTest
public class InstagramPostCreationBatchTest {
    @isTest
    static void testBatchExecution() {
        RecordType caseRecordType;
        try {
            caseRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'Social_Media' LIMIT 1];
        } catch (Exception e) {
            System.debug('RecordType not found: ' + e.getMessage());
            return;
        }

        // Create Instagram API details record
        Instagram_Api_Details__c fap = new Instagram_Api_Details__c();
        fap.CLIENT_ID__c = 'bccbckbcewbcje';
        fap.CLIENT_SECRET__c = 'cbewciuewcw cweu ciw cwucw';
        fap.REDIRECT_URI__c = 'bcewcbwecwueicwc c iwcw';
        fap.accessToken__c = 'bxiueqbcubce ccwebcw cuew';
        fap.basicUrl__c = 'bcwiuecewucwcuew cew cw cweuc';
        fap.businessUserId__c = 'bcew ciwu ce ce cuec';
        fap.next_Pagination_Post_Token__c = 'ncencencienciencnecne';
        fap.next_Pagination_Mention_Token__c = 'uebfbbcuebcebcucbeubcuecue';
        fap.next_pagination_hashtag_Token__c = 'jciece ci c e ce c';
        fap.HashTag__c = 'ubcebwcubcuewcubcuewbcbew'; 
        insert fap;
        
        // Create a test Case record
        Case testCase = new Case(
            Subject = 'Test Case',
            Origin = 'Instagram',
            RecordTypeId = caseRecordType.Id,
            Brand__c = 'Hyphen',
            Post_Id__c = '17841405793087218'
        );
        insert testCase;
        
        // Create a test Case_Communication__c record
        Case_Communication__c testComment = new Case_Communication__c(
            Case__c = testCase.Id,
            Activity_Content__c = 'Test comment',
            Activity_ID__c = 'test_comment_id_123'
        );
        insert testComment;
        
        // Start the batch process
        Test.startTest();
        InstagramPostCreationBatch batch = new InstagramPostCreationBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Perform assertions to verify the expected results
        // For example, check if the inserted Case records and Case_Communication__c records are as expected
    }
}