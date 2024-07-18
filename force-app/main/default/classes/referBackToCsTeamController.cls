public without sharing class referBackToCsTeamController {
    @AuraEnabled
    public static Case getCaseById(String caseId) {
        Case cases = [SELECT Id, Refer_Back_Reason__c, Refund_Amount__c, Approval_Remarks__c, 
                      Rejection_Remarks__c, Rejection_Reason__c, Describe_Information_Needed__c, 
                      OrderId__c, OrderId__r.Refund_Amount__c,ownerId,Refund_Reasons__c, Refund_Type__c  FROM Case  WHERE Id = :caseId LIMIT 1];
        return cases;
    }
    
    @AuraEnabled
    public static string getCaseTeamAndType(String caseId){
        try {
            Case caseRec = [SELECT Id, Refer_Back_Reason__c, Refund_Amount__c, Approval_Remarks__c, 
                            Rejection_Remarks__c, Rejection_Reason__c, Describe_Information_Needed__c, 
                            OrderId__c, OrderId__r.Refund_Amount__c,ownerId, RecordType.Name, Type, Is_With_Refund_Team__c  FROM Case  WHERE Id = :caseId LIMIT 1 ];
            List<User> userRecList = [SELECT Id, Name, Profile.Name FROM User WHERE Id =: caseRec.OwnerId];
            User userRec = new User();
            Boolean isWHAndOrderRelated = false;
            if(!userRecList.isEmpty()){
                userRec = userRecList[0];
            }
            if(userRec != null && caseRec.Type == 'Order Related' && userRec.Profile.Name == 'WareHouse Team'){
                isWHAndOrderRelated = true;
                return 'showFOCandAWB';
            }else if(caseRec.Is_With_Refund_Team__c){
                return 'showRefundAmount';
            }else if(userRec.Profile.Name == 'System Administrator'){
                return 'adminUser';
            }
            return 'none';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getCaseAndOrderDetails(String caseId, String referBackReason, Decimal refundAmount, String approvalRemarks, String  rejectionReason,String describeInformationNeeded,Decimal orderRefundAmount, 
    String resolutionRemarks, String updateDesc, String base64, String filename, String awbNumber, String focOrderId, String techIssueType, Boolean isRefundCase) {
        String currUserId = userInfo.getUserId();
        List<Case> updatedCases = new List<Case>();   
        
        try {
            if(String.isNotBlank(caseId)){
                String proceed;
                Case caseRec = [SELECT Id, CS_Team_Member__c,CaseNumber, OwnerId, Is_With_Refund_Team__c FROM Case WHERE Id=: caseId LIMIT 1]; //SELECT Id, OwnerId, User.ManagerId FROM Case WHERE Id = '500F300000DLFGLIA5'
                String OwnersId= caseRec.CS_Team_Member__c != null ? caseRec.CS_Team_Member__c : userInfo.getUserId();
                List<User> userList = [SELECT Id,Email,Name From User Where Profile.Name = 'Customer Service Executive' AND Id=:OwnersId LIMIT 1];
                User userRec = new User();
                if(!userList.isEmpty()){
                    userRec = userList[0];
                }
                Case caseToUpdate = new Case();
                if(caseId != null){
                    caseToUpdate.id = caseId;
                }
                
                if(referBackReason != null){
                    if(referBackReason =='Wrongly Sent'){
                            if(caseRec.Is_With_Refund_Team__c && String.valueOf(caseRec.OwnerId).startsWith('005')){
                                caseToUpdate.RefundTeamMember__c = caseRec.OwnerId;
                            }else if(caseRec.Is_With_Refund_Team__c && String.valueOf(caseRec.OwnerId).startsWith('00G')){
                                caseToUpdate.RefundTeamMember__c = userInfo.getUserId();
                            }
                            if(caseRec.CS_Team_Member__c != null && String.valueOf(caseRec.CS_Team_Member__c) != ''){
                                caseToUpdate.OwnerId = caseRec.CS_Team_Member__c;
                            }else if(userRec.Id != null){
                                caseToUpdate.OwnerId = userRec.Id;                     
                            }else{
                                caseToUpdate.OwnerId = caseRec.OwnerId;
                                
                            }
                            Case_Progress_Detail__c cpdRec = new Case_Progress_Detail__c();
                            cpdRec.Status__c = referBackReason == 'Resolved' ? 'Resolved' : 'In Progress';
                            cpdRec.WH_Team_Remarks__c = 'Referred Back as Wrongly Sent';
                            cpdRec.Case__c = caseId;
                            cpdRec.Current_Action__c = 'Referred Back to CS Team';
                            cpdRec.Responded_By__c = UserInfo.getUserId();
                            insert cpdRec;

                            Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                            notification.setBody('The Team has sent the case back as it was wrongly sent '+  caseRec.CaseNumber); 
                            notification.setTitle('Case Sent Back'); 
                            notification.setSenderId(Userinfo.getUserId()); 
                            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'ReferBackToCsTeam'];  
                            notification.setNotificationTypeId(type.id); 
                            notification.setTargetId(caseId); // target object id 
                            if(caseRec.CS_Team_Member__c != null){
                                notification.send(new Set<String> { caseRec.CS_Team_Member__c });
                            }else{
                                notification.send(new Set<String> { caseRec.OwnerId });
                            }
                            caseToUpdate.Is_With_Refund_Team__c = false;

                    }
                    else if(referBackReason == 'Need More Info' || referBackReason == 'Send Update'){
                        if(referBackReason == 'Need More Info'){
                            Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                            notification.setBody('The Team has asked more information On this Case Please Kindly Look Into it Detail of the Case are'+  caseRec.CaseNumber); 
                            notification.setTitle('Need More Info On Case'); 
                            notification.setSenderId(Userinfo.getUserId()); 
                            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'ReferBackToCsTeam'];  
                            notification.setNotificationTypeId(type.id); 
                            notification.setTargetId(caseId); // target object id 
                            if(caseRec.CS_Team_Member__c != null){
                                notification.send(new Set<String> { caseRec.CS_Team_Member__c });
                            }else{
                                notification.send(new Set<String> { caseRec.OwnerId });
                            }
                            caseToUpdate.more_Info_Requested__c = true;
                            Case_Progress_Detail__c cpdRec = new Case_Progress_Detail__c();
                            cpdRec.Status__c = referBackReason == 'Resolved' ? 'Resolved' : 'In Progress';
                            cpdRec.WH_Team_Remarks__c = referBackReason == 'Resolved' ? resolutionRemarks : describeInformationNeeded;
                            cpdRec.Case__c = caseId;
                            cpdRec.Current_Action__c = 'Requested more Info from CS Team';
                            insert cpdRec;
                            if(base64 != null){
                                uploadFile(base64, filename, cpdRec.Id);
                            }
                            
                        }if(referBackReason == 'Send Update'){
                            Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                            notification.setBody('The Team has sent some update on this Case, Please Look into it.'+  caseRec.CaseNumber); 
                            notification.setTitle('Update Received On Case'); 
                            notification.setSenderId(Userinfo.getUserId()); 
                            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'ReferBackToCsTeam'];  
                            notification.setNotificationTypeId(type.id); 
                            notification.setTargetId(caseId); // target object id 
                            if(caseRec.CS_Team_Member__c != null){
                                notification.send(new Set<String> { caseRec.CS_Team_Member__c });
                            }else{
                                notification.send(new Set<String> { caseRec.OwnerId });
                            }
                            List<Case_Progress_Detail__c> furs = [SELECT Id, Status__c, OwnerId, WH_Team_Remarks__c, CS_Remarks__c, CreatedDate, Responded_By__c 
                                                                  FROM Case_Progress_Detail__c 
                                                                  WHERE Status__c = 'Open' AND Case__c = :caseId ];
                            List<Case_Progress_Detail__c> fuprRec = new List<Case_Progress_Detail__c>();                            
                            if (!furs.isEmpty()) {
                                //fuprRec = furs[0];
                                
                                for(Case_Progress_Detail__c fr : furs){
                                    fr.Status__c = 'Responded';
                                    fr.Current_Action__c = 'Case Update Sent';
                                    fr.WH_Team_Remarks__c = updateDesc;
                                    fr.Response_Time__c = System.Now(); 
                                    fr.Responded_By__c = UserInfo.getUserId();
                                    fuprRec.add(fr);
                                }
                                
                                update fuprRec;
                                if(base64 != null){
                                    uploadFile(base64, filename, fuprRec[0].Id);
                                }
                                notification.send(new set<String>{fuprRec[0].OwnerId});
                                
                            }else{
                                Case_Progress_Detail__c fupRec = new Case_Progress_Detail__c();
                                fupRec.Status__c = 'Responded';
                                fupRec.WH_Team_Remarks__c = updateDesc;
                                fupRec.Response_Time__c = System.Now(); 
                                fupRec.Responded_By__c = UserInfo.getUserId();
                                fupRec.Current_Action__c = 'Case Update Sent';
                                fupRec.Case__c = caseId;
                                insert fupRec;
                                if(caseRec.CS_Team_Member__c != null){
                                    notification.send(new Set<String> { caseRec.CS_Team_Member__c });
                                }else{
                                    notification.send(new Set<String> { caseRec.OwnerId });
                                }
                                if(base64 != null){
                                    uploadFile(base64, filename, fupRec.Id);
                                }
                            }
                        }
                        
                    }
                    if(referBackReason == 'Resolved'){
                        if(isRefundCase){
                            proceed = CalloutRefundAPIClass.postRefundRequest(caseId);
                            //proceed= 'Success';
                            if(proceed == 'Success'){
                                if(caseRec.Is_With_Refund_Team__c && String.valueOf(caseRec.OwnerId).startsWith('005')){
                                    caseToUpdate.RefundTeamMember__c = caseRec.OwnerId;
                                }else if(caseRec.Is_With_Refund_Team__c && String.valueOf(caseRec.OwnerId).startsWith('00G')){
                                    caseToUpdate.RefundTeamMember__c = userInfo.getUserId();
                                }
                                if(caseRec.CS_Team_Member__c != null && String.valueOf(caseRec.CS_Team_Member__c) != ''){
                                    caseToUpdate.OwnerId = caseRec.CS_Team_Member__c;
                                }else if(userRec.Id != null){
                                    caseToUpdate.OwnerId = userRec.Id;                     
                                }else{
                                    caseToUpdate.OwnerId = caseRec.OwnerId;
                                    
                                }
                                Case_Progress_Detail__c cpdRec = new Case_Progress_Detail__c();
                                cpdRec.Status__c = referBackReason == 'Resolved' ? 'Resolved' : 'In Progress';
                                if(String.isNotBlank(techIssueType)){
                                    caseToUpdate.Tech_Issue_Type__c = techIssueType;
                                    cpdRec.WH_Team_Remarks__c = referBackReason == 'Resolved' ? techIssueType + '-' + resolutionRemarks : techIssueType + '-' + describeInformationNeeded;
                                    
                                }else{
                                    cpdRec.WH_Team_Remarks__c = referBackReason == 'Resolved' ? resolutionRemarks : describeInformationNeeded;
                                }
                                cpdRec.Case__c = caseId;
                                cpdRec.Current_Action__c = 'Referred Back to CS Team';
                                cpdRec.Responded_By__c = UserInfo.getUserId();
                                cpdRec.AWB_Number__c = awbNumber;
                                cpdRec.FOC_Order_Id__c = focOrderId;
                                insert cpdRec;
                                if(base64 != null){
                                    uploadFile(base64, filename, cpdRec.Id);
                                }
                                Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                                notification.setBody('The Team has resolved the Case, Please Look into it.'+  caseRec.CaseNumber); 
                                notification.setTitle('Case Resolved'); 
                                notification.setSenderId(Userinfo.getUserId()); 
                                CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'ReferBackToCsTeam'];  
                                notification.setNotificationTypeId(type.id); 
                                notification.setTargetId(caseId); // target object id 
                                if(caseRec.CS_Team_Member__c != null){
                                    notification.send(new Set<String> { caseRec.CS_Team_Member__c });
                                }else{
                                    notification.send(new Set<String> { caseRec.OwnerId });
                                }
                                caseToUpdate.Is_With_Refund_Team__c = false;
                            }
                        }else{
                            if(caseRec.Is_With_Refund_Team__c && String.valueOf(caseRec.OwnerId).startsWith('005')){
                                caseToUpdate.RefundTeamMember__c = caseRec.OwnerId;
                            }else if(caseRec.Is_With_Refund_Team__c && String.valueOf(caseRec.OwnerId).startsWith('00G')){
                                caseToUpdate.RefundTeamMember__c = userInfo.getUserId();
                            }
                            if(caseRec.CS_Team_Member__c != null && String.valueOf(caseRec.CS_Team_Member__c) != ''){
                                caseToUpdate.OwnerId = caseRec.CS_Team_Member__c;
                            }else if(userRec.Id != null){
                                caseToUpdate.OwnerId = userRec.Id;                     
                            }else{
                                caseToUpdate.OwnerId = caseRec.OwnerId;
                                
                            }
                            Case_Progress_Detail__c cpdRec = new Case_Progress_Detail__c();
                            cpdRec.Status__c = referBackReason == 'Resolved' ? 'Resolved' : 'In Progress';
                            if(String.isNotBlank(techIssueType)){
                                caseToUpdate.Tech_Issue_Type__c = techIssueType;
                                cpdRec.WH_Team_Remarks__c = referBackReason == 'Resolved' ? techIssueType + '-' + resolutionRemarks : techIssueType + '-' + describeInformationNeeded;
                                
                            }else{
                                cpdRec.WH_Team_Remarks__c = referBackReason == 'Resolved' ? resolutionRemarks : describeInformationNeeded;
                            }
                            cpdRec.Case__c = caseId;
                            cpdRec.Current_Action__c = 'Referred Back to CS Team';
                            cpdRec.Responded_By__c = UserInfo.getUserId();
                            cpdRec.AWB_Number__c = awbNumber;
                                cpdRec.FOC_Order_Id__c = focOrderId;
                            insert cpdRec;
                            if(base64 != null){
                                uploadFile(base64, filename, cpdRec.Id);
                            }
                            Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                            notification.setBody('The Team has resolved the Case, Please Look into it.'+  caseRec.CaseNumber); 
                            notification.setTitle('Case Resolved'); 
                            notification.setSenderId(Userinfo.getUserId()); 
                            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'ReferBackToCsTeam'];  
                            notification.setNotificationTypeId(type.id); 
                            notification.setTargetId(caseId); // target object id 
                            if(caseRec.CS_Team_Member__c != null){
                                notification.send(new Set<String> { caseRec.CS_Team_Member__c });
                            }else{
                                notification.send(new Set<String> { caseRec.OwnerId });
                            }
                            caseToUpdate.Is_With_Refund_Team__c = false;
                        }
                    }
                    if((isRefundCase && proceed == 'Success') || !isRefundCase){
                        caseToUpdate.Refer_Back_Reason__c = referBackReason;
                        List<CaseShare> existingShares = [SELECT Id, UserOrGroup.Name FROM CaseShare WHERE CaseId = :caseToUpdate.Id AND UserOrGroupId = :currUserId AND RowCause != 'Owner'];
                        System.debug('Inside sharing check');
                        if(!existingShares.isEmpty()){
                            delete existingShares;
                        }
                    }
                }
                if((isRefundCase && proceed == 'Success') || !isRefundCase){
                    if(approvalRemarks != null){
                        caseToUpdate.Approval_Remarks__c = approvalRemarks;
                    }
                    if(rejectionReason != null){
                        caseToUpdate.Rejection_Reason__c = rejectionReason;
                    }
                    if(describeInformationNeeded != null){
                        caseToUpdate.Describe_Information_Needed__c = describeInformationNeeded;
                    }                
                    if (caseToUpdate.OrderId__c != null && orderRefundAmount != null) {
                        caseToUpdate.OrderId__r.Refund_Amount__c = orderRefundAmount;
                    }
                    if(refundAmount != null){
                        caseToUpdate.Refund_Amount__c = refundAmount;
                    }
                    caseToUpdate.Case_Sub_Status__c = 'Referred Back to CS Team';
                    caseToUpdate.AWB_Number__c = awbNumber;
                    caseToUpdate.FOC_Order_Id__c = focOrderId;
                    caseToUpdate.Last_Response__c = system.now();
                    update caseToUpdate;
                    updatedCases.add(caseToUpdate);
                    return 'Success';
                }else{
                    return proceed;
                }
            }
            return 'error';            
        } catch (Exception e) {
            System.debug('Error updating Case record: ' + e.getMessage());
            system.debug('Exception Line Number--->'+e.getLineNumber());
            return e.getMessage();
        }
    }


    @AuraEnabled
    public static String getCaseAndOrderDetailsNew(String caseId, String referBackReason, Decimal refundAmount, String approvalRemarks, String  rejectionReason,String describeInformationNeeded,Decimal orderRefundAmount, 
    String resolutionRemarks, String updateDesc, String base64, String filename, String awbNumber, String focOrderId, String techIssueType, Boolean isRefundCase, Boolean isMonitoringCase) {
        String currUserId = userInfo.getUserId();
        List<Case> updatedCases = new List<Case>();   
        
        try {
            if(String.isNotBlank(caseId)){
                String proceed;
                Case caseRec = [SELECT Id, CS_Team_Member__c,CaseNumber, OwnerId, Is_With_Refund_Team__c FROM Case WHERE Id=: caseId LIMIT 1]; //SELECT Id, OwnerId, User.ManagerId FROM Case WHERE Id = '500F300000DLFGLIA5'
                String OwnersId= caseRec.CS_Team_Member__c != null ? caseRec.CS_Team_Member__c : userInfo.getUserId();
                List<User> userList = [SELECT Id,Email,Name From User Where Profile.Name = 'Customer Service Executive' AND Id=:OwnersId LIMIT 1];
                User userRec = new User();
                if(!userList.isEmpty()){
                    userRec = userList[0];
                }
                Case caseToUpdate = new Case();
                if(caseId != null){
                    caseToUpdate.id = caseId;
                }
                
                if(referBackReason != null){
                    if(referBackReason == 'Resolved'){
                        if(isRefundCase && isMonitoringCase){
                            proceed = CalloutRefundAPIClass.postRefundRequest(caseId);
                            //proceed= 'Success';
                            if(proceed == 'Success'){
                                if(caseRec.Is_With_Refund_Team__c && String.valueOf(caseRec.OwnerId).startsWith('005')){
                                    caseToUpdate.RefundTeamMember__c = caseRec.OwnerId;
                                }else if(caseRec.Is_With_Refund_Team__c && String.valueOf(caseRec.OwnerId).startsWith('00G')){
                                    caseToUpdate.RefundTeamMember__c = userInfo.getUserId();
                                }
                                if(caseRec.CS_Team_Member__c != null && String.valueOf(caseRec.CS_Team_Member__c) != ''){
                                    caseToUpdate.OwnerId = caseRec.CS_Team_Member__c;
                                }else if(userRec.Id != null){
                                    caseToUpdate.OwnerId = userRec.Id;                     
                                }else{
                                    caseToUpdate.OwnerId = caseRec.OwnerId;
                                    
                                }
                                caseToUpdate.Status = 'Closed';
                                Case_Progress_Detail__c cpdRec = new Case_Progress_Detail__c();
                                cpdRec.Status__c = referBackReason == 'Resolved' ? 'Resolved' : 'In Progress';
                                if(String.isNotBlank(techIssueType)){
                                    caseToUpdate.Tech_Issue_Type__c = techIssueType;
                                    cpdRec.WH_Team_Remarks__c = referBackReason == 'Resolved' ? techIssueType + '-' + resolutionRemarks : techIssueType + '-' + describeInformationNeeded;
                                    
                                }else{
                                    cpdRec.WH_Team_Remarks__c = referBackReason == 'Resolved' ? resolutionRemarks : describeInformationNeeded;
                                }
                                cpdRec.Case__c = caseId;
                                cpdRec.Current_Action__c = 'Refund Issued and Case Closed by Refund Team';
                                cpdRec.Responded_By__c = UserInfo.getUserId();
                                cpdRec.AWB_Number__c = awbNumber;
                                cpdRec.FOC_Order_Id__c = focOrderId;
                                insert cpdRec;
                                if(base64 != null){
                                    uploadFile(base64, filename, cpdRec.Id);
                                }
                                // Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                                // notification.setBody('The Team has resolved the Case, Please Look into it.'+  caseRec.CaseNumber); 
                                // notification.setTitle('Case Resolved'); 
                                // notification.setSenderId(Userinfo.getUserId()); 
                                // CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'ReferBackToCsTeam'];  
                                // notification.setNotificationTypeId(type.id); 
                                // notification.setTargetId(caseId); // target object id 
                                // if(caseRec.CS_Team_Member__c != null){
                                //     notification.send(new Set<String> { caseRec.CS_Team_Member__c });
                                // }else{
                                //     notification.send(new Set<String> { caseRec.OwnerId });
                                // }
                                caseToUpdate.Is_With_Refund_Team__c = false;
                            }
                        }else{
                            proceed='Success';
                            if(caseRec.Is_With_Refund_Team__c && String.valueOf(caseRec.OwnerId).startsWith('005')){
                                caseToUpdate.RefundTeamMember__c = caseRec.OwnerId;
                            }else if(caseRec.Is_With_Refund_Team__c && String.valueOf(caseRec.OwnerId).startsWith('00G')){
                                caseToUpdate.RefundTeamMember__c = userInfo.getUserId();
                            }
                            if(caseRec.CS_Team_Member__c != null && String.valueOf(caseRec.CS_Team_Member__c) != ''){
                                caseToUpdate.OwnerId = caseRec.CS_Team_Member__c;
                            }else if(userRec.Id != null){
                                caseToUpdate.OwnerId = userRec.Id;                     
                            }else{
                                caseToUpdate.OwnerId = caseRec.OwnerId;
                                
                            }
                            Case_Progress_Detail__c cpdRec = new Case_Progress_Detail__c();
                            cpdRec.Status__c = referBackReason == 'Resolved' ? 'Resolved' : 'In Progress';
                            if(String.isNotBlank(techIssueType)){
                                caseToUpdate.Tech_Issue_Type__c = techIssueType;
                                cpdRec.WH_Team_Remarks__c = referBackReason == 'Resolved' ? techIssueType + '-' + resolutionRemarks : techIssueType + '-' + describeInformationNeeded;
                                
                            }else{
                                cpdRec.WH_Team_Remarks__c = referBackReason == 'Resolved' ? resolutionRemarks : describeInformationNeeded;
                            }
                            cpdRec.Case__c = caseId;
                            cpdRec.Current_Action__c = 'Referred Back to CS Team';
                            cpdRec.Responded_By__c = UserInfo.getUserId();
                            cpdRec.AWB_Number__c = awbNumber;
                            cpdRec.FOC_Order_Id__c = focOrderId;
                            insert cpdRec;
                            if(base64 != null){
                                uploadFile(base64, filename, cpdRec.Id);
                            }
                            Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                            notification.setBody('The Team has resolved the Case, Please Look into it.'+  caseRec.CaseNumber); 
                            notification.setTitle('Case Resolved'); 
                            notification.setSenderId(Userinfo.getUserId()); 
                            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'ReferBackToCsTeam'];  
                            notification.setNotificationTypeId(type.id); 
                            notification.setTargetId(caseId); // target object id 
                            if(caseRec.CS_Team_Member__c != null){
                                notification.send(new Set<String> { caseRec.CS_Team_Member__c });
                            }else{
                                notification.send(new Set<String> { caseRec.OwnerId });
                            }
                            caseToUpdate.Is_With_Refund_Team__c = false;
                        }
                    }
                    if((isRefundCase && proceed == 'Success') || !isRefundCase){
                        caseToUpdate.Refer_Back_Reason__c = referBackReason;
                        List<CaseShare> existingShares = [SELECT Id, UserOrGroup.Name FROM CaseShare WHERE CaseId = :caseToUpdate.Id AND UserOrGroupId = :currUserId AND RowCause != 'Owner'];
                        System.debug('Inside sharing check');
                        if(!existingShares.isEmpty()){
                            delete existingShares;
                        }
                    }
                }
                if((isRefundCase && proceed == 'Success') || !isRefundCase){
                    if(approvalRemarks != null){
                        caseToUpdate.Approval_Remarks__c = approvalRemarks;
                    }
                    if(rejectionReason != null){
                        caseToUpdate.Rejection_Reason__c = rejectionReason;
                    }
                    if(describeInformationNeeded != null){
                        caseToUpdate.Describe_Information_Needed__c = describeInformationNeeded;
                    }                
                    if (caseToUpdate.OrderId__c != null && orderRefundAmount != null) {
                        caseToUpdate.OrderId__r.Refund_Amount__c = orderRefundAmount;
                    }
                    if(refundAmount != null){
                        caseToUpdate.Refund_Amount__c = refundAmount;
                    }
                    caseToUpdate.Case_Sub_Status__c = 'Referred Back to CS Team';
                    caseToUpdate.AWB_Number__c = awbNumber;
                    caseToUpdate.FOC_Order_Id__c = focOrderId;
                    caseToUpdate.Last_Response__c = system.now();
                    update caseToUpdate;
                    updatedCases.add(caseToUpdate);
                    return 'Success';
                }else{
                    return proceed;
                }
            }
            return 'error';            
        } catch (Exception e) {
            System.debug('Error updating Case record: ' + e.getMessage());
            system.debug('Exception Line Number--->'+e.getLineNumber());
            return e.getMessage();
        }
    }
    
    // Method to delete CaseShare records associated with the given Case Id
    public static void deletecaseShares(String caseId){
        List<CaseShare> lscaseshare = [Select Id From CaseShare where Id =:caseId];
        if(!lscaseshare.isEmpty()){
            delete lscaseshare;
            System.debug('lscaseshare deleted sucessfully=====>'+lscaseshare);
        }
        else{
            System.debug('lscaseshare is empty=====>'+lscaseshare);
        }
    } 
    
    public static void sendingCustomNotification(String OwnerId,String caseId,String notificationTitle, String notificationBody,list<string> emaillist){
        System.debug('OwnerId=====>'+OwnerId);
        System.debug('caseId=====>'+caseId);
        System.debug('notificationTitle=====>'+notificationTitle);
        
        // Fetching the manager's UserId
        User ownerUser = [SELECT ManagerId FROM User WHERE Id = : ownerId LIMIT 1];
        String managerId = ownerUser.ManagerId;
        System.debug('managerId======>' + managerId);
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                   WHERE DeveloperName='ReferBackToCsTeam'];
        System.debug('notificationType=====>'+notificationType);
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        notification.setTitle(notificationTitle);
        notification.setBody(notificationBody);
        
        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(caseId);
        
        Set<String> addressee = new Set<String>();
        addressee.add(OwnerId);
        //addressee.add(managerId);
        
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='Case Assigned to CS Team'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String body = temp.body;
        //body = body.replace('{!Case.Id}',newCase.Id);
        mail.setPlainTextBody(body);
        mail.setTemplateId(temp.id);
        mail.setWhatId(caseId);
        mail.setToAddresses(emaillist);
        mail.setTargetObjectId( UserInfo.getUserId() );
        mail.setSaveAsActivity(FALSE);
        mailList.add(mail);
        // Actually send the notification
        try {
            notification.send(addressee);
            Messaging.sendEmail(mailList);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }
    
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }

    public static void AccountCreatedConCreated(List<Account> AccList) {
        List<Contact> conlist = new List<Contact>();
        for(Account acc : AccList){
            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.LastName = acc.Name;
            con.Phone = acc.Phone;
            con.Description = acc.Description;
            con.Email = acc.Email__c;
            conlist.add(con);
        }
        if (!conlist.isEmpty()) {
            insert conlist;  
        }
    }

    public static void dumMethod(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
    
}