trigger TriggerOnTask on Task (before insert, after insert) {
    if(trigger.isAfter && trigger.isInsert){
        taskTriggerHelper.createCaseOnCall(trigger.new);
        taskTriggerHelper.missedCallHelper(trigger.new);
        taskTriggerHelper.resetMissedCallCounter(trigger.new);
    }
}