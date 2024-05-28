trigger TriggerOnCase on Case (before insert, before update, after update, after insert) {   
    string socialRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Social Media').getRecordTypeId();
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Case> caseListForAfterInsertAndUpdate = new List<case>();
        for(Case caseRec : trigger.new){
            if(caseRec.RecordTypeId != socialRecordTypeId){
                caseListForAfterInsertAndUpdate.add(caseRec);
            }
        }
        if(!caseListForAfterInsertAndUpdate.isEmpty()){
            caseTriggerHelper.updateUserFieldsOnReassignment(caseListForAfterInsertAndUpdate, Trigger.oldMap);   
        }
        
        if(trigger.isUpdate && trigger.isAfter){
            //CaseHelperControllers.sendEmailToUserAndNotificationToUserPincodeNotServiceable(Trigger.new,Trigger.oldMap);
            //CaseHelperControllers.sendEmailToUserAndNotificationToUserDelayInDelivery(Trigger.new,Trigger.oldMap);
            //referBackToCsTeamController.sendEmailToUserAndNotificationToUserReasonForLostInTransit(Trigger.new,Trigger.oldMap);
            //CaseHelperControllers.sendEmailToContactOwnerAndSendNotificationToOMSTeam(Trigger.new,Trigger.oldMap); 
            List<Case> caseListForAfterUpdate = new List<case>();
            for(Case caseRec : trigger.new){
                if(caseRec.RecordTypeId != socialRecordTypeId){
                    caseListForAfterUpdate.add(caseRec);
                }
            }
            if(!caseListForAfterUpdate.isEmpty()){
                caseTriggerHelper.resetTypeAndSubtypeOnRecordTypeChange(caseListForAfterUpdate, Trigger.oldMap);  
                caseTriggerHelper.resetAlreadyUtilized(caseListForAfterUpdate, Trigger.oldMap); 
            }
        }     
    }
    if(trigger.isInsert && trigger.isBefore){
        List<Case> caseListForBeforeInsert= new List<case>();
            for(Case caseRec : trigger.new){
                if(caseRec.RecordTypeId != socialRecordTypeId){
                    caseListForBeforeInsert.add(caseRec);
                }
            }
            if(!caseListForBeforeInsert.isEmpty()){
                caseTriggerHelper.modifyEmailCases(caseListForBeforeInsert);
            }
        
    }
    if(trigger.isAfter && trigger.isInsert){
        List<Case> caseListForAfterInsert= new List<case>();
            for(Case caseRec : trigger.new){
                if(caseRec.RecordTypeId != socialRecordTypeId){
                    caseListForAfterInsert.add(caseRec);
                }
            }
            if(!caseListForAfterInsert.isEmpty()){
                caseTriggerHelper.createdAffectedSKUs(caseListForAfterInsert);
            }
    }

    if((trigger.isInsert && trigger.isBefore) || (trigger.isUpdate && trigger.isBefore)){
        List<Case> caseListForBeforeInsertAndUpdate= new List<case>();
            for(Case caseRec : trigger.new){
                if(caseRec.RecordTypeId != socialRecordTypeId){
                    caseListForBeforeInsertAndUpdate.add(caseRec);
                }
            }
            if(!caseListForBeforeInsertAndUpdate.isEmpty()){
                caseTriggerHelper.handleCases(caseListForBeforeInsertAndUpdate);
        caseTriggerHelper.setHighPriorityCases(caseListForBeforeInsertAndUpdate);
            }
    }
   
}