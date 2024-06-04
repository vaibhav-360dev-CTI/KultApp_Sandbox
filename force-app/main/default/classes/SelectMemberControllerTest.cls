@isTest
public class SelectMemberControllerTest {
	@isTest
    static void testClass(){
        //SelectMemberController.dumMethod();
        Profile profile1 = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Profile profile2 = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
         User user1 = new User(
            Alias = 'test1',
            Email='test1@example.com',
            EmailEncodingKey='UTF-8',
            LastName='User1',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = profile1.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='Jhony09876@abs.com'
        );
        insert user1;
        
        User user2 = new User(
            Alias = 'test2',
            Email='test2@example.com',
            EmailEncodingKey='UTF-8',
            LastName='User2',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = profile2.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='xyz123456@iu.com'
        );
        insert user2;
        
        Test.startTest();
        Map<String, Object> result = SelectMemberController.getAllProfiles();
        Test.stopTest();
        
        Map<String, Object> profileDetails1 = (Map<String, Object>)result.get(profile1.Id);
        Map<String, Object> profileDetails2 = (Map<String, Object>)result.get(profile2.Id);
        List<Map<String, String>> users1 = (List<Map<String, String>>)profileDetails1.get('Users');
        List<Map<String, String>> users2 = (List<Map<String, String>>)profileDetails2.get('Users');
        
    }
}