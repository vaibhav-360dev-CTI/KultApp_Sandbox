public class taskTriggerHelper {
    public static void createCaseOnCall(List<Task> taskList){
        try{
            List<Group> missedCallQueueList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, QueueRoutingConfigId, OwnerId, DoesSendEmailToMembers, DoesIncludeBosses, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp FROM Group WHERE DeveloperName = 'Missed_Call_Queue' LIMIT 1];
            Group missedCallGroup = new Group();
            if(!missedCallQueueList.isEmpty()){
                missedCallGroup = missedCallQueueList[0];
            }
            List<Case> caseToInsert = new List<Case>();
            List<Task> tasksToInsert = new List<Task>();
            for(Task taskRec : taskList){
                /* Case caseRec = new Case();
if(taskRec.Subject.containsIgnoreCase('Missed Call') && taskRec.Exotel_CTI__Call_Direction__c == 'Inbound'){
caseRec.Origin = 'Inbound Missed Call';
if(taskRec.WhatId != null){
caseRec.AccountId = taskRec.WhatId;
}else if(taskRec.WhoId != null){
caseRec.ContactId = taskRec.WhoId;
}
caseRec.Contact_Number__c = taskRec.Exotel_CTI__From__c;
caseRec.Remarks_mentioned__c = 'Missed Call From ' + String.ValueOf(taskRec.Exotel_CTI__From__c);
caseRec.Priority = 'High';
caseRec.OwnerId = missedCallGroup.Id;
caseToInsert.add(caseRec);


}/*else if(taskRec.Subject.containsIgnoreCase('Outgoing Call') && taskRec.Exotel_CTI__Call_Direction__c == 'Outbound' && taskRec.Exotel_CTI__Call_Status__c == 'completed'){
caseRec.Origin = 'Outbound Call';
if(taskRec.WhatId != null){
caseRec.AccountId = taskRec.WhatId;
}else if(taskRec.WhoId != null){
caseRec.ContactId = taskRec.WhoId;
}
caseRec.Contact_Number__c = taskRec.Exotel_CTI__To__c;
caseRec.Remarks_mentioned__c = 'Completed Outbound Call To ' + String.ValueOf(taskRec.Exotel_CTI__To__c);
caseRec.Priority = 'Medium';
caseRec.OwnerId = taskRec.OwnerId;
}else */ if(taskRec.Subject.containsIgnoreCase('Outgoing Call') && taskRec.Exotel_CTI__Call_Direction__c == 'Outbound' && (taskRec.Exotel_CTI__Call_Status__c == 'customer_unanswered' || taskRec.Exotel_CTI__Call_Status__c == 'agent_canceled')){
    System.debug('Check Outbound');
    Task newTaskRec = new Task();
    /*caseRec.Origin = 'Outbound Call';
if(taskRec.WhatId != null){
caseRec.AccountId = taskRec.WhatId;
}else if(taskRec.WhoId != null){
caseRec.ContactId = taskRec.WhoId;
}
caseRec.Contact_Number__c = taskRec.Exotel_CTI__To__c;
caseRec.Remarks_mentioned__c = 'Unanswered Outbound Call To ' + String.ValueOf(taskRec.Exotel_CTI__To__c);
caseRec.Priority = 'Medium';
caseRec.OwnerId = taskRec.OwnerId;*/
    
    newTaskRec.Subject = 'Call Customer Again at ' + String.valueOf(taskRec.Exotel_CTI__To__c);
    if(taskRec.WhatId != null){
        newTaskRec.WhatId = taskRec.WhatId;
    }else if(taskRec.WhoId != null){
        newTaskRec.WhoId = taskRec.WhoId;
    }
    newTaskRec.OwnerId = taskRec.OwnerId;
    newTaskRec.ActivityDate = System.Today();
    tasksToInsert.add(newTaskRec);
}
            }
            /* if(!caseToInsert.isEmpty()){
insert caseToInsert;
System.debug('caseToInsert==> ' + caseToInsert);
}*/
            if(!tasksToInsert.isEmpty()){
                insert tasksToInsert;
                System.debug('tasksToInsert==> ' + tasksToInsert);
            }
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }
    public static void missedCallHelper(List<Task> taskList){
        try{
            Set<Id> accountIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            List<Task> totalTasksList = new List<Task>();
            Map<Id, List<Task>> tasksByAccountId = new Map<Id, List<Task>>();
            Map<Id, List<Task>> tasksByContactId = new Map<Id, List<Task>>();
            List<Task> tasksToUpdate = new List<Task>();
            for(Task taskRec : taskList){
                if(taskRec.Subject.startsWithIgnoreCase('Missed Call')){
                    if(taskRec.WhoId != null && String.valueOf(taskRec.WhoId).startsWithIgnoreCase('003')){
                        contactIds.add(taskRec.WhoId);
                    }
                    else if(taskRec.WhatId != null && String.valueOf(taskRec.WhatId).startsWithIgnoreCase('001')){
                        accountIds.add(taskRec.WhatId);
                    }   
                }
            }
            totalTasksList = [SELECT Id, WhoId, WhatId, WhoCount, Case__c, WhatCount, Subject, ActivityDate, Status, Priority, IsHighPriority, OwnerId, Description, IsDeleted, AccountId, IsClosed, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsArchived, CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateOnly, RecurrenceEndDateOnly, RecurrenceTimeZoneSidKey, RecurrenceType, RecurrenceInterval, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, RecurrenceInstance, RecurrenceMonthOfYear, RecurrenceRegeneratedType, TaskSubtype, CompletedDateTime, Exotel_CTI__Call_Direction__c, Exotel_CTI__Call_Duration__c, Exotel_CTI__Call_Sid__c, Exotel_CTI__Call_Status__c, Exotel_CTI__End_Time__c, Exotel_CTI__From__c, Exotel_CTI__Leg1_Status__c, Exotel_CTI__Leg2_Status__c, Exotel_CTI__Recording_URL__c, Exotel_CTI__Start_Time__c, Exotel_CTI__To__c, Exotel_CTI__Virtual_Number__c, No_Of_Missed_Calls__c FROM Task WHERE (WhoId In: contactIds OR 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      WhatId IN: accountIds) AND Subject LIKE 'Missed Call %' AND Exotel_CTI__Call_Direction__c = 'Inbound' AND CreatedDate >= TODAY  ORDER BY CreatedDate ASC];
            for(Task taskRec : totalTasksList){
                if(taskRec.WhoId != null && String.valueOf(taskRec.WhoId).startsWithIgnoreCase('003')){
                    if(!tasksByContactId.containsKey(taskRec.WhoId)){
                        tasksByContactId.put(taskRec.WhoId, new List<Task> {taskRec});
                    }else{
                        tasksByContactId.get(taskRec.WhoId).add(taskRec);
                    }
                }else if(taskRec.WhatId != null && String.valueOf(taskRec.WhatId).startsWithIgnoreCase('001')){
                    if(!tasksByAccountId.containsKey(taskRec.WhatId)){
                        tasksByAccountId.put(taskRec.WhatId, new List<Task> {taskRec});
                    }else{
                        tasksByAccountId.get(taskRec.WhatId).add(taskRec);
                    }
                }
            }
            for(Id accId : accountIds){
                Decimal noOfMissedCallsOld;
                if(tasksByAccountId.containsKey(accId)){
                    noOfMissedCallsOld = tasksByAccountId.get(accId)[0].No_Of_Missed_Calls__c;
                    if(noOfMissedCallsOld == null){
                        noOfMissedCallsOld = 0;
                    }
                    if(noOfMissedCallsOld == 0 || noOfMissedCallsOld == null){
                        createCaseOnFirstMissedCall(tasksByAccountId.get(accId)[0]);
                    }
                    if(noOfMissedCallsOld >= 3){
                        createEscalationTask(tasksByAccountId.get(accId)[tasksByAccountId.get(accId).Size() - 1]);
                        Task taskRec = new Task();
                        taskRec.No_Of_Missed_Calls__c = noOfMissedCallsOld + 1;
                        taskRec.Id = tasksByAccountId.get(accId)[0].Id;
                        tasksToUpdate.add(taskRec);
                    }else{
                        Task taskRec = new Task();
                        taskRec.No_Of_Missed_Calls__c = noOfMissedCallsOld + 1;
                        taskRec.Id = tasksByAccountId.get(accId)[0].Id;
                        tasksToUpdate.add(taskRec);   
                    }
                }
            }
            for(Id conId : contactIds){
                Decimal noOfMissedCallsOld;
                if(tasksByContactId.containsKey(conId)){
                    noOfMissedCallsOld = tasksByContactId.get(conId)[0].No_Of_Missed_Calls__c;
                    if(noOfMissedCallsOld == null){
                        noOfMissedCallsOld = 0;
                    }
                    if(noOfMissedCallsOld == 0 || noOfMissedCallsOld == null){
                        createCaseOnFirstMissedCall(tasksByContactId.get(conId)[0]);
                    }
                    if(noOfMissedCallsOld >= 3){
                        createEscalationTask(tasksByContactId.get(conId)[tasksByContactId.get(conId).Size() - 1]);
                        Task taskRec = new Task();
                        taskRec.No_Of_Missed_Calls__c = noOfMissedCallsOld + 1;
                        taskRec.Id = tasksByContactId.get(conId)[0].Id;
                        tasksToUpdate.add(taskRec);  
                    }else{
                        Task taskRec = new Task();
                        taskRec.No_Of_Missed_Calls__c = noOfMissedCallsOld + 1;
                        taskRec.Id = tasksByContactId.get(conId)[0].Id;
                        tasksToUpdate.add(taskRec);   
                    }
                }
            }
            if(!tasksToUpdate.isEmpty()){
                update tasksToUpdate;
            }
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }
    
    public static void createEscalationTask(Task taskRec){
        try{
            Task newTaskrec = new Task();
            String oldSubject = taskRec.Subject;
            newTaskRec = taskRec;
            newTaskRec.Id = null;
            newTaskRec.Status = 'Open';
            newTaskRec.Priority = 'High';
            newTaskRec.Exotel_CTI__Call_Sid__c = null;
            newTaskrec.Subject = 'Escalation Task For ' + oldSubject;
            insert newTaskRec;
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }
    
    public static void createCaseOnFirstMissedCall(Task taskRec){
        try{
            List<Group> missedCallQueueList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, QueueRoutingConfigId, OwnerId, DoesSendEmailToMembers, DoesIncludeBosses, 
                                               CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp 
                                               FROM Group WHERE DeveloperName = 'Missed_Call_Queue' LIMIT 1];
            Group missedCallGroup = new Group();
            if(!missedCallQueueList.isEmpty()){
                missedCallGroup = missedCallQueueList[0];
            }
            Case caseRec = new Case();
            caseRec.Origin = 'Inbound Missed Call';
            if(taskRec.WhatId != null){
                caseRec.AccountId = taskRec.WhatId;
            }else if(taskRec.WhoId != null){
                caseRec.ContactId = taskRec.WhoId;
            }
            caseRec.Contact_Number__c = taskRec.Exotel_CTI__From__c;
            caseRec.Subject = 'Missed Call From ' + String.ValueOf(taskRec.Exotel_CTI__From__c);
            caseRec.Priority = 'High';
            caseRec.OwnerId = missedCallGroup.Id;
            insert caseRec;
            
            if(taskRec.Case__c == null){
                taskRec.Case__c = caseRec.Id;
            }
            update taskRec;
            sendingCustomNotification(taskRec.OwnerId, caseRec.Id, 'Case Created for Missed Call', 'You have missed a customer\'s call');
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }
    
    public static void resetMissedCallCounter(List<Task> taskList){
        try{
            Set<Id> accountIds = new Set<Id>();
            Set<Id> contactIds = new Set<Id>();
            List<Task> totalTasksList = new List<Task>();
            List<Task> escalationTasksList = new List<Task>();
            Map<Id, List<Task>> tasksByAccountId = new Map<Id, List<Task>>();
            Map<Id, List<Task>> tasksByContactId = new Map<Id, List<Task>>();
            Map<Id, List<Task>> tasksToCompleteByAccountId = new Map<Id, List<Task>>();
            Map<Id, List<Task>> tasksToCompleteByContactId = new Map<Id, List<Task>>();
            List<Task> tasksToUpdate = new List<Task>();
            for(Task taskRec : taskList){
                if(taskRec.Subject.startsWithIgnoreCase('Outgoing Call') || (taskRec.Subject.startsWithIgnoreCase('Incoming Call') && taskRec.Exotel_CTI__Call_Status__c == 'completed')){
                    if(taskRec.WhoId != null && String.valueOf(taskRec.WhoId).startsWithIgnoreCase('003')){
                        contactIds.add(taskRec.WhoId);
                    }
                    else if(taskRec.WhatId != null && String.valueOf(taskRec.WhatId).startsWithIgnoreCase('001')){
                        accountIds.add(taskRec.WhatId);
                    } 
                }
            }
            totalTasksList = [SELECT Id, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate, Status, Priority, IsHighPriority, OwnerId, Description, IsDeleted, AccountId, IsClosed, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsArchived, CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateOnly, RecurrenceEndDateOnly, RecurrenceTimeZoneSidKey, RecurrenceType, RecurrenceInterval, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, RecurrenceInstance, RecurrenceMonthOfYear, RecurrenceRegeneratedType, TaskSubtype, CompletedDateTime, Exotel_CTI__Call_Direction__c, Exotel_CTI__Call_Duration__c, Exotel_CTI__Call_Sid__c, Exotel_CTI__Call_Status__c, Exotel_CTI__End_Time__c, Exotel_CTI__From__c, Exotel_CTI__Leg1_Status__c, Exotel_CTI__Leg2_Status__c, Exotel_CTI__Recording_URL__c, Exotel_CTI__Start_Time__c, Exotel_CTI__To__c, Exotel_CTI__Virtual_Number__c, No_Of_Missed_Calls__c FROM Task WHERE (WhoId In: contactIds OR 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      WhatId IN: accountIds) AND Subject LIKE 'Missed Call %' AND Exotel_CTI__Call_Direction__c = 'Inbound' AND CreatedDate >= TODAY  ORDER BY CreatedDate ASC];
            escalationTasksList = [SELECT Id, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate, Status, Priority, IsHighPriority, OwnerId, Description, IsDeleted, AccountId, IsClosed, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, IsArchived, CallDurationInSeconds, CallType, CallDisposition, CallObject, ReminderDateTime, IsReminderSet, RecurrenceActivityId, IsRecurrence, RecurrenceStartDateOnly, RecurrenceEndDateOnly, RecurrenceTimeZoneSidKey, RecurrenceType, RecurrenceInterval, RecurrenceDayOfWeekMask, RecurrenceDayOfMonth, RecurrenceInstance, RecurrenceMonthOfYear, RecurrenceRegeneratedType, TaskSubtype, CompletedDateTime, Exotel_CTI__Call_Direction__c, Exotel_CTI__Call_Duration__c, Exotel_CTI__Call_Sid__c, Exotel_CTI__Call_Status__c, Exotel_CTI__End_Time__c, Exotel_CTI__From__c, Exotel_CTI__Leg1_Status__c, Exotel_CTI__Leg2_Status__c, Exotel_CTI__Recording_URL__c, Exotel_CTI__Start_Time__c, Exotel_CTI__To__c, Exotel_CTI__Virtual_Number__c, No_Of_Missed_Calls__c FROM Task WHERE (WhoId In: contactIds OR 
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           WhatId IN: accountIds) AND Subject LIKE 'Escalation %' AND CreatedDate >= TODAY  ORDER BY CreatedDate ASC];
            for(Task taskRec : totalTasksList){
                if(taskRec.WhoId != null && String.valueOf(taskRec.WhoId).startsWithIgnoreCase('003')){
                    if(!tasksByContactId.containsKey(taskRec.WhoId)){
                        tasksByContactId.put(taskRec.WhoId, new List<Task> {taskRec});
                    }else{
                        tasksByContactId.get(taskRec.WhoId).add(taskRec);
                    }
                }else if(taskRec.WhatId != null && String.valueOf(taskRec.WhatId).startsWithIgnoreCase('001')){
                    if(!tasksByAccountId.containsKey(taskRec.WhatId)){
                        tasksByAccountId.put(taskRec.WhatId, new List<Task> {taskRec});
                    }else{
                        tasksByAccountId.get(taskRec.WhatId).add(taskRec);
                    }
                }
            }
            /*for(Task taskRec : escalationTasksList){
if(taskRec.WhoId != null && String.valueOf(taskRec.WhoId).startsWithIgnoreCase('003')){
if(!tasksToCompleteByContactId.containsKey(taskRec.WhoId)){
tasksToCompleteByContactId.put(taskRec.WhoId, new List<Task> {taskRec});
}else{
tasksToCompleteByContactId.get(taskRec.WhoId).add(taskRec);
}
}else if(taskRec.WhatId != null && String.valueOf(taskRec.WhatId).startsWithIgnoreCase('001')){
if(!tasksToCompleteByAccountId.containsKey(taskRec.WhatId)){
tasksToCompleteByAccountId.put(taskRec.WhatId, new List<Task> {taskRec});
}else{
tasksToCompleteByAccountId.get(taskRec.WhatId).add(taskRec);
}
}
}*/
            for(Id accId : accountIds){
                Integer noOfMissedCalls ;
                if(tasksByAccountId.containsKey(accId)){
                    noOfMissedCalls = 0;
                    Task taskRec = new Task();
                    taskRec.No_Of_Missed_Calls__c = noOfMissedCalls;
                    taskRec.Id = tasksByAccountId.get(accId)[0].Id;
                    tasksToUpdate.add(taskRec);
                }
            }
            for(Id conId : contactIds){
                Integer noOfMissedCalls ;
                if(tasksByContactId.containsKey(conId)){
                    noOfMissedCalls = 0;
                    Task taskRec = new Task();
                    taskRec.No_Of_Missed_Calls__c = noOfMissedCalls;
                    taskRec.Id = tasksByContactId.get(conId)[0].Id;
                    tasksToUpdate.add(taskRec);
                }
            }
            if(!escalationTasksList.isEmpty()){
                for(Task taskRec : escalationTasksList){
                    taskRec.Status = 'Completed';
                    tasksToUpdate.add(taskRec);
                }
            }
            if(!tasksToUpdate.isEmpty()){
                update tasksToUpdate;
            }
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }
    
    public static void sendingCustomNotification(String OwnerId, String recId, String notificationTitle, String notificationBody){
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Refund_Team_Member'];                                                                       
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(notificationTitle);
        notification.setBody(notificationBody);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(recId);                         
        Set<String> addressee = new Set<String>();
        addressee.add(OwnerId);                         
        try {
            notification.send(addressee);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static taskWithCaseWrappper tagCaseOnTask(String recId){
        try {
            System.debug('recId=========>'+recId);
            List<Task> tasList = new List<Task>();
            List<Task> AlltaskList = new List<Task>();
            List<Task> singleTaskList = new List<Task>();
            String caseId;
            Date createDate;
            taskWithCaseWrappper wrap = new taskWithCaseWrappper();
            if (recId != null) {
                System.debug('recId=================>'+recId);
                singleTaskList = [SELECT Id, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate,Case__c,Case__r.CaseNumber,CreatedDate,Exotel_CTI__From__c,Exotel_CTI__Call_Direction__c,Exotel_CTI__To__c,Exotel_CTI__Start_Time__c FROM Task Where  Id =: recId];
                
                wrap.CurrTaskList = singleTaskList;
                if (!singleTaskList.isEmpty() && singleTaskList[0].Case__c != null) {
                    System.debug('Inside singleTaskList=========>'+singleTaskList);
                    createDate = Date.ValueOf(singleTaskList[0].CreatedDate);
                    tasList = [SELECT Id, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate,Case__c,Case__r.CaseNumber,CreatedDate,Exotel_CTI__From__c,Exotel_CTI__Call_Direction__c,Exotel_CTI__To__c,Exotel_CTI__Start_Time__c FROM Task Where  Day_Only(CreatedDate) =: createDate 
                               AND Case__c = null AND  Exotel_CTI__Call_Direction__c != null ORDER BY CreatedDate ASC];
                    
                    if(!tasList.isEmpty()){
                        for(Task ts : tasList){
                            if(ts.Id != singleTaskList[0].Id){
                                AlltaskList.add(ts);
                            }
                        }
                    }
                    if(AlltaskList.Size()>0){
                        wrap.taskList = AlltaskList;
                    }
                    
                    
                    
                }
                if(wrap != null){
                    return wrap;
                }else{
                    return null;
                }
            } else {
                return null;
            }
        } catch (Exception e) {
            System.debug('Problem sending notification=====>' + e.getMessage() + 'at Line Number====>' + e.getLineNumber());
        }
        return null;
    }
    
    public class taskWithCaseWrappper{
        @AuraEnabled
        public List<Task> taskList{get; set;}
        
        @AuraEnabled
        public List<Task> CurrTaskList{get; set;}
    }
    
    
    @AuraEnabled
    public static taskWrappper getAllCasesTasksAndCurrentTask(String recId){
        try {
            List<Task> tskList = new List<Task>();
            List<Task> taskList = new List<Task>();
            List<Task> AlltaskList = new List<Task>();
            List<Case>  cseList = new List<Case>();
            taskWrappper wrap = new taskWrappper();
            Date createDate;
            Id accId;
            if(recId != null){
                tskList = [SELECT Id, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate,Case__c,Case__r.CaseNumber,AccountId,CreatedDate,Exotel_CTI__From__c,Exotel_CTI__To__c,Exotel_CTI__Start_Time__c,Exotel_CTI__Call_Direction__c FROM Task Where  Id =: recId AND Case__c = null];
                System.debug('tskList == >'+tskList);
                if(!tskList.isEmpty()){
                    createDate = Date.ValueOf(tskList[0].CreatedDate);
                    if(tskList[0].AccountId != null){
                        accId = tskList[0].AccountId;
                    }
                    
                    wrap.CurrentTaskList = tskList;
                    System.debug('tskList == >'+tskList);
                    
                    cseList = [SELECT Id,CaseNumber,CreatedDate,Origin,AccountId From Case Where AccountId =: accId];
                    if(cseList.Size()>0){
                        wrap.caseList = cseList;
                    }
                    System.debug('cseList == >'+cseList);
                    
                    taskList  = [SELECT Id, WhoId, WhatId, WhoCount, WhatCount,AccountId, Subject, ActivityDate,Case__c,Case__r.CaseNumber,CreatedDate,Exotel_CTI__From__c,Exotel_CTI__To__c,Exotel_CTI__Start_Time__c,Exotel_CTI__Call_Direction__c FROM Task WHERE Case__c = null AND Day_Only(CreatedDate) =: createDate AND Exotel_CTI__Call_Direction__c != null];
                    System.debug('taskList == >'+taskList);
                    
                    if(taskList.Size()>0){
                        for(Task ts : taskList){
                            if(ts.Id != tskList[0].Id){
                                AlltaskList.add(ts);
                            }
                        }
                        wrap.tuskList = taskList;
                    }
                }
                if(wrap != null){
                    System.debug('wrap == >'+wrap);
                    return wrap;
                }
                else{
                    return null;
                }
            }
        } catch (Exception e) {
            System.debug('Problem sending notification=====>' + e.getMessage() + 'at Line Number====>' + e.getLineNumber());
        }
        return null;
    }
    
    public class taskWrappper{
        @AuraEnabled
        public List<Task> tuskList{get; set;}
        
        @AuraEnabled
        public List<Task> CurrentTaskList{get; set;}
        
        @AuraEnabled
        public List<Case> caseList {get; set;}
    }
    
    @AuraEnabled
    public static String taggedCase(String jsonData) {
        System.debug('jsonData ============>' + jsonData);
        try {
            
            
            if (jsonData != null) { 
                
                String TaskId;
                String CaseId;
                String relatedTaskIdList;
                List<String> stringList = new List<String>();
                List<String> CurrentstringList = new List<String>();
                List<Task> currentTasks = new List<Task>();
                List<Task> AllTaskRelatedToCurrentTask = new List<Task>();
                List<Task> AllTaskRelatedToCurrentTaskWithNoCase = new List<Task>();
                List<Task> tskList = new List<Task>();
                String CurrentTaskCaseId;
                
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
                if(String.valueOf(jsonMap.get('TaskId')) !=null){
                    //TaskId = String.valueOf(jsonMap.get('TaskId'));
                    TaskId = String.valueOf(jsonMap.get('TaskId'));
                    CurrentstringList = TaskId.substring(1, TaskId.length() - 1).split(', ');
                    System.debug('TaskId ============>' + TaskId);
                    System.debug('CurrentstringList ============>' + CurrentstringList);
                }
                if(String.valueOf(jsonMap.get('CaseId')) !=null){
                    CaseId = String.valueOf(jsonMap.get('CaseId'));
                    System.debug('CaseId ============>' + CaseId);
                }
                if(String.valueOf(jsonMap.get('relatedTaskId')) != null){
                    relatedTaskIdList = String.valueOf(jsonMap.get('relatedTaskId'));
                    stringList = relatedTaskIdList.substring(1, relatedTaskIdList.length() - 1).split(', ');
                    System.debug('stringList ============>' + stringList);
                }
                
                if(CaseId == null){
                    System.debug('Case Id Null ============>' + CaseId);
                    System.debug('TaskId 1 ============>' + TaskId);
                    // Set<Id> taskIdset = new Set<Id>();
                    // taskIdset.add(TaskId);
                    // TaskId = TaskId.replace('(', '').replace(')', '');
                    System.debug('TaskId 2 ============>' + TaskId);
                    tskList = [SELECT Id, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate,Case__c,Case__r.CaseNumber FROM Task Where Id IN:CurrentstringList];
                    System.debug('tskList ============>' + tskList);
                    if(tskList.Size()>0){
                        CurrentTaskCaseId = tskList[0].Case__c;
                    }
                    update tskList;
                    System.debug('CurrentTaskCaseId ============>' + CurrentTaskCaseId);
                    // task With Cases
                    AllTaskRelatedToCurrentTask = [SELECT Id, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate,Case__c,Case__r.CaseNumber FROM Task Where Id IN: stringList];
                    
                    System.debug('AllTaskRelatedToCurrentTask ============>' + AllTaskRelatedToCurrentTask);
                    if(AllTaskRelatedToCurrentTask.Size()>0){
                        for(Task ts : AllTaskRelatedToCurrentTask){
                            if(CurrentTaskCaseId != null){
                                ts.Case__c = CurrentTaskCaseId;
                            }
                        }
                    }
                    
                    update AllTaskRelatedToCurrentTask;
                    System.debug('AllTaskRelatedToCurrentTask ============>' + AllTaskRelatedToCurrentTask);
                }else if(CaseId != null){
                    System.debug('Case Id Not Null ============>' + CaseId);
                    // task With No Cases
                    TaskId = TaskId.replace('(', '').replace(')', '');
                    System.debug('Task Id Not Null ============>' + TaskId);
                    CaseId = CaseId.replace('(', '').replace(')', '');
                    System.debug('Case Id Not Null ============>' + CaseId);
                    tskList = [SELECT Id, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate,Case__c,Case__r.CaseNumber FROM Task Where Id IN: CurrentstringList];
                    System.debug('tskList ============>' + tskList);
                    
                    if(tskList.Size()>0){
                        for(Task ts : tskList){
                            ts.Case__c = CaseId;
                        }
                    }
                    
                    update tskList;
                    System.debug('tskList ============>' + tskList);
                    
                    AllTaskRelatedToCurrentTaskWithNoCase = [SELECT Id, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate,
                                                             Case__c,Case__r.CaseNumber FROM Task Where Id IN: stringList];
                    
                    System.debug('AllTaskRelatedToCurrentTaskWithNoCase ============>' + AllTaskRelatedToCurrentTaskWithNoCase);
                    
                    if(AllTaskRelatedToCurrentTaskWithNoCase.Size()>0){
                        for(Task ts : AllTaskRelatedToCurrentTaskWithNoCase){
                            ts.Case__c = CaseId;
                        }
                        update AllTaskRelatedToCurrentTaskWithNoCase;
                    }
                    System.debug('AllTaskRelatedToCurrentTaskWithNoCase ============>' + AllTaskRelatedToCurrentTaskWithNoCase);
                }
                
                
                return 'SUCCESS';
                
            }else{
                return null;
            }
            
        } catch (Exception e) {
            System.debug('Problem processing JSON data: ' + e.getMessage() + ' at Line Number: ' + e.getLineNumber());
        }
        return null;
    }
    
}