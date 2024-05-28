trigger caseProgressDetailTrigger on Case_Progress_Detail__c (before insert, after insert) {
    if(trigger.isInsert && trigger.isAfter){
        //caseProgressDetailTriggerHelper.sendNotificationToCSTeam(trigger.new);
        caseProgressDetailTriggerHelper.UpdateRefundWHStatusHelper(trigger.new);
    }   
}