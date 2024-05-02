public class followUpTriggerHelper {
    public static void updateCaseOnFollowUpCreation(List<Follow_Up_Request__c> followUpRequestList){
        Set<Id> setOfCaseId = new Set<Id>();
        for(Follow_Up_Request__c fur :followUpRequestList){
            if(fur.Case__c != null){
                setOfCaseId.add(fur.Case__c);
            }
        }
        
        List<Case> cseList = [SELECT Id,isFollowUp__c From Case Where Id IN: setOfCaseId];
        if(!cseList.isEmpty()){
            for(Case cs : cseList){
                cs.isFollowUp__c = 'Yes';
            }
            update cseList;
        }
    }
    
    public static void updateCaseOnFollowUpUpdation(List<Follow_Up_Request__c> followUpRequestList) {
        Set<Id> setOfCaseId = new Set<Id>();
        
        for (Follow_Up_Request__c fur : followUpRequestList) {
            if (fur.Case__c != null) {
                setOfCaseId.add(fur.Case__c);
            }
        }
        
        List<Follow_Up_Request__c> followUpReqList = [
            SELECT Id, Name, Case__c, Follow_Up_Status__c
            FROM Follow_Up_Request__c
            WHERE Case__c IN :setOfCaseId
            ORDER BY CreatedDate DESC LIMIT 1
        ];
        
        if (!followUpReqList.isEmpty()) {
            Follow_Up_Request__c recentFollowUp = followUpReqList[0];
            if (recentFollowUp.Follow_Up_Status__c == 'Responded') {
                Case cs = new Case();
                cs.Id = recentFollowUp.Case__c;
                cs.isFollowUp__c = 'No';
                
                update cs;
            }
        }
        
        
    }
    
}