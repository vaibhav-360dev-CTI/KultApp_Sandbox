@isTest
public class ScheduleInstagramBatchForPostsTest {
	@istest
    public static void  schedulePosts() {
        Test.StartTest();
        ScheduleInstagramBatchForPosts sh1 = new ScheduleInstagramBatchForPosts();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}