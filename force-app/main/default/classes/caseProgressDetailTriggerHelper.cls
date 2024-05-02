public class caseProgressDetailTriggerHelper {
    public static void sendNotificationToCSTeam(List<Case_Progress_Detail__c> cpdList){
        try{
            Set<Id> caseIds = new Set<Id>();
            for(Case_Progress_Detail__c cpdRec : cpdList){
                if(cpdRec.CS_Remarks__c == null){
                caseIds.add(cpdRec.Case__c);
                }
            }
            Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, CS_Team_Member__c FROM Case WHERE Id IN: caseIds]);
            CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
            for(Case_Progress_Detail__c cpdRec : cpdList){
             Messaging.CustomNotification notification = new Messaging.CustomNotification();
            String notificationBody = 'A remark has been mentioned on the case, please check the details.'; 
            notification.setBody(notificationBody);
            notification.setTitle('Remark mentioned on the case');
            notification.setSenderId(UserInfo.getUserId());
            notification.setNotificationTypeId(customNotiList.Id); 
            notification.setTargetId(cpdRec.Case__c);
            System.debug('notification:::::::::::>' + notification); 
            notification.send(new set<String>{caseMap.get(cpdRec.Case__c).CS_Team_Member__c});
            }
        }catch(exception e){
            System.debug('Error Message: ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }
}