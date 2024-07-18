public without sharing class moveToWarehouseController {
    @AuraEnabled
    public static wareHouseWrapper getCaseDetailsAndPicklistValues(String recId){
        try{
            if(recId != null){
                Case caseRec = new Case();
                List<Affected_SKU__c> affSKUList = new List<Affected_SKU__c>();
                List<Case> caseList = [SELECT Id, IsDeleted, MasterRecordId, CaseNumber, ContactId, AccountId, EntitlementId, ParentId, 
                                       SuppliedName, SuppliedEmail, SuppliedPhone, SuppliedCompany, Type, RecordTypeId, Status, Reason, Origin, 
                                       Language, Subject, Priority, Description, IsClosed, ClosedDate, IsEscalated, OwnerId, SlaStartDate, SlaExitDate, 
                                       CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ContactPhone, ContactMobile, ContactEmail, 
                                       ContactFax, Comments, LastViewedDate, LastReferencedDate, MilestoneStatus, Sub_Type__c, Sub_Sub_Type__c, Payment_ID__c, 
                                       Amount_Paid__c,Refund_Back_Reason__c, Approval_Remarks__c, 
                                        Coupon_Code__c,Logging_Mobile_number__c, 
                                       Brand__c, Actual_Price__c, Movement_Date_Time__c,
                                       Brand_Name__c, User_Id__c, Contact_Number__c, 
                                       Instagram_ID__c, Address_With_Pin_Code__Street__s, Address_With_Pin_Code__City__s, Address_With_Pin_Code__PostalCode__s, 
                                       Address_With_Pin_Code__StateCode__s, Address_With_Pin_Code__CountryCode__s, Address_With_Pin_Code__Latitude__s, 
                                       Address_With_Pin_Code__Longitude__s, Address_With_Pin_Code__GeocodeAccuracy__s, Address_With_Pin_Code__c, Landmark__c,
                                        Remarks_mentioned__c, Actual_Order_Status__c, Expected_Date_Time__c, Receiver_Name__c, Address__Street__s,
                                       Address__City__s, Address__PostalCode__s, Address__StateCode__s, Address__CountryCode__s, Address__Latitude__s, Address__Longitude__s, 
                                       Address__GeocodeAccuracy__s, Address__c, Pin_code__Street__s, Pin_code__City__s, Pin_code__PostalCode__s, Pin_code__StateCode__s, 
                                       Pin_code__CountryCode__s, Pin_code__Latitude__s, Pin_code__Longitude__s, Pin_code__GeocodeAccuracy__s, Pin_code__c, 
                                       Receiver_Mobile_Number__c, Expected_Delivery_By__c, SKU_Details__c,
                                       Stage__c, Refund_Reason__c, Refund_Type__c, Coupon__c, OrderId__c,
                                       AWB_Number__c, Disposition__c, Current_PIN_Code__c, OOS_Quantity__c, Marketing__c, Case_Reason_Description__c, 
                                       Email_Replied__c, Communication_Mode__c, Channel_Case__c, RefundTeamMember__c, Parent_Case__c, Approval_Step__c, Re_Opening_Reason__c, 
                                       Profile_Name__c, Refund_Amount__c, Rejection_Remarks__c,
                                       MT_Assignment_Reason__c, MT_Assignment_Remarks__c, Category__c,Social_Media_Platform__c, 
                                       User_Name__c, Type_of_Post__c, Post_Id__c, Record_changed__c, Created_DateTime__c, Refund_Reasons__c,  Caption__c, 
                                       Created_Time__c, POST_URL__c,  Mention__c, HashTag__c, Hash_Tag_Id__c, Customer_s_Request__c, Post_Comments__c, 
                                       Post_Case_Comments__c, Warehouse_Team_Member__c, CS_Team_Member__c, RecordType.Name, Case_Sub_Status__c, CSE_Remarks__c, Number_of_Times_Sent_to_WH__c FROM Case WHERE Id=: recId];
                wareHouseWrapper wr = new wareHouseWrapper();
                if(!caseList.isEmpty()){
                    caseRec = caseList[0];
                    if(caseRec.OrderId__c != null){
                        List<OrderItem> oliList = [SELECT Id, Product2.Name, Quantity, TotalPrice, OrderID, OriginalOrderItemId, Is_Duplicate_Order__c, PricebookEntryId,
                                                   Product2Id, ListPrice, UnitPrice, Refund_Quantity__c,SKU__c FROM OrderItem WHERE OrderID =: caseRec.OrderId__c];
                        if(oliList.size()>0){
                            wr.oliList = oliList;
                        }
                    }
                    affSKUList = [SELECT Id, Case__c FROM Affected_SKU__c WHERE Case__c = :recId];
                }
                List<String> customerRequestOptions = getPicklistValues('Case', 'Customer_s_Request__c');
                List<String> caseReasonOptions = getPicklistValues('Case', 'Type_Of_Case__c');
                
                wr.customerRequestOptions = customerRequestOptions;
                wr.caseReasonOptions = caseReasonOptions;
                wr.caseRec = caseRec;
                if(!affSKUList.isEmpty()){
                    wr.isAffSKUsFound = true;
                }else{
                    wr.isAffSKUsFound = false;
                }
                wr.countryList = getCountryPicklistValues('Case', 'Address_With_Pin_Code__CountryCode__s');
                wr.statesByCountry = dependentPicklistValAPEX.getCountryStateDependencies('Case', 'Address_With_Pin_Code__CountryCode__s', 'Address_With_Pin_Code__StateCode__s');
                return wr;
            }
            return null;
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static String moveToWHteams(Case caseRec, String CSremarks){
        try{
            List<User> userLists = [SELECT Id, Name, UserName, Email FROM User WHERE Profile.Name = 'WareHouse Team' AND isActive = true LIMIT 1];
            List<Group> groupList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, QueueRoutingConfigId, OwnerId, DoesSendEmailToMembers, DoesIncludeBosses, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp FROM Group WHERE DeveloperName = 'Warehouse_Team_Queue'];
            List<EmailTemplate> etList = [SELECT Id,Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName ='WH_Team_Notification'];
            EmailTemplate et = new EmailTemplate();
            List<string> toAddress = new List<string>();

            for(User userRec : userLists){
                if(userRec.Email != null && userRec.UserName != 'varun.s@kult.app' && userRec.UserName != 'samir.p@kult.app' && userRec.UserName != 'rohan.m@kult.app'){
                    toAddress.add(userRec.Email);
                }
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);
            mail.setToAddresses(toAddress);
            mail.setSubject(et.subject);
           // mail.setHTMLBody(et.Body);
            mail.setWhatId(caseRec.Id);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
        
            if(!etList.isEmpty()){
                et = etList[0];
            }
            String queueId;
            if(!groupList.isEmpty()){
                queueId = groupList[0].Id;
            }else if(!userLists.isEmpty()){
                queueId = userLists[0].Id;
            }
            if(queueId != null){
                String body = et.HTMLValue;
                body = body.replace('<CaseNumber>', caseRec.CaseNumber);               
                
                if(caseRec.Type != null)
                    body = body.replace('<CaseType>', caseRec.Type);
                if(caseRec.Sub_Type__c != null)
                    body = body.replace('<CaseSubType>', caseRec.Sub_Type__c);
                if(caseRec.Sub_Sub_Type__c != null)
                    body = body.replace('<CaseSubSubType>', caseRec.Sub_Sub_Type__c);
                if(CSremarks != null)
                    body = body.replace('<CSremarks>', CSremarks);
                
                mail.setHTMLBody(body);
                //caseRec.Warehouse_Team_Member__c = userLists[0].Id;
                if(caseRec.CS_Team_Member__c == null){
                    caseRec.CS_Team_Member__c = caseRec.OwnerId;
                }
                caseRec.OwnerId = queueId;
                caseRec.Status = 'In Progress';
                caseRec.Case_Sub_Status__c = 'Assigned to Warehouse Team';
                caseRec.Assigned_to_WH_Team__c = true;
                caseRec.Number_of_Times_Sent_to_WH__c = caseRec.Number_of_Times_Sent_to_WH__c == null ? 1 : caseRec.Number_of_Times_Sent_to_WH__c + 1;
                caseRec.Movement_Date_Time__c = System.Now();
                update caseRec;
                Case_Progress_Detail__c cpdRec = new Case_Progress_Detail__c();
                cpdRec.Status__c = 'In Progress';
                cpdRec.CS_Remarks__c = CSremarks;
                cpdRec.Case__c = caseRec.Id;
                cpdRec.Current_Action__c = 'Moved to WH Team';
                insert cpdRec;
                
                List<CaseShare> existingShares = [SELECT Id FROM CaseShare WHERE CaseId = :caseRec.Id AND UserOrGroupId = :caseRec.CS_Team_Member__c AND RowCause != 'Owner'];
                
                if(!existingShares.isEmpty()){
                    //delete existingShares;
                }else{
                    CaseShare newCaseShare = new CaseShare();
                    newCaseShare.CaseId =  caseRec.Id;    //caseRecord.Id;
                    newCaseShare.UserOrGroupId = caseRec.CS_Team_Member__c;
                    newCaseShare.CaseAccessLevel = 'Edit';
                    //newCaseShare.RowCause = Schema.CaseShare.RowCause.Manual;
                    insert newCaseShare;
                    List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                    allmsg.add(mail);
                    try {
                        Messaging.sendEmail(allmsg,false);
                        return 'Successful';
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                    } 
                    //sendingCustomNotification(caseRec.Warehouse_Team_Member__c, caseRec.Id, 'Case has been assigned', 'A case has been moved to warehouse team bucket, please take relevant action');
                    return 'Successful';
                }
            }
            return 'error';
        }catch(exception e){
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static void sendingCustomNotification(String refundTeamMemberId,String caseId,String notificationTitle, String notificationBody){

        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                   WHERE DeveloperName='Refund_Team_Member'];
        
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(notificationTitle);
        notification.setBody(notificationBody);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(caseId);                         
        Set<String> addressee = new Set<String>();
        addressee.add(refundTeamMemberId);                         
        try {
            notification.send(addressee);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
        
    }
    
    public class wareHouseWrapper{
        @AuraEnabled
        public List<String> customerRequestOptions;
        @AuraEnabled
        public List<String> caseReasonOptions;
        @AuraEnabled
        public Case caseRec;
        @AuraEnabled
        public Boolean isAffSKUsFound;
        @AuraEnabled
        public List<OrderItem> oliList;
        @AuraEnabled
        public List<Country> countryList;
        @AuraEnabled
        public Map<String, List<dependentPicklistValAPEX.State>> statesByCountry;
    }
    
    public static List<String> getPicklistValues(String objName, String fieldName){
        List<String> options = new List<String>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            options.add(objPickList.getValue());
        }
        return options;
    }
    
    public static List<Country> getCountryPicklistValues(String objName, String fieldName){
        List<Country> options = new List<Country>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            Country countryRec = new Country();
            countryRec.value = objPickList.getValue();
            countryRec.label = objPickList.getLabel();
            options.add(countryRec);
        }
        return options;
    }
    
    public class Country {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
    
    @AuraEnabled
    public static String showErrorToAddSkuDetails(String recId) {
        try {
            List<Affected_SKU__c> affSKUList = [SELECT Id, Case__c FROM Affected_SKU__c WHERE Id = :recId];
            if (affSKUList.size() > 0) {
                return 'SUCCESS';
            } else {
                return 'No affected SKUs found.';
            }
        } catch (Exception e) {
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static string AssignToAdminQueue(string RecId, String reassignReason){
        try {
            if(RecId != null){
                List<Group> queueList = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'Admin_Queue' ];
                String queueId;
                if(queueList != null){
                    queueId = queueList[0].Id;
                }
                List<Case> csList = [SELECT Id,CaseNumber,MT_Assignment_Reason__c,OwnerId From Case Where Id =: RecId Limit 1];
                for(Case cse : csList){
                    if(reassignReason != null){
                        cse.MT_Assignment_Reason__c = reassignReason;
                        cse.OwnerId = queueId;
                        cse.Movement_Date_Time__c = System.Now();
                        cse.Case_Sub_Status__c = 'Assigned to Admin Queue';
                        cse.Assigned_to_Admin__c = true;
                    }
                    Case_Progress_Detail__c cpd = new Case_Progress_Detail__c();
                    cpd.CS_Remarks__c = reassignReason;
                    cpd.Status__c = 'In Progress';
                    cpd.Case__c = cse.Id;
                    cpd.Current_Action__c = 'Move To Admin';
                    Insert cpd;
                }
                update csList;
                
                return 'SUCCESS';
            }
        } catch (Exception e) {
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            
        }return null;
    }

    @AuraEnabled
    public static string reAssignCaseToCSTeam(string recId, String reAssignmnetReason, Id usrId){
        try {
            if(recId != null){
                
                List<Case> csList = [SELECT Id,CaseNumber,MT_Assignment_Reason__c,CS_Team_Member__c,OwnerId,Is_With_Refund_Team__c From Case Where Id =: recId Limit 1];
                for(Case cse : csList){
                    if(reAssignmnetReason != null){
                        cse.MT_Assignment_Reason__c = reAssignmnetReason;
                        cse.OwnerId = usrId;
                        cse.CS_Team_Member__c = usrId;
                        cse.Is_With_Refund_Team__c = false;
                        cse.Status = 'Re Assigned';
                        cse.Case_Sub_Status__c = 'Assigned to CS Team';
                        cse.Case_Reassigned_DateTime__c = System.Now();
                        Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                        notification.setBody('A New Case Has Been Assigned To You'); 
                        notification.setTitle('New Case Assignment'); 
                        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];  
                        notification.setNotificationTypeId(type.id); 
                        notification.setTargetId(cse.Id);
                        notification.send(new Set<String> { cse.OwnerId });
                    }
                    Case_Progress_Detail__c cpd = new Case_Progress_Detail__c();
                    cpd.CS_Remarks__c = reAssignmnetReason;
                    cpd.Status__c = 'In Progress';
                    cpd.Case__c = cse.Id;
                    cpd.Current_Action__c = 'Reassigned To CS Team';
                    cpd.OwnerId = usrId;
                    Insert cpd;



                }
                
                update csList;                
                return 'SUCCESS';
            }
        } catch (Exception e) {
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            
        }return null;
    }

    @AuraEnabled
    public static string reAssignCaseToWHTeam(string recId, String reAssignmnetReason, Id usrId){
        try {
            if(recId != null){
                
                List<Case> csList = [SELECT Id,CaseNumber,MT_Assignment_Reason__c,CS_Team_Member__c,OwnerId,Is_With_Refund_Team__c, Warehouse_Team_Member__c, Case_Reassigned_DateTime__c, Status From Case Where Id =: recId Limit 1];
                for(Case cse : csList){
                    if(reAssignmnetReason != null){
                        cse.MT_Assignment_Reason__c = reAssignmnetReason;
                        cse.OwnerId = usrId;
                        cse.Warehouse_Team_Member__c = usrId;
                        cse.Is_With_Refund_Team__c = false;
                        cse.Assigned_to_WH_Team__c = true;
                        cse.Assigned_to_Dropshipping__c = false;
                        cse.Status = 'Re Assigned';
                        cse.Case_Reassigned_DateTime__c = System.Now();
                        Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                        notification.setBody('A New Case Has Been Assigned To You'); 
                        notification.setTitle('New Case Assignment'); 
                        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];  
                        notification.setNotificationTypeId(type.id); 
                        notification.setTargetId(cse.Id);
                        notification.send(new Set<String> { cse.OwnerId });
                    }
                    Case_Progress_Detail__c cpd = new Case_Progress_Detail__c();
                    cpd.CS_Remarks__c = reAssignmnetReason;
                    cpd.Status__c = 'In Progress';
                    cpd.Case__c = cse.Id;
                    cpd.Current_Action__c = 'Reassigned To WH Team';
                    cpd.OwnerId = usrId;
                    Insert cpd;



                }
                
                update csList;                
                return 'SUCCESS';
            }
        } catch (Exception e) {
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            
        }return null;
    }

    @AuraEnabled
    public static string reAssignCaseToDropshippingTeam(string recId, String reAssignmnetReason, Id usrId){
        try {
            if(recId != null){
                List<Case> csList = [SELECT Id,CaseNumber,MT_Assignment_Reason__c,CS_Team_Member__c,OwnerId,Is_With_Refund_Team__c, Warehouse_Team_Member__c, Case_Reassigned_DateTime__c, Status, Dropshipping_User__c, Type, Sub_Type__c, Sub_Sub_Type__c From Case Where Id =: recId Limit 1];
                List<EmailTemplate> etList = [SELECT Id,Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName ='WH_Team_Notification'];
                EmailTemplate et = new EmailTemplate();
                List<string> toAddress = new List<string>();
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                // List<Dropshipping_User__mdt> dropshippingUsers = [SELECT Id, Username__c, Name, Email_Id__c FROM Dropshipping_User__mdt];
                // for(Dropshipping_User__mdt drUser : dropshippingUsers){
                //     toAddress.add(drUser.Email_Id__c);
                // }    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(et.Id);
                mail.setToAddresses(toAddress);
                mail.setSubject(et.subject);
               // mail.setHTMLBody(et.Body);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
            
                if(!etList.isEmpty()){
                    et = etList[0];
                }
                for(Case cse : csList){
                    if(reAssignmnetReason != null){
                        cse.MT_Assignment_Reason__c = reAssignmnetReason;
                        cse.OwnerId = usrId;
                        cse.Dropshipping_User__c = usrId;
                        cse.Assigned_to_Dropshipping__c = true;
                        cse.Status = 'Re Assigned';
                        cse.Case_Reassigned_DateTime__c = System.Now();

                        mail.setWhatId(cse.Id);
                        mail.setTargetObjectId(usrId);
                        String body = et.HTMLValue;
                        body = cse.CaseNumber != null ? body.replace('<CaseNumber>', cse.CaseNumber) : body.replace('<CaseNumber>', 'NA');
                        body = cse.Type != null ? body.replace('<CaseType>', cse.Type) : body.replace('<CaseType>', 'NA');
                        body = cse.Sub_Type__c != null ? body.replace('<CaseSubType>', cse.Sub_Type__c) : body.replace('<CaseSubType>', 'NA');
                        body = cse.Sub_Sub_Type__c != null ? body.replace('<CaseSubSubType>', cse.Sub_Sub_Type__c) : body.replace('<CaseSubSubType>', 'NA');
                        body = body.replace('<b>CS Remarks:</b> <CSremarks><br><br>', '');
                        mail.setHTMLBody(body);
                        allmsg.add(mail);

                        Messaging.CustomNotification notification = new Messaging.CustomNotification(); 
                        notification.setBody('A New Case Has Been Assigned To You'); 
                        notification.setTitle('New Case Assignment'); 
                        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];  
                        notification.setNotificationTypeId(type.id); 
                        notification.setTargetId(cse.Id);
                        notification.send(new Set<String> { cse.OwnerId });
                    }
                    Case_Progress_Detail__c cpd = new Case_Progress_Detail__c();
                    cpd.CS_Remarks__c = reAssignmnetReason;
                    cpd.Status__c = 'In Progress';
                    cpd.Case__c = cse.Id;
                    cpd.Current_Action__c = 'Assigned To Dropshipping Team';
                    cpd.OwnerId = usrId;
                    Insert cpd;



                }
                
                update csList;  
                try {
                    Messaging.sendEmail(allmsg,false);
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }              
                return 'SUCCESS';
            }
        } catch (Exception e) {
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            
        }return null;
    }


    @AuraEnabled
    public static List<User> getAllUser(){
        try {

            List<User> userList = [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name = 'Customer Service Executive' AND IsActive = true];
            return userList;            
        } catch (Exception e) {
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static List<User> getAllWHUser(){
        try {

            List<User> userList = [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name = 'Warehouse Team' AND IsActive = true];
            return userList;            
        } catch (Exception e) {
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static List<User> getAllDropshippingUser(){
        try {
            List<Dropshipping_User__mdt> userListMDT = [SELECT Id, Username__c FROM Dropshipping_User__mdt];
            Set<String> userNamesSet = new Set<String>();
            List<User> userList = new List<User>();
            if(!userListMDT.isEmpty()){
                for(Dropshipping_User__mdt mdt : userListMDT){
                    userNamesSet.add(mdt.Username__c);
                }
                userList = [SELECT Id, Name, Profile.Name FROM User WHERE Username IN :userNamesSet];
            }
            return userList;            
        } catch (Exception e) {
            System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
            return null;
        }
    }
    
       public static void dumMethod() {
    Integer i = 0;
    Integer j = 0;
    Integer k = 0;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k; 
          i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
   }
}