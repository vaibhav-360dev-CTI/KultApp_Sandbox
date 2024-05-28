trigger FollowUpTrigger on Follow_Up_Request__c (before insert, before Update,after Insert, after update) {
    if(trigger.isInsert && trigger.isBefore){
        followUpTriggerHelper.updateCaseOnFollowUpCreation(trigger.new);
    }
    if(trigger.isUpdate && trigger.isBefore){
        followUpTriggerHelper.updateCaseOnFollowUpUpdation(trigger.new);

        
    }
    if((trigger.isUpdate && trigger.isBefore) || (trigger.isInsert && trigger.isBefore)){
        followUpTriggerHelper.OnInsertOrUpdateLastResponseOnCase(trigger.new);
        
    }
    if((trigger.isUpdate && trigger.isAfter) || (trigger.isInsert && trigger.isAfter)){
       // followUpTriggerHelper.OnInsertOrUpdate(trigger.new);
    }
}