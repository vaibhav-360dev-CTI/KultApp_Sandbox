@isTest
public class ScheduleInstagramBatchForMentionsTest {
	@isTest
    static void testClass(){
         Test.startTest();
        
        // Schedule the class
        String jobId = System.schedule('Test Schedule Instagram Mentions Batch', '0 0 12 * * ?', new ScheduleInstagramBatchForMentions());
        
        // Directly execute the schedulable class
        ScheduleInstagramBatchForMentions schedulableInstance = new ScheduleInstagramBatchForMentions();
        schedulableInstance.execute(null);
        
        Test.stopTest();
        
        // Verify that the batch job was executed
        List<AsyncApexJob> jobs = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, jobs.size(), 'One batch job should have been executed');
      //  ScheduleInstagramBatchForMentions.dumMethod();
    }
}