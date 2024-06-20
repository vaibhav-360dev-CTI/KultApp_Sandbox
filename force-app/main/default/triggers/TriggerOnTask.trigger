trigger TriggerOnTask on Task (before insert, after insert, before update) {
    if(trigger.isAfter && trigger.isInsert){
        taskTriggerHelper.createCaseOnCall(trigger.new);
        taskTriggerHelper.missedCallHelper(trigger.new);
        taskTriggerHelper.resetMissedCallCounter(trigger.new);
       // taskTriggerHelper.createFeedItemAfterInsertOrUpdate(trigger.new);
    }
    if((trigger.isUpdate || trigger.isInsert) && trigger.isBefore){
       // taskTriggerHelper.changeWhatIdAndAccountId(trigger.new, trigger.oldMap);
    }
    if((trigger.isUpdate || trigger.isInsert) && trigger.isAfter){
        taskTriggerHelper.tagCaseOnWhatIdIfAccountIsNotTagged(trigger.new);
    }
}