@isTest
public class taskTriggerHelperTest {

    @testSetup
    static void setupData() {
        Group missedCallGroup = new Group(DeveloperName = 'Missed_Call_Queue', Name = 'Missed Call Queue');
        insert missedCallGroup;

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;
        
        Task task1 = new Task(Subject = 'Missed Call', WhoId = con.Id, WhatId = acc.Id, Exotel_CTI__Call_Direction__c = 'Inbound', Exotel_CTI__From__c = '1234567890');
        Task task2 = new Task(Subject = 'Outgoing Call', WhoId = con.Id, WhatId = acc.Id, Exotel_CTI__Call_Direction__c = 'Outbound', Exotel_CTI__Call_Status__c = 'customer_unanswered', Exotel_CTI__To__c = '0987654321');
        Task task3 = new Task(Subject = 'Outgoing Call', WhoId = con.Id, WhatId = acc.Id, Exotel_CTI__Call_Direction__c = 'Outbound', Exotel_CTI__Call_Status__c = 'completed', Exotel_CTI__To__c = '1122334455');
        insert new List<Task>{task1, task2, task3};
    }

    @isTest
    static void testCreateCaseOnCall() {
        List<Task> tasks = [SELECT Id, Subject, WhoId, WhatId, Exotel_CTI__Call_Direction__c, Exotel_CTI__From__c, Exotel_CTI__To__c, Exotel_CTI__Call_Status__c FROM Task];

        Test.startTest();
        taskTriggerHelper.createCaseOnCall(tasks);
        Test.stopTest();

    }

    @isTest
    static void testMissedCallHelper() {
        //List<Task> tasks = [SELECT Id, Subject, WhoId, WhatId FROM Task WHERE Subject LIKE 'Missed Call%'];
        List<Task> taskList = new List<Task>();
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert con;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;
        
        Task testTasks = new Task(WhatId = testAccount.Id,Status='Open',Priority = 'High',Exotel_CTI__Call_Sid__c = null,Subject = 'Missed Call %',Exotel_CTI__Call_Status__c = 'completed',Exotel_CTI__Call_Direction__c = 'Inbound');
        insert testTasks;
        taskList.add(testTasks);

        Test.startTest();
        taskTriggerHelper.missedCallHelper(taskList);
        Test.stopTest();

    }
    
    @isTest
    static void testMissedCallHelper1() {
        //List<Task> tasks = [SELECT Id, Subject, WhoId, WhatId FROM Task WHERE Subject LIKE 'Missed Call%'];
        List<Task> taskList = new List<Task>();
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert con;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;
        
        Task testTasks = new Task(WhoId = con.Id,Status='Open',Priority = 'High',Exotel_CTI__Call_Sid__c = null,Subject = 'Missed Call %',Exotel_CTI__Call_Status__c = 'completed',Exotel_CTI__Call_Direction__c = 'Inbound');
        insert testTasks;
        taskList.add(testTasks);

        Test.startTest();
        taskTriggerHelper.missedCallHelper(taskList);
        Test.stopTest();

    }
    
    @isTest
    static void testMissedCallHelper2() {
        List<Task> taskList = new List<Task>();
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert con;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;
        
        Task testTasks = new Task(WhoId = con.Id,Status='Open',Priority = 'High',Exotel_CTI__Call_Sid__c = null,Subject = 'Missed Call %',Exotel_CTI__Call_Status__c = 'completed',Exotel_CTI__Call_Direction__c = 'Inbound',No_Of_Missed_Calls__c=3);
        insert testTasks;
        taskList.add(testTasks);

        Test.startTest();
        taskTriggerHelper.missedCallHelper(taskList);
        Test.stopTest();

    }

    @isTest
    static void testCreateEscalationTask() {
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;
        
        Task testTasks = new Task(WhatId = testCase.Id,Status='Open',Priority = 'High',Exotel_CTI__Call_Sid__c = null,Subject = 'Escalation Task For ');
        insert testTasks;

        Test.startTest();
        taskTriggerHelper.createEscalationTask(testTasks);
        Test.stopTest();

    }

    @isTest
    static void testCreateCaseOnFirstMissedCall() {
        Task task = [SELECT Id, Subject, WhoId, WhatId, Exotel_CTI__From__c FROM Task WHERE Subject LIKE 'Missed Call%' LIMIT 1];

        Test.startTest();
        taskTriggerHelper.createCaseOnFirstMissedCall(task);
        Test.stopTest();

        // Verify that a case was created
        Case createdCase = [SELECT Id, Subject, Origin FROM Case WHERE Subject LIKE 'Missed Call From%' LIMIT 1];
        System.assertEquals('Inbound Missed Call', createdCase.Origin);
    }

    @isTest
    static void testResetMissedCallCounter() {
        //List<Task> tasks = [SELECT Id, Subject, WhoId, WhatId, Exotel_CTI__Call_Status__c FROM Task WHERE Subject LIKE 'Outgoing Call%' OR (Subject LIKE 'Incoming Call%' AND Exotel_CTI__Call_Status__c = 'completed')];
        List<Task> taskList = new List<Task>();
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert con;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;
        
        Task testTasks = new Task(WhatId = testAccount.Id,Status='Open',Priority = 'High',Exotel_CTI__Call_Sid__c = null,Subject = 'Missed Call %',Exotel_CTI__Call_Status__c = 'completed',Exotel_CTI__Call_Direction__c = 'Inbound');
        insert testTasks;
        taskList.add(testTasks);

        Test.startTest();
        taskTriggerHelper.resetMissedCallCounter(taskList);
        Test.stopTest();

    }
    
    @isTest
    static void testResetMissedCallCounter1() {
        //List<Task> tasks = [SELECT Id, Subject, WhoId, WhatId, Exotel_CTI__Call_Status__c FROM Task WHERE Subject LIKE 'Outgoing Call%' OR (Subject LIKE 'Incoming Call%' AND Exotel_CTI__Call_Status__c = 'completed')];
        List<Task> taskList = new List<Task>();
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert con;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;
        
        Task testTasks = new Task(WhoId = con.Id,Status='Open',Priority = 'High',Exotel_CTI__Call_Sid__c = null,Subject = 'Escalation %',Exotel_CTI__Call_Status__c = 'completed',Exotel_CTI__Call_Direction__c = 'Inbound');
        insert testTasks;
        taskList.add(testTasks);

        Test.startTest();
        taskTriggerHelper.resetMissedCallCounter(taskList);
        Test.stopTest();

    }

    @isTest
    static void testSendingCustomNotification() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Task task = [SELECT Id, OwnerId FROM Task LIMIT 1];
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;

        Test.startTest();
        taskTriggerHelper.sendingCustomNotification(task.OwnerId, testCase.Id, 'Test Notification', 'This is a test notification');
        Test.stopTest();
    }

    @isTest
    static void testTagCaseOnTask() {
       // Task task = [SELECT Id FROM Task LIMIT 1];
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;
        
        Task testTasks = new Task(WhatId = testAccount.Id,Status='Open',Priority = 'High',Exotel_CTI__Call_Sid__c = null,Subject = 'Incoming Call%',Exotel_CTI__Call_Status__c = 'completed');
        insert testTasks;

        Test.startTest();
        taskTriggerHelper.tagCaseOnTask(testTasks.Id);
        Test.stopTest();

        // Verify that the wrapper is not null
        taskTriggerHelper.taskWithCaseWrappper wrap = taskTriggerHelper.tagCaseOnTask(testTasks.Id);
        System.assertNotEquals(null, wrap);
    }

    @isTest
    static void testGetAllCasesTasksAndCurrentTask() {
        Task task = [SELECT Id FROM Task LIMIT 1];

        Test.startTest();
        taskTriggerHelper.getAllCasesTasksAndCurrentTask(task.Id);
        Test.stopTest();

        // Verify that the wrapper is not null
        taskTriggerHelper.taskWrappper wrap = taskTriggerHelper.getAllCasesTasksAndCurrentTask(task.Id);
        System.assertNotEquals(null, wrap);
    }

    @isTest
    static void testTaggedCase() {
        // Prepare JSON data
        String jsonData = '{"TaskId":"[\'' + [SELECT Id FROM Task LIMIT 1][0].Id + '\']","CaseId":null,"relatedTaskId":"[\'' + [SELECT Id FROM Task LIMIT 1][0].Id + '\']"}';

        Test.startTest();
        String result = taskTriggerHelper.taggedCase(jsonData);
        Test.stopTest();

        // Verify the result
        System.assertEquals('SUCCESS', result);
    }

    /*@isTest
    static void testCreateCaseOnCallWithNoMissedCallQueue() {
        // Delete the missed call queue group
        delete [SELECT Id FROM Group WHERE DeveloperName = 'Missed_Call_Queue'];

        List<Task> tasks = [SELECT Id, Subject, WhoId, WhatId, Exotel_CTI__Call_Direction__c, Exotel_CTI__From__c, Exotel_CTI__To__c, Exotel_CTI__Call_Status__c FROM Task];

        Test.startTest();
        taskTriggerHelper.createCaseOnCall(tasks);
        Test.stopTest();

    }*/

    @isTest
    static void testMissedCallHelperWithNoTasks() {
        List<Task> tasks = new List<Task>();

        Test.startTest();
        taskTriggerHelper.missedCallHelper(tasks);
        Test.stopTest();

        // Verify no task was updated
        Integer countTasks = [SELECT COUNT() FROM Task WHERE No_Of_Missed_Calls__c != null];
        System.assertEquals(0, countTasks);
    }

    @isTest
    static void testCreateCaseOnCallWithOutboundCall() {
        List<Task> tasks = [SELECT Id, Subject, WhoId, WhatId, Exotel_CTI__Call_Direction__c, Exotel_CTI__From__c, Exotel_CTI__To__c, Exotel_CTI__Call_Status__c FROM Task WHERE Subject LIKE 'Outgoing Call%' AND Exotel_CTI__Call_Status__c = 'completed'];

        Test.startTest();
        taskTriggerHelper.createCaseOnCall(tasks);
        Test.stopTest();

        // Verify no case was created for outbound completed call
        Integer countCases = [SELECT COUNT() FROM Case];
        System.assertEquals(0, countCases);
    }

    @isTest
    static void testCreateCaseOnFirstMissedCallWithNoGroup() {
         Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
         Case testCase = new Case(
            Subject = 'Test Case',
            AccountId = testAccount.Id,
            Status = 'New'
        );
        insert testCase;

        Task testTasks = new Task(WhatId = testCase.Id);
        insert testTasks;
        
        Test.startTest();
        taskTriggerHelper.createCaseOnFirstMissedCall(testTasks);
        Test.stopTest();

    }
}