trigger FollowUpTrigger on Follow_Up_Request__c (before insert, before Update) {
    if(trigger.isInsert && trigger.isBefore){
        followUpTriggerHelper.updateCaseOnFollowUpCreation(trigger.new);
    }
    if(trigger.isUpdate && trigger.isBefore){
        followUpTriggerHelper.updateCaseOnFollowUpUpdation(trigger.new);
    }
}