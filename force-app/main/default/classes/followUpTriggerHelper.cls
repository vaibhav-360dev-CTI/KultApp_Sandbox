public class followUpTriggerHelper {
    public static void updateCaseOnFollowUpCreation(List<Follow_Up_Request__c> followUpRequestList){
        Set<Id> setOfCaseId = new Set<Id>();
        for(Follow_Up_Request__c fur :followUpRequestList){
            if(fur.Case__c != null && fur.Follow_Up_Status__c == 'Open'){
                setOfCaseId.add(fur.Case__c);
            }
        }
        system.debug('setOfCaseId==============>'+setOfCaseId);
        List<Case> cseList = [SELECT Id,isFollowUp__c From Case Where Id IN: setOfCaseId];
        if(!cseList.isEmpty()){
            for(Case cs : cseList){
                cs.isFollowUp__c = 'Yes';
            }
            update cseList;
        }
        system.debug('cseList==============>'+cseList);
        List<Follow_Up_Request__c> followUpRequstList = [
            SELECT Id, Name, Case__c, Follow_Up_Status__c
            FROM Follow_Up_Request__c
            WHERE Case__c IN :setOfCaseId
        ];
        
    }
    
    public static void updateCaseOnFollowUpUpdation(List<Follow_Up_Request__c> followUpRequestList) {
        Set<Id> setOfCaseId = new Set<Id>();
        
        for (Follow_Up_Request__c fur : followUpRequestList) {
            if (fur.Case__c != null) {
                setOfCaseId.add(fur.Case__c);
            }
        }
        system.debug('setOfCaseId==============>'+setOfCaseId);
        List<Follow_Up_Request__c> followUpReqList = [
            SELECT Id, Name, Case__c, Follow_Up_Status__c
            FROM Follow_Up_Request__c
            WHERE Case__c IN :setOfCaseId
            ORDER BY CreatedDate DESC LIMIT 1
        ];
        system.debug('followUpReqList==============>'+followUpReqList);
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
    public static void OnInsertOrUpdateLastResponseOnCase(List<Follow_Up_Request__c> followUpRequestList){
        Set<Id> setOfCaseId = new Set<Id>();
        
        for (Follow_Up_Request__c fur : followUpRequestList) {
            if (fur.Case__c != null) {
                if(fur.Follow_Up_Status__c == 'Responded'){
                    Case cs = new Case();
                    cs.Id = fur.Case__c;
                    cs.Last_Response__c = system.now();
                    
                    update cs;
                    System.debug('setOfCaseId============>'+setOfCaseId);
                }
                
            }
        }
        
        
        
    }
   /* public static void OnInsertOrUpdate(List<Follow_Up_Request__c> followUpRequestList){
        Set<Id> setOfCaseId = new Set<Id>();
        
        for (Follow_Up_Request__c fur : followUpRequestList) {
            if (fur.Case__c != null && fur.Follow_Up_Status__c == 'Responded') {
                setOfCaseId.add(fur.Case__c);
                System.debug('setOfCaseId============>'+setOfCaseId);
            }
        }
        
        List<Follow_Up_Request__c> furReq =  [SELECT Id, Name, Case__c, Follow_Up_Status__c FROM Follow_Up_Request__c WHERE Follow_Up_Status__c = 'Open'  AND Case__c IN :setOfCaseId];
        for(Follow_Up_Request__c fur : furReq){
            fur.Follow_Up_Status__c = 'Responded';
        }
        update furReq;
    }*/
    
}