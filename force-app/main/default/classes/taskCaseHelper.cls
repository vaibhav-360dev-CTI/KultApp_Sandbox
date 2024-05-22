public with sharing class taskCaseHelper {
    
    @AuraEnabled
    public static Boolean getTaskOfCaseBasedOnAccountId(String recId) {
        System.debug('recId===============>' + recId);
        try {
            if (recId != null) {
                String accId;
                List<Task> tskList = new List<Task>();
                Boolean isMissedCallTask = false;
                Boolean isOutBoundCallTask = false;
                List<Case> cseList = [SELECT Id, AccountId, ContactId, Origin FROM Case WHERE Id = :recId LIMIT 1];
                if (cseList.size() > 0) {
                    if (cseList[0].Origin == 'Inbound Missed Call') {
                        accId = cseList[0].AccountId;
                        if (accId != null) {
                            tskList = [SELECT Id, Subject, AccountId FROM Task WHERE AccountId = :accId ORDER BY CreatedDate ASC];
                            if (tskList.size() > 0) {
                                for (Task tsk : tskList) {
                                    if (tsk.Subject.containsIgnoreCase('Missed Call')) {
                                        isMissedCallTask = true;
                                    }
                                    if (tsk.Subject.containsIgnoreCase('Outgoing Call') && isMissedCallTask) {
                                        isOutBoundCallTask = true;
                                    }
                                    if (tsk.Subject.containsIgnoreCase('Outgoing Call') && isMissedCallTask && isOutBoundCallTask) {
                                        isOutBoundCallTask = false;
                                    }
                                }
                                return isOutBoundCallTask; // Return the final boolean value
                            } else {
                                return false; // Return false if tskList is empty
                            }
                        } else {
                            return false; // Return false if accId is null
                        }
                    } else {
                        return false; // Return false if Origin is not 'Inbound Missed Call'
                    }
                } else {
                    return false; // Return false if cseList is empty
                }
            } else {
                return false; // Return false if recId is null
            }
        } catch (Exception e) {
            System.debug('get error message ======>' + e.getMessage() + ' at line Number=========>' + e.getLineNumber());
            return false; // Return false in case of any exception
        }
    }
    
}