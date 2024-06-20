public class contentDocumentLinkTriggerHelper {
    public static void updateCaseLastResponseTime(List<ContentDocumentLink> attList){
        try{
            Set<id> caseIds = new Set<id>();
            for(ContentDocumentLink attRec : attList){
                System.debug('attRec=> ' + attRec);
                System.debug('attRec.parentId=> ' + attRec.LinkedEntityId);
                if(String.ValueOf(attRec.LinkedEntityId).startsWithIgnoreCase('500')){
                    caseIds.add(attRec.LinkedEntityId);
                }
            }
            List<case> caseListToUpdate = [SELECT id, Last_Response__c FROM Case WHERE Id IN: caseIds];
            for(Case csRec : caseListToUpdate){
                csRec.Last_Response__c = System.Now();
            }
            update caseListToUpdate;
        }catch(exception e){
            System.debug('Error:: ' + e.getMessage() + ' at Line Number:: ' + e.getLineNumber());
        }
    }
}