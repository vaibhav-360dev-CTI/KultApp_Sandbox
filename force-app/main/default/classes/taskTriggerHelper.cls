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
                Case caseRec = new Case();
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
                }*/else if(taskRec.Subject.containsIgnoreCase('Outgoing Call') && taskRec.Exotel_CTI__Call_Direction__c == 'Outbound' && (taskRec.Exotel_CTI__Call_Status__c == 'customer_unanswered' || taskRec.Exotel_CTI__Call_Status__c == 'agent_canceled')){
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
            if(!caseToInsert.isEmpty()){
                insert caseToInsert;
                System.debug('caseToInsert==> ' + caseToInsert);
            }
            if(!tasksToInsert.isEmpty()){
                insert tasksToInsert;
                System.debug('tasksToInsert==> ' + tasksToInsert);
            }
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }
}