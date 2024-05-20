public class followUpController {
    @AuraEnabled
    public static void sendFollowUp(String recId, String remarks){
        try{
            /*Follow_Up_Request__c fupReq = new Follow_Up_Request__c();
fupReq.Follow_Up_Remarks__c	 = remarks;
fupReq.Case__c = recId;
insert fupReq; */
            
            Case caseRec = [SELECT Id, OwnerId,Is_With_Refund_Team__c, isFollowUp__c FROM Case WHERE Id =: recId LIMIT 1];
            
            String UserId =  userInfo.getUserId();
            User usrRec = [SELECT Id,Name,Profile.Name From User Where Id =:UserId];
            
            Case_Progress_Detail__c cpd = new Case_Progress_Detail__c();            
            cpd.Case__c = recId;
            cpd.Status__c = 'Open';
            if(usrRec.Profile.Name == 'WareHouse Team'){
                cpd.WH_Team_Remarks__c = remarks;
                cpd.Current_Action__c = 'Follow Request Raised by WH Team';
            }else if(usrRec.Profile.Name == 'Customer Service Executive' && caseRec.Is_With_Refund_Team__c == true){
                cpd.WH_Team_Remarks__c = remarks;
                cpd.Current_Action__c = 'Follow Request Raised by Refund Team';
            }else{
                cpd.CS_Remarks__c = remarks;
                cpd.Current_Action__c = 'Follow Request Raised by CS Agent';
            } 
            Insert cpd;

            caseRec.isFollowUp__c = 'Yes';
            
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
            Set<Id> setOfCaseId = new Set<Id>();
            List<Case_Progress_Detail__c> caseProgressDetailRec = new List<Case_Progress_Detail__c>();
            List<Case_Progress_Detail__c> cpdDeatils= [SELECT Id, WH_Team_Remarks__c, Case__c, Responded_By__c, OwnerId, Response_Time__c,Status__c ,CS_Remarks__c, CreatedBy.Profile.Name 
                                                       FROM Case_Progress_Detail__c 
                                                       WHERE Case__c =:recId AND Status__c = 'Open' Order By CreatedDate desc];
            String recentCpdId = cpdDeatils[0].Id;
            if(!cpdDeatils.isEmpty()){
                for(Case_Progress_Detail__c cpdRec : cpdDeatils){
                    cpdRec.Status__c = 'Responded';
                    cpdRec.Responded_By__c = userInfo.getUserId();
                    if(cpdRec.CS_Remarks__c == null && cpdRec.Id == recentCpdId){
                        cpdRec.CS_Remarks__c = respondNote;
                        
                    }if(cpdRec.WH_Team_Remarks__c == null && cpdRec.Id == recentCpdId){
                        cpdRec.WH_Team_Remarks__c = respondNote;
                    }
                    cpdRec.Response_Time__c = system.Now();
                    caseProgressDetailRec.add(cpdRec);
                }
                update caseProgressDetailRec;
                
                Case cs = new Case();
                cs.Id = recId;
                cs.isFollowUp__c = 'No';
                cs.Last_Response__c = system.now();
                update cs;
                System.debug('setOfCaseId============>'+setOfCaseId);
                
                CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                String notificationBody = 'A followUp response has been received. Please Check!'; 
                notification.setBody(notificationBody);
                notification.setTitle('Response To Follow Up Received');
                notification.setNotificationTypeId(customNotiList.Id); 
                notification.setTargetId(recId);
                notification.send(new set<String>{caseProgressDetailRec[0].OwnerId});
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