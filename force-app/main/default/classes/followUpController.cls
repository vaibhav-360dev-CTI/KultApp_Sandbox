public class followUpController {
    @AuraEnabled
    public static void sendFollowUp(String recId, String remarks){
        try{
            Follow_Up_Request__c fupReq = new Follow_Up_Request__c();
            fupReq.Follow_Up_Remarks__c	 = remarks;
            fupReq.Case__c = recId;
            insert fupReq;
            
            Case caseRec = [SELECT Id, OwnerId FROM Case WHERE Id =: recId LIMIT 1];
            CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            String notificationBody = 'CS Agent is following up on the case. Please update!'; 
            notification.setBody(notificationBody);
            notification.setTitle('Follow Up Request Received');
            notification.setSenderId(UserInfo.getUserId());
            notification.setNotificationTypeId(customNotiList.Id); 
            notification.setTargetId(recId);
            System.debug('notification:::::::::::>' + notification); 
            notification.send(new set<String>{caseRec.OwnerId});
        }catch(exception e){
            System.debug('Error Message: ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static String sendFollowUpResponse(String recId, String respondNote) {
        try {
            List<Follow_Up_Request__c> furs = [SELECT Id, Follow_Up_Status__c, OwnerId, Response_Notes__c, CreatedDate 
                                               FROM Follow_Up_Request__c 
                                               WHERE Follow_Up_Status__c = 'Open' AND Case__c = :recId ];
            List<Follow_Up_Request__c> fuprRec = new List<Follow_Up_Request__c>();
            
            if (!furs.isEmpty()) {
                //fuprRec = furs[0];
                for(Follow_Up_Request__c fr : furs){
                    fr.Follow_Up_Status__c = 'Responded';
                    fr.Response_Notes__c = respondNote;
                    fr.Response_Time__c = System.Now(); 
                    fuprRec.add(fr);
                }
                
                update fuprRec;
                
                CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                String notificationBody = 'A followUp response has been received. Please Check!'; 
                notification.setBody(notificationBody);
                notification.setTitle('Response To Follow Up Received');
                notification.setNotificationTypeId(customNotiList.Id); 
                notification.setTargetId(recId);
                notification.send(new set<String>{fuprRec[0].OwnerId});
                return 'Success';
            } else {
                System.debug('No open Follow_Up_Request__c records found for Case: ' + recId);
                return 'No records found';
            }
        } catch(Exception e) {
            System.debug('Error Message: ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            return 'Error: ' + e.getMessage();
        }
    }
    @AuraEnabled
    public static string checkFollowUpStatu(string recId){
        try {
            List<Follow_Up_Request__c> furs = [SELECT Id, Follow_Up_Status__c, OwnerId, Response_Notes__c, CreatedDate FROM Follow_Up_Request__c 
                                               WHERE  Case__c = :recId ORDER BY CreatedDate DESC LIMIT 1];
            
            if(!furs.isEmpty()){
                Follow_Up_Request__c getRecentFollowUp = furs[0];
                
                if(getRecentFollowUp.Follow_Up_Status__c == 'Open'){
                    return 'Open';
                }else{
                    return 'Responded';
                }
            }
            return 'No Follow-Up Requests Found';
        } catch (Exception e) {
            System.debug('Error Message: ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            return null;
        }
    }
}