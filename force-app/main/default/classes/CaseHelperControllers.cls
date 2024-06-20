public class CaseHelperControllers {
    
    @AuraEnabled(cacheable = true)
    public static List<String> getAllProfileNames() {
        List<String> profileNames = new List<String>();
        
        for (Profile prof : [SELECT Name FROM Profile]) {
            profileNames.add(prof.Name);
        }
        
        return profileNames;
    }

    @AuraEnabled
    public static void closeCase(String caseId){
        try {
            Case caseRec = new Case();
            caseRec.Id = caseId;
            caseRec.Status = 'Closed';
            update caseRec;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static boolean manualCaseShare(String recordId, String userOrGroupId){
        CaseShare cshare = new CaseShare();
        cshare.CaseId = recordId;
        cshare.UserOrGroupId = userOrGroupId;
        cshare.CaseAccessLevel = 'Edit';
        cshare.RowCause = 'manual';
        Database.SaveResult sr = Database.insert(cshare,false);
        
        if(sr.isSuccess()){
            return true;
        }else {
            
            Database.Error err = sr.getErrors()[0];
            
            if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  err.getMessage().contains('AccessLevel')){
                return true;
            }
            else{
                return false;
            }
        }
    }
    
    @AuraEnabled
    public static Case getCaseRec(String caseId){
        try{
            if(caseId != null){
                Case caseRec = [SELECT Id, Sub_Type__c, Sub_Sub_Type__c,Status,Disposition__c, Case_Category__c FROM Case WHERE Id =: caseId LIMIT 1];
                return caseRec;
            }
            return null;
        }catch(exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
            return null;
        }
    }
    /**
* Getting Field Sets
* @author Anwar Chikle
* @description Field Sets for LWC Component for Case Disposition.
*
*/
    // getting case field-set 
    @AuraEnabled
    public static List<String> getCaseFieldSetListss(){
        try{
            List<String> caseFieldSetList = new List<String>();
            List<Schema.FieldSetMember> FieldSetListFromCase  = SobjectType.Case.FieldSets.Field_set_For_Order_Related.getFields();
            for(Schema.FieldSetMember fieldsToAdd : FieldSetListFromCase){
                caseFieldSetList.add(String.valueOf(fieldsToAdd.sobjectfield));
            }
            if(caseFieldSetList.size()>0){
                return caseFieldSetList;
            }
        }catch(Exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
    }
    /**
* Getting Field Sets
* @author Anwar Chikle
* @description Field Sets for LWC Component for Child Case Creation.
*
*/
    
    //Getting Status field
    @AuraEnabled
    public static void updateStatusfield(String recId,String Status){
        try {
            case recordToupdate = [Select Id,Status from case WHERE Id =: recId];
            recordToupdate.Status =  Status;
            update recordToupdate;       
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
    }
    // Case status
    @AuraEnabled
    public static Case loadcasestatus (String recordId){
        try {
            Case loadcastatus = [SELECT Id, Status FROM Case WHERE Id = :recordId];
            return loadcastatus;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
    }
    
    
    
    // getting case field-set 
    @AuraEnabled
    public static List<String> getCaseFieldSetList(){
        try{
            List<String> caseFieldSetList = new List<String>();
            List<Schema.FieldSetMember> FieldSetListFromCase  = SobjectType.Case.FieldSets.Field_Set_For_Case_Child_Creation.getFields();
            for(Schema.FieldSetMember fieldsToAdd : FieldSetListFromCase){
                caseFieldSetList.add(String.valueOf(fieldsToAdd.sobjectfield));
            }
            if(caseFieldSetList.size()>0){
                return caseFieldSetList;
            }
        }catch(Exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
    }
    /**
* Getting All Fields of Case Object
* @author Anwar Chikle
* @description To Display Fields Of Case Obj for field sets itself.
*
*/
    
    @AuraEnabled
    public static List<String> getAllCaseFields() {
        
        try{
            List<String> allAPInames = new List<String>();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType sobjSchema = schemaMap.get('Case');
            Map<String, Schema.SObjectField> fieldMap = sobjSchema.getDescribe().fields.getMap();            
            for (SObjectField field: fieldMap.values()) {  
                DescribeFieldresult fieldDesc = field.getDescribe();
                String fieldName = fieldDesc.getName();
                allAPInames.add(fieldName);
                //System.debug('fieldName==> ' + fieldName);
            }
            return allAPInames;   
        }
        catch(exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number ==> ' + e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static Id getRecrdTypeId(String recordId){
        
        return [SELECT Id,RecordTypeId FROM Case where Id =: recordId LIMIT 1].RecordTypeId;
    }
    @AuraEnabled
    public static Id getRecrdTypeIdChat(){
        
        return [SELECT Id,RecordTypeId FROM Case LIMIT 1].RecordTypeId;
    }
    
    @AuraEnabled
    public static Case caseRecord(String caseId){
        case cs =  [SELECT Id,RecordTypeId,Parent_Case__c FROM Case where Id =: caseId];
        return cs;
        
    }
    @AuraEnabled
    public static Case getCaseRecord(String caseId){
        case cs =  [SELECT Id,RecordTypeId,Parent_Case__c,Sub_Type__c,Sub_Sub_Type__c,OwnerId,Subject,Status,Origin,AccountId,Contact_Number__c,ContactId,Owner.Name FROM Case where Id =: caseId];
        return cs;
        
    }
    
    @AuraEnabled
    public static Case getCaseRecords(){
        case cs =  [SELECT Id,RecordTypeId,Parent_Case__c,Sub_Type__c,Sub_Sub_Type__c,OwnerId,Subject,Status,Origin,AccountId,Contact_Number__c,ContactId,Owner.Name FROM Case LIMIT 1];
        return cs;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ObjectType> getCaseRecordTypes() {
        List<ObjectType> recordTypes = new List<ObjectType>();
        
        try {
            Schema.SObjectType caseType = Schema.getGlobalDescribe().get('Case');
            Map<String, Schema.RecordTypeInfo> rtInfos = caseType.getDescribe().getRecordTypeInfosByName();
            
            for (String rtName : rtInfos.keySet()) {
                Schema.RecordTypeInfo rtInfo = rtInfos.get(rtName);
                ObjectType objType = new ObjectType(rtInfo.getRecordTypeId(), rtInfo.getName());
                recordTypes.add(objType);
            }
        } catch (Exception e) {
            // Handle exception if necessary
            System.debug('Exception: ' + e.getMessage());
        }
        
        return recordTypes;
    }
    
    @AuraEnabled(cacheable=true)
    public Static Map<Id, String> getAllRT(){
        String objectAPIName = 'Case' ;
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get(objectAPIName).getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<Id,String> mapOfRecordTypeIdWithName = new Map<Id, String>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapOfRecordTypeIdWithName.put(info.getRecordTypeId(), info.getName());
        }
        return mapOfRecordTypeIdWithName;
        
    }
    
    // Inner class to represent record types
    public class ObjectType {
        @AuraEnabled public String value;
        @AuraEnabled public String label;
        
        public ObjectType(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> dependentFields(){
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Case');
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get('Sub_Type__c').getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get('Sub_Sub_Type__c').getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for(Schema.PicklistEntry currControllingValue : controllingValues)
        {
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);
            
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
                    
            Integer baseCount = 0;
            
            for(Integer curr : hexString.getChars())
            {
                Integer val = 0;
                
                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }
                
                if((val & 8) == 8)
                {
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4)
                {
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2)
                {
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1)
                {
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                }
                
                baseCount += 4;
            }            
        }
                
        return controllingInfo;
    }
    class MyPickListInfo {
        public String active {get; set;}
        public String defaultValue {get; set;}
        public String label {get; set;}
        public String value {get; set;}
        public String validFor {get; set;}
    }
    
    @AuraEnabled
    public static string reOpenCase(String RecId, String Reason){
        try {
            Case Cs = new Case();
            Cs.Id = RecId;
            Cs.OwnerId = userInfo.getUserId();
            update Cs;
            set<Id> setOfOwnerId = new set<Id>();
            if(Reason != null){                   
                cs.Status = 'Re-Opened';
                cs.Re_Opening_Reason__c = Reason;  
            }
            update cs;
            Case cseList = [SELECT Id,ContactId,Contact.Email,OwnerId,Owner.email From Case Where Id =: cs.Id];
            String CaseOwnId = cseList.Owner.email;
            
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
            // notification to user
            notification.setBody('An Old Case Has been Re-Opened. Please check the details.');
            notification.setTitle('Dear User, An Old Case Has been Re-Opened.');
            notification.setSenderId(UserInfo.getUserId());
            notification.setNotificationTypeId(customNotiList.Id); 
            notification.setTargetId(cs.Id);
            if(cseList.OwnerId != null){
                notification.send(new set<String>{cseList.OwnerId});
            }
            
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate temp = [SELECT Id,Subject, Body FROM EmailTemplate WHERE Name ='child case creation'];
            List<String> setToAdresses = new List<String>();
            setToAdresses.add(CaseOwnId);
            String body = temp.body;
            if(CaseOwnId != null){
                Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage(); 
                body = body.replace('{!Case.Id}',cseList.Id);
                mailTemp.setPlainTextBody(body);
                mailTemp.setTemplateId(temp.id);
                mailTemp.setTargetObjectId(cseList.ContactId);
                mailTemp.setToAddresses(setToAdresses);
                mailTemp.setSaveAsActivity(false);
                mailTemp.setWhatId(cseList.Id);
                mails.add(mailTemp);
            }
            
            if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Exception type caught: ' + e.getTypeName());    
            System.debug('Message: ' + e.getMessage());    
            System.debug('Cause: ' + e.getCause());    // returns null
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());  
            throw new AuraHandledException(e.getMessage());
            
            
        }
    }
    // handle data in 3 types
    // @AuraEnabled(cacheable=true)
    // public static String fetchDependentPicklistValues(){
    //     List<recordTypeCustomMetaData__mdt> StateCityAreaList = [SELECT Id,RecordType__c,Type__c,Sub_Type__c FROM recordTypeCustomMetaData__mdt];
    //     Map<String,List<Map<String,List<String>>>> MapOfStateCityAreaList = new Map<String,List<Map<String,List<String>>>>();
    //     Map<String,List<String>> mapOfCityArea = new  Map<String,List<String>>();
    //     for(recordTypeCustomMetaData__mdt data : StateCityAreaList){
    //         mapOfCityArea = new Map<String,List<String>>();
    //         List<String> areaList = data.Sub_Type__c.split(','); 
    //         mapOfCityArea.put(data.Type__c,areaList);
    //         if(MapOfStateCityAreaList.containsKey(data.RecordType__c)){
    //             MapOfStateCityAreaList.get(data.RecordType__c).add(mapOfCityArea);
    //         }
    //         else{
    //             MapOfStateCityAreaList.put(data.RecordType__c,new List<Map<String,List<String>>>{mapOfCityArea});
    //         }
    //     }
    //     system.debug('MapOfStateCityAreaList == >'+MapOfStateCityAreaList);
    //     return JSON.serialize(MapOfStateCityAreaList);
    // }
    
    // handle data in 2 types
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> fetchDependentPicklist() {
        try {
            Map<String, List<String>> mapOfPicklist = new Map<String, List<String>>();
            List<recordTypeCustomData__mdt> recTypAndTypList = [SELECT Id, RecordType__c, Types__c FROM recordTypeCustomData__mdt];
            
            for (recordTypeCustomData__mdt data : recTypAndTypList) {
                List<String> listOfString = data.Types__c.split(',');
                
                if (!mapOfPicklist.containsKey(data.RecordType__c)) {
                    mapOfPicklist.put(data.RecordType__c, listOfString);
                } else {
                    mapOfPicklist.get(data.RecordType__c).addAll(listOfString);
                }
            }            
            return mapOfPicklist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String createChildCase(String RecordTypeName, String Type, String SubType, String AccId, String conId, String Subjt, String conNumber, String recId, Id ownId) {
        try {
            Case newCase = new Case();
            if (RecordTypeName != null && Type != null && SubType != null) {
                Set<Id> setOfOwnerId = new Set<Id>();
                List<Case> cseList = new List<Case>();
                RecordType rt = [SELECT Id FROM RecordType WHERE Name = :RecordTypeName LIMIT 1];
                
                newCase.RecordTypeId = rt.Id;
                newCase.Sub_Type__c = Type;
                newCase.Sub_Sub_Type__c = SubType;
                
                if(AccId != null){
                    newCase.AccountId = AccId;
                }
                if(conId != null){
                    newCase.ContactId = conId;
                }
                if(Subjt != null){
                    newCase.Subject = Subjt;
                }
                if(AccId != null){
                    newCase.Contact_Number__c = conNumber;
                }
                
                newCase.Status = 'New';
                newCase.OwnerId = ownId;
                newCase.ParentId = recId;
                
                insert newCase;
                setOfOwnerId.add(newCase.OwnerId);
                cseList.add(newCase);
                
                // Case caseRec = new Case(Id = recId, Parent_Case__c = newCase.Id);
                // update caseRec;
                // System.debug('caseRec:::::::::::>' + caseRec);
                
                Set<String> setOfUserId = new Set<String>();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
                List<User> userList = [SELECT Id, Email FROM User WHERE Email IN :setOfOwnerId];
                EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='child case creation'];
                Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                for (User us : userList) {
                    setOfUserId.add(us.Id);
                }
                
                // notification to user
                notification.setBody('A New Case Has been created. Please check the details.');
                notification.setTitle('Hi, A New Case Has been created.');
                notification.setSenderId(UserInfo.getUserId());
                notification.setNotificationTypeId(customNotiList.Id); 
                notification.setTargetId(newCase.Id);
                // email to user
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                String body = temp.body;
                body = body.replace('{!Case.Id}',newCase.Id);
                mail.setPlainTextBody(body);
                mail.setTemplateId(temp.id);
                //mail.setTargetObjectId(newCase.Id);
                mail.setToAddresses(new List<String> { UserInfo.getUserId() });
                mailList.add(mail);
                notification.send(new Set<String> { newCase.OwnerId });
                // Messaging.sendEmail(mailList);
                
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
            return null;
        }
    }
    
    
    @AuraEnabled
    public static List<Case>  getRelatedCases(String recId) {
        Case cse = [SELECT Id, CaseNumber, Subject,Order_Number__c, OrderId__r.Name,RecordType.Name,OrderId__c,Sub_Type__c,Sub_Sub_Type__c,AccountId,ContactId,Email_Id__c FROM Case WHERE Id = :recId];
        Set<Id> caseOrderIds = new Set<Id>();
        set<String> TypeString = new set<String>();
        set<String> SubTypeString = new set<String>();
        if (cse.OrderId__c != null || cse.Sub_Type__c != null) {
            caseOrderIds.add(cse.OrderId__c);
            TypeString.add(cse.Sub_Type__c);
            SubTypeString.add(cse.Sub_Sub_Type__c);
        }
        List<Case> caseList = [SELECT Id, Subject, Origin, Status, OrderId__r.OrderNumber,CaseNumber,Sub_Type__c,Sub_Sub_Type__c,RecordType.Name,RecordTypeId FROM Case WHERE OrderId__c IN :caseOrderIds AND Sub_Type__c IN: TypeString  AND  Sub_Sub_Type__c IN: SubTypeString AND ParentId = null Order By CreatedDate];
        return caseList;
    }
    @AuraEnabled
    public static List<Case>  mergeCaseBasedOnAccIdConIdEmailIdPhoneNumberInstagram(String recId) {
        Case cse = [SELECT Id, CaseNumber, SuppliedEmail, SuppliedPhone, Subject, Order_Number__c,RecordType.Name,OrderId__r.Name ,OrderId__r.OrderNumber,OrderId__c,ContactPhone,AccountId,ContactId,Email_Id__c,Contact_Number__c,ContactMobile,Instagram_ID__c FROM Case WHERE Id = :recId];
        Set<Id> caseAccountIds = new Set<Id>();
        Set<Id> caseContactIds = new Set<Id>();
        set<String> TypeString = new set<String>();
        set<String> EmailString = new set<String>();
        set<String> PhoneString = new set<String>();
        set<String> MobileString = new set<String>();
        set<String> InstagramString = new set<String>();
        set<String> contactNumberString = new set<String>();
        if (cse.AccountId != null || cse.ContactId != null || cse.Email_Id__c != null || cse.ContactPhone != null || 
            cse.Instagram_ID__c != null || cse.ContactMobile != null || cse.Contact_Number__c != null || cse.SuppliedEmail != null || cse.SuppliedPhone != null){
                caseAccountIds.add(cse.AccountId);
                caseContactIds.add(cse.ContactId);
                EmailString.add(cse.Email_Id__c);
                EmailString.add(cse.SuppliedEmail);
                // PhoneString.add(cse.ContactPhone);
                InstagramString.add(cse.Instagram_ID__c);
                // MobileString.add(cse.ContactMobile);
                contactNumberString.add(cse.Contact_Number__c);
                contactNumberString.add(cse.SuppliedPhone);
                
            }
        
        List<Case> caseList = [SELECT Id, Subject, Origin, Status,OrderId__r.Name, Order_Number__c,RecordType.Name,OrderId__r.OrderNumber,CaseNumber,Sub_Type__c,Sub_Sub_Type__c,ContactPhone,
                               Account.Name,AccountId,Contact.Name,ContactId,Email_Id__c,Contact_Number__c,ContactMobile,Instagram_ID__c FROM Case WHERE 
                               (AccountId IN :caseAccountIds OR ContactId IN :caseContactIds OR Email_Id__c IN :EmailString OR SuppliedEmail IN: emailString
                                OR Contact_Number__c IN :contactNumberString OR SuppliedPhone IN :contactNumberString OR Instagram_ID__c IN :InstagramString) AND Status != 'Closed' Order By CreatedDate];
        return caseList;
    }
     
    @AuraEnabled
    public static String mergeDuplicateCases(List<String> cases) {
        try{
            String caseId; 
            String caseNo; 
            List<Case> cseList = [SELECT Id,Status,CreatedDate,caseNumber,Case_Reason_Description__c From Case Where Id IN: cases Order By CreatedDate ASC];
            caseId = cseList[0].Id;
            caseNo = cseList[0].caseNumber;
            List<Case> updatingCaseList = new List<Case>();
            for(Case cse : cseList){
                if(cse.Id != caseId){
                    cse.Status = 'Closed';
                    cse.Case_Reason_Description__c =  'Closed as Duplicate Case Under Case No.' + caseNo;
                    updatingCaseList.add(cse);
                }
            }
            update updatingCaseList;
            return 'SUCCESS';
        }catch(Exception e ){
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Case> mergeSelectedCases(String caseId, List<Case> cases) {

        Set<Id> setOfCaseId = new Set<Id>();
        List<String> caseIdList = caseId.split(',');
        for (String cs : caseIdList) {
            setOfCaseId.add(cs);
        }        
        Set<Id> caseIdsToMerge = new Set<Id>();
        for (Case cs : cases) {
            caseIdsToMerge.add(cs.Id);
        }
        
        caseIdsToMerge.removeAll(setOfCaseId);
        
        List<Case> casesToMerge = [SELECT Id, CaseNumber, Subject, Origin, Status, OrderId__r.OrderNumber, ParentId FROM Case WHERE Id IN :caseIdsToMerge];
        List<Case> casesToUpdate = new List<Case>();
        
        for (Case c : casesToMerge) {
            c.ParentId = setOfCaseId.isEmpty() ? null : setOfCaseId.iterator().next();
            casesToUpdate.add(c);
        }
        
        update casesToUpdate;
        return casesToUpdate;
    }
    
    @AuraEnabled
    public static Case courierRelatedCase(String recId) {
        try {
            // Use Database.queryById to handle potential exceptions if record not found
            Case cse = [SELECT Id, Address_With_Pin_Code__PostalCode__s, Address_With_Pin_Code__Street__s, Address_With_Pin_Code__City__s, Address_With_Pin_Code__StateCode__s, 
                        Address_With_Pin_Code__CountryCode__s, Address_With_Pin_Code__Latitude__s, Address_With_Pin_Code__Longitude__s, Address_With_Pin_Code__GeocodeAccuracy__s, 
                        Address_With_Pin_Code__c FROM Case where Id =:recId];
            if (cse != null) {
                return cse;
            }
        } catch (QueryException e) {
            System.debug('Error fetching Case record: ' + e.getMessage());
        }
        return null; // If record not found or other error occurs
    }
    
    
    @AuraEnabled
    public static String updateCaseAndOrder(String recId) {
        Case cse = [SELECT Id, ContactId, OrderId__c,Address_With_Pin_Code__Street__s,Address_With_Pin_Code__City__s,Contact_Number__c,
                    Address_With_Pin_Code__PostalCode__s,Address_With_Pin_Code__CountryCode__s,Address_With_Pin_Code__StateCode__s FROM Case WHERE Id = :recId LIMIT 1];
        if (cse != null) {
            if(cse.ContactId != null){
                Contact conRec = [SELECT Id FROM Contact WHERE Id = :cse.ContactId LIMIT 1];
                if (conRec != null) {
                    conRec.Phone = cse.Contact_Number__c;
                    update conRec;
                }
            }
            
            
            if(cse.OrderId__c != null){
                Order ordRec = [SELECT Id FROM Order WHERE Id = :cse.OrderId__c LIMIT 1];
                if (ordRec != null) {
                    ordRec.ShippingStreet = cse.Address_With_Pin_Code__Street__s;
                    ordRec.ShippingState = cse.Address_With_Pin_Code__StateCode__s;
                    ordRec.ShippingCity = cse.Address_With_Pin_Code__City__s;
                    ordRec.ShippingCountry = cse.Address_With_Pin_Code__CountryCode__s;
                    ordRec.ShippingPostalCode =  cse.Address_With_Pin_Code__PostalCode__s;
                    update ordRec;
                }
            }
            
            
            return 'SUCCESS';
        } else {
            return 'ERROR: Case not found';
        }
    }
    
    @AuraEnabled
    public static String sendNotificationToOrderManagementTeam(String recId){
        try{
            List<Case> caseList = [SELECT Id,Status From Case Where Id=:recId];
            List<CustomNotificationType > TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='custom_notification_to_refund_team_on_pincode_not_serviceable'];
            List<Messaging.CustomNotification> notificationList = new List<Messaging.CustomNotification>();
            
            List<User> userist = [SELECT Id,Name,Email,Profile.Name From User Where Profile.Name = 'Order Management Team'];
            Set<String> OrderManagementTeamUsers = new Set<String>();
            for(User usr : userist){
                OrderManagementTeamUsers.add(usr.Id);
            }
            for (Case cse : caseList) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                
                notification.setBody('A new Case Has been Assigned to you Please go through it and resolve it ASAP');
                notification.setTitle('Assigned To Marketing Team');
                notification.setSenderId(UserInfo.getUserId());
                notification.setNotificationTypeId(TemplateInfoDetail[0].Id);
                notification.setTargetId(cse.Id);
                notification.send(OrderManagementTeamUsers);
            }
            return 'SUCCESS';
        }catch(Exception e){
            system.debug('Line Number'+ e.getLineNumber());
            return null;
        }
    }
    
    
    // Method to get Profile Name & its User List
    @AuraEnabled 
    public static Map<String,List<User>> getProfileBasedUserList(){
        try{
            Map<String, List<User>> profileUserMap = new Map<String, List<User>>();
            String ProfileNamesString = System.Label.profile_names;
            Set<String> ProfilenamesList = new Set<String>();
            ProfilenamesList.addAll(ProfileNamesString.split(',')); 
            List<User> userList = [SELECT Id, Name, Profile.Name FROM User WHERE Profile.Name IN:ProfilenamesList];
            for(User u : userList) {
                String profileName = u.Profile.Name;
                if(!profileUserMap.containsKey(profileName)) {
                    profileUserMap.put(profileName, new List<User>());
                }
                profileUserMap.get(profileName).add(u);
            }
            if(profileUserMap.size()>0){
                return profileUserMap;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
   /* @AuraEnabled
    public static string returnToOrigin(String recId, String reasonForRto, String rtoResolution){
        try {
            List<User> CsTeamUserList = [SELECT Id,Name,Profile.Name,Email From User Where Profile.Name =:'Customer Service Executive' AND Name Like '%Aisha%' LIMIT 1];
            Case cs = new Case();
            cs.RTO_Reso__c = rtoResolution;
            cs.Reason_for_RTO__c = reasonForRto;
            cs.Id = recId;
            cs.OwnerId = CsTeamUserList[0].Id;
            update cs;
            
            List<Case> csList = [SELECT Id,OrderId__c,ContactId,CreatedDate,OwnerId,AccountId,Reason_for_RTO__c From Case Where Id=: recId LIMIT 1];
            
            set<Id> setOfOrderId = new set<Id>();
            set<Id> setOfContact = new set<Id>();
            set<Id> setOfAccount = new set<Id>();
            for(case cse : csList){
                if(cse.AccountId != null){
                    setOfAccount.add(cse.AccountId);
                }else if(cse.ContactId != null){
                    setOfContact.add(cse.ContactId);
                }
                if(cse.OrderId__c != null){
                    setOfOrderId.add(cse.OrderId__c);
                }
            }
            
            List<Order> ListOfOrder = [SELECT Id,OrderNumber,Total_Amount__c,Refund_Amount__c,TotalAmount,Reason_for_RTO__c From Order Where Id IN: setOfOrderId LIMIT 1];
            
            List<Order> ordList = new List<Order>();
            for(Order ord : ListOfOrder){
                order updatingOrder = new order();
                updatingOrder.Id = ord.Id;
                updatingOrder.Refund_Amount__c = ord.Refund_Amount__c;
                updatingOrder.Total_Amount__c = ord.TotalAmount;
                updatingOrder.Reason_for_RTO__c = reasonForRto;
                ordList.add(updatingOrder);
            }
            if(ordList.size() > 0){
                update ordList;
            }
            List<OrderItem> OrderItemList = [SELECT Id,OrderId,TotalPrice,Refund_Price__c From OrderItem  Where OrderId IN: setOfOrderId];
            if(OrderItemList.size()>0){
                List<OrderItem> ordItmList = new List<OrderItem>();
                for(OrderItem ordItm : OrderItemList){
                    OrderItem orIt = new OrderItem();
                    orIt.Refund_Reason__c = reasonForRto;
                    orIt.Id = ordItm.Id;
                    orIt.Reason_for_RTO__c = reasonForRto;
                    orIt.Refund_Price__c = ordItm.TotalPrice;
                    ordItmList.add(orIt);
                }
                if(ordItmList.size() > 0){
                    update ordItmList;
                }
            }
                        
            set<String> CsTeamUsers = new set<String>();
            List<String> CsTeamUsersInList = new List<String>();
            List<Id> CsteamTaskUsers = new List<Id>();
            
            for(User usr : CsTeamUserList){
                CsTeamUsers.add(usr.Id);
                CsTeamUsersInList.add(usr.Email);
                CsteamTaskUsers.add(usr.id);
            }
            
            
            List<CustomNotificationType > TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='custom_notification_to_refund_team_on_pincode_not_serviceable'];
            
            List<String> emailString1 = new List<String>();
            Map<Id,Contact> mapOfContact = new Map<Id,Contact>();
            Map<Id,Account> mapOfAccount = new Map<Id,Account>();
            
            List<Contact> conList =[SELECT Id,Name,Email From Contact Where Id IN:setOfContact];
            List<Account> accList =[SELECT Id,Name,Email__c From Account Where Id IN:setOfAccount];
            
            EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'ReturnToOriginForCustomer'];
            EmailTemplate Reftemp = [SELECT Id, Name, DeveloperName, Subject, Body, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'ReturnToOriginForRefundTeam'];
            OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='refund team'];
            
            Map<Id,Order> mapOfOrd = new Map<Id,Order>();
            List<Order> orderList = [SELECT Id,CreatedDate,OrderNumber,Refund_Amount__c From Order Where Id IN:setOfOrderId];
            for(Order ord : orderList){
                if(!mapOfOrd.containsKey(ord.Id)){
                    mapOfOrd.put(Ord.Id,Ord);
                }
            }
            
            for(Contact con : conList){
                mapOfContact.put(con.Id, con);
            }
            for(Account acc : accList){
                mapOfAccount.put(acc.Id, acc);
            }
            List<String> emailString = new List<String>();
            
            List<task> taskList = new List<task>();
            String body = temp.body;
            String body1 = Reftemp.body;
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> mailListToRefundTeam = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> mailListToCsTeam = new List<Messaging.SingleEmailMessage>();
            for (Case cse : csList) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Messaging.SingleEmailMessage mailToRefundUser = new Messaging.SingleEmailMessage();
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                Messaging.CustomNotification WareHouseNotification = new Messaging.CustomNotification();
                
                if (cse.OrderId__c != null) {
                    Body = Body.replace('{!Case.OrderId__c}', String.valueOf(mapOfOrd.get(cse.OrderId__c).OrderNumber));
                }
                if(mapOfOrd.get(cse.OrderId__c).Refund_Amount__c != null){
                    body1 = body1.replace('{!Case.Order__r}', String.valueOf(mapOfOrd.get(cse.OrderId__c).Refund_Amount__c));
                }
                
                if (cse.Reason_for_RTO__c != null) {
                    Body = Body.replace('{!Case.Reason_for_RTO__c}', cse.Reason_for_RTO__c);
                }
                
                if (cse.OrderId__c != null) {
                    body1 = body1.replace('{!Case.OrderId__c}', String.valueOf(mapOfOrd.get(cse.OrderId__c).OrderNumber));
                }if(mapOfOrd.get(cse.OrderId__c).Refund_Amount__c != null){
                    body1 = body1.replace('{!Case.Order__r}', String.valueOf(mapOfOrd.get(cse.OrderId__c).Refund_Amount__c));
                }
                
                if (cse.Reason_for_RTO__c != null) {
                    body1 = body1.replace('{!Case.Reason_for_RTO__c}', cse.Reason_for_RTO__c);
                }
                
                mailToRefundUser.setSubject(Reftemp != null ? Reftemp.Subject : '');
                mailToRefundUser.setPlainTextBody(body1);
                mailToRefundUser.setTemplateId(Reftemp != null ? Reftemp.Id : null);
                mailToRefundUser.setSaveAsActivity(true);
                mailToRefundUser.setWhatId(cse.Id);
                //mailToRefundUser.setorgwideemailaddressid(owea.id);
                mailToRefundUser.setToAddresses(CsTeamUsersInList);
                mailListToCsTeam.add(mailToRefundUser);
                
                notification.setBody('Dear CS teams,Please Check For this Case As the Case is Returned To Origin'); 
                notification.setTitle('Return To Origin'); 
                notification.setSenderId(Userinfo.getUserId()); 
                notification.setNotificationTypeId(TemplateInfoDetail[0].id); 
                notification.setTargetId(cse.id);
                notification.send(CsTeamUsers);
                
                task tsk = new task();
                tsk.subject ='Return To Origin';
                tsk.Priority = 'High';
                tsk.ActivityDate = System.today().addDays(2);
                tsk.whatId =   cse.Id;
                tsk.OwnerId = CsteamTaskUsers[0];
                taskList.add(tsk);
            }
            if(mailListToCsTeam.size()>0){
                Messaging.SendEmail(mailListToCsTeam);
            }
            if(taskList.size()>0){
                Insert taskList;
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('e.getLineNumber::::::::::::>' + e.getLineNumber() + ' e.getMessage::::::>' + e.getMessage());
            return null;
        }
    } */
    
    @AuraEnabled(cacheable=true)
    public static createDupLicateWrapper showAllCaseData(String recId) {
        try {
            if (String.isNotBlank(recId)) {
                createDupLicateWrapper oosWr = new createDupLicateWrapper();
                //AND OrderId__r.OrderNumber != null AND Order_Date__c != null AND OrderId__r.OrderNumber != null
                Case caseRec = [SELECT Id, CaseNumber, OrderId__r.OrderNumber, OrderId__r.Status, OrderId__c, Order_Date__c, Status, ContactId, Reason_for_RTO__c,Contact.Email FROM Case WHERE Id = :recId  LIMIT 1 ];
                oosWr.caseRec = caseRec;
                if (caseRec.OrderId__c != null) {
                    List<OrderItem> oliList = [SELECT Id, Product2.Name, Quantity, TotalPrice, OrderID, OriginalOrderItemId, Is_Duplicate_Order__c, PricebookEntryId, Product2Id, ListPrice, UnitPrice, Refund_Quantity__c FROM OrderItem WHERE OrderID = :caseRec.OrderId__c];
                    if (!oliList.isEmpty()) {
                        oosWr.oliList = oliList;
                    }
                }
                return oosWr;
            }
            return null;
        } catch (Exception e) {
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
            return null;
        }
    }
    
    public class createDupLicateWrapper {
        @AuraEnabled
        public Case caseRec;
        @AuraEnabled
        public List<OrderItem> oliList;
    }
    
    @AuraEnabled
    public static List<OrderItem> getAllRelatedOrderItems(String OrdId){
        try{
            return [SELECT Id, OrderItemNumber, SKU__c,Product_Name__c, UnitPrice, Description,Quantity FROM OrderItem WHERE OrderId = :OrdId];
        } catch(Exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
            return null;
        }
    }
    
    
    @AuraEnabled
    public static List<OrderItem> getOrderItems(String OrdId){
        system.debug('OrdId ===========>' +OrdId);
        List<OrderItem> orderItems = new List<OrderItem>(); // Define the list outside the try-catch block
        try {
            
            Order orderRec = new Order();
            List<OrderItem> itmList = new List<OrderItem>();
            Set<Id> subOrderIds = new Set<Id>();
            
            if(OrdId != null){
                orderRec = [SELECT Id, Name, ParentOrder__c FROM Order WHERE Id =: OrdId];
            }
            if(orderRec.ParentOrder__c == null){
                List<Order> subOrderList = [SELECT Id FROM Order WHERE ParentOrder__c =: orderRec.Id];
                if(!subOrderList.isEmpty()){
                    for(Order orderRecord : subOrderList){
                        subOrderIds.add(orderRecord.Id);
                    }
                }
                if(!subOrderIds.isEmpty()){
                    itmList = [SELECT Id,Refunded_Price__c,Status__c, SKU__C,OrderId,product2.Name,Order.ParentOrder__c,product2Id,Order.Name,Order.OrderNumber, Order.ParentOrder__r.Paid_Amount__c, Order.ParentOrder__r.CreatedDate, Order.CreatedDate,Order.Paid_Amount__c, Order.ParentOrder__r.Name, Order.ParentOrder__r.OrderNumber FROM OrderItem  Where OrderId IN: subOrderIds];
                }
            }else{
                itmList = [SELECT Id,Refunded_Price__c,SKU__C,OrderId,Status__c, product2.Name,product2Id,Order.Name,Order.OrderNumber,Order.ParentOrder__c, Order.ParentOrder__r.Paid_Amount__c, Order.CreatedDate,Order.Paid_Amount__c, Order.ParentOrder__r.CreatedDate, Order.ParentOrder__r.OrderNumber FROM OrderItem  Where OrderId =: OrdId];
            }
            
            return itmList;
            // if (OrdId != null) {
            //     orderItems = [SELECT Id, Product2.Name, Quantity, Refund_Quantity__c, TotalPrice, Refund_Price__c, Refund_Reason__c, Refund_Reasons__c, Refund_Type__c, SKU__c, Total_Selling_Price__c, Selling_Price__c,Affected_Quantity__c FROM OrderItem WHERE OrderId = :OrdId];
            // }
        } catch (Exception e) {
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
            return null; // Return null if an exception occurs
        }
    }
    
    
    @AuraEnabled
    public static Case createCaseInLiveChatTranscript(String RecordTypeName, String Type, String SubType, String AccId, String conId, String Subjt, String conNumber, String recId, Id ownId, String ordId) {
        try {
            Case newCase = new Case();
                Set<Id> setOfOwnerId = new Set<Id>();
                List<Case> cseList = new List<Case>();
                List<User> usr = new List<User>();
                List<Order> ordList = new List<Order>();
                List<Account> accList = new List<Account>();
               //RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = :RecordTypeName LIMIT 1];
                
                // newCase.RecordTypeId = rt.Id;
                // newCase.Sub_Type__c = Type;
                // newCase.Sub_Sub_Type__c = SubType;
                
                if(ordId != null){
                    ordList = [SELECT Id,Name,orderNumber, AccountId From Order Where Id =: ordId Limit 1 ];
                    if(ordList.size()>0){
                        newCase.AccountId = ordList[0].AccountId;
                        
                    }
                }else{
                    if(AccId != null){
                        newCase.AccountId = AccId;
                    }
                }
                            
                if(conId != null){
                    newCase.ContactId = conId;
                }
                newCase.Subject = 'Manual Case Creation';
                if(conNumber != null){
                    newCase.Contact_Number__c = conNumber;
                    newCase.SuppliedPhone = conNumber;
                }
                newCase.Status = 'New';
                if(ownId != null){
                    newCase.OwnerId = ownId;
                }else{
                    newCase.OwnerId = UserInfo.getUserId();
                }
                newCase.Communication_Mode__c = 'Chat';
                insert newCase;
                setOfOwnerId.add(newCase.OwnerId);
                cseList.add(newCase);
                
               // LiveChatTranscript LCTRec = new LiveChatTranscript(Id = recId, CaseId = newCase.Id);
               // update LCTRec;
               // System.debug('LCTRec:::::::::::>' + LCTRec);
                
                Set<String> setOfUserId = new Set<String>();
                 Messaging.CustomNotification notification = new Messaging.CustomNotification();
                // List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
                List<User> userList = [SELECT Id, Email FROM User WHERE Email IN :setOfOwnerId];
                // EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='child case creation'];
                // Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                for (User us : userList) {
                    setOfUserId.add(us.Id);
                }
                
                if(newCase.OwnerId != null){
                    usr = [SELECT Id,Name,Email From User Where Id=:newCase.OwnerId Limit 1];
                }
                
                // notification to user
                notification.setBody('A New Case Has been created. Please check the details.');
                notification.setTitle('Hi, A New Case Has been created.');
                notification.setSenderId(usr[0].Id);
                notification.setNotificationTypeId(customNotiList.Id); 
                notification.setTargetId(newCase.Id);
                // email to user
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                // String body = temp.body;
                // body = body.replace('{!Case.Id}',newCase.Id);
                // mail.setPlainTextBody(body);
                // mail.setTemplateId(temp.id);
                // //mail.setTargetObjectId(newCase.Id);
                // mail.setToAddresses(new List<String> {usr[0].Email});
                // mailList.add(mail);
                
                notification.send(new Set<String> { newCase.OwnerId });
               // Messaging.sendEmail(mailList);
            // List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(mailList);
            // for(Messaging.SendEmailResult result : sendResults) {
            //     System.debug('result === >'+result);
            //     if(result.isSuccess()) {
            //         System.debug('Email sent successfully.');
            //         return newCase;
            //     } else {
            //         System.debug('Failed to send email: ' + result.getErrors()[0].getMessage());
            //     }
            // }
           // return newCase;
        } catch (Exception e) {
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
        }
         return null;
    }
    
    @AuraEnabled
    public static Case createCaseFromContact(String Subjt, String conNumber, String recId, String ordId) {
        try {
            
            List<Order> ord = new List<Order>();
            List<Contact> con = new List<Contact>();
            if(recId != null){
                con = [SELECT Id,Name,AccountId From Contact Where Id =: recId LIMIT 1];
            }
            
            if(ordId != null){
                 ord = [SELECT Id,AccountId From Order where Id =: ordId LIMIT 1];
                 
            }
            
            
            
            Case newCase = new Case();
            
            Set<Id> setOfOwnerId = new Set<Id>();
            List<Case> cseList = new List<Case>();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Inbound Case' LIMIT 1];
            if(ord.size()>0){
                newCase.OrderId__c = ord[0].Id;
                newCase.RecordTypeId = rt.Id;
                if(ord[0].AccountId != null){
                    newCase.AccountId = ord[0].AccountId;
                }
                
            }else{
                newCase.RecordTypeId = rt.Id;
                if(con[0].AccountId != null){
                    newCase.AccountId = con[0].AccountId;
                }
                
            }
            
            
            newCase.Subject = 'Manual Case Creation';
            
            if(conNumber != null){
                newCase.SuppliedPhone = conNumber;
                newCase.Contact_Number__c = conNumber;
            }
            if(recId != null){
                newCase.contactId = recId;
            }
            
            newCase.Status = 'New';
            newCase.OwnerId = UserInfo.getUserId();
            
            
            insert newCase;
            setOfOwnerId.add(newCase.OwnerId);
            cseList.add(newCase);
            
            
            Set<String> setOfUserId = new Set<String>();
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            // List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
            List<User> userList = [SELECT Id, Email FROM User WHERE Email IN :setOfOwnerId];
            //EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='child case creation'];
            //Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
            for (User us : userList) {
                setOfUserId.add(us.Id);
            }
            
            User usr = [SELECT Id,Name,Email From User Where Id=: newCase.OwnerId];
            // notification to user
            notification.setBody('A New Case Has been created. Please check the details.');
            notification.setTitle('Hi, A New Case Has been created.');
            notification.setSenderId(usr.Id);
            notification.setNotificationTypeId(customNotiList.Id); 
            notification.setTargetId(newCase.Id);
            // email to user
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // String body = temp.body;
            // body = body.replace('{!Case.Id}',newCase.Id);
            // mail.setPlainTextBody(body);
            // mail.setTemplateId(temp.id);
            // //mail.setTargetObjectId(newCase.Id);
            // mail.setToAddresses(new List<String> {usr.Email});
            // mailList.add(mail);
            
            // System.debug('notification:::::::::::>' + notification);
             notification.send(new Set<String> { newCase.OwnerId });
            // Messaging.sendEmail(mailList);
            
            
            return newCase;
        } catch (Exception e) {
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static Case createCaseFromAccount(String Subjt, String conNumber, String recId, String ordId) {
        try {
            Case newCase = new Case();
            Set<Id> setOfOwnerId = new Set<Id>();
            List<Order> ordList = new List<Order>();
            List<Case> cseList = new List<Case>();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Inbound Case' LIMIT 1];
            if(ordId != null){
                 ordList = [SELECT Id,AccountId From Order where Id =: ordId LIMIT 1];
            }
            
            
            if(ordList.size()>0){
                if(ordList[0] != null){
                    newCase.OrderId__c = ordList[0].Id;
                    newCase.RecordTypeId = rt.Id;
                    newCase.AccountId = recId;
                    
                }else{
                    newCase.RecordTypeId = rt.Id;
                    newCase.AccountId = recId;
                }
                
                newCase.Subject = 'Call - Manual Case Creation';
                newCase.Communication_Mode__c = 'Call';
                newCase.Origin = 'Inbound Phone';
                
                if(conNumber != null){
                    newCase.Contact_Number__c = conNumber;
                    newCase.SuppliedPhone = conNumber;                    
                }
                
                newCase.Status = 'New';
                newCase.OwnerId = UserInfo.getUserId();
            }
            else{
                if(conNumber != null){
                    newCase.SuppliedPhone = conNumber;
                    newCase.Contact_Number__c = conNumber;
                }
                newCase.RecordTypeId = rt.Id;
                newCase.AccountId = recId;
                newCase.Subject = 'Call - Manual Case Creation';
                newCase.Communication_Mode__c = 'Call';
                newCase.Origin = 'Inbound Phone';
                newCase.Status = 'New';
                newCase.OwnerId = UserInfo.getUserId();
            }
            
            
            
            
            
            insert newCase;
            setOfOwnerId.add(newCase.OwnerId);
            cseList.add(newCase);            
            
            Set<String> setOfUserId = new Set<String>();
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            // List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
            List<User> userList = [SELECT Id, Email FROM User WHERE Email IN :setOfOwnerId];
            // EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='child case creation'];
            // Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
            for (User us : userList) {
                setOfUserId.add(us.Id);
            }
            
            User usr = [SELECT Id,Name,Email From User Where Id=:newCase.OwnerId ];
            // notification to user
            notification.setBody('A New Case Has been created. Please check the details.');
            notification.setTitle('Hi, A New Case Has been created.');
            notification.setSenderId(usr.Id);
            notification.setNotificationTypeId(customNotiList.Id); 
            notification.setTargetId(newCase.Id);
            // email to user
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // String body = temp.body;
            // body = body.replace('{!Case.Id}',newCase.Id);
            // mail.setPlainTextBody(body);
            // mail.setTemplateId(temp.id);
            // //mail.setTargetObjectId(newCase.Id);
            // mail.setToAddresses(new List<String> {usr.Email});
            // mailList.add(mail);
            
            notification.send(new Set<String> { newCase.OwnerId });
            // Messaging.sendEmail(mailList);
            
            
            return newCase;
        } catch (Exception e) {
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static List<String> getCaseFieldSetListForCourierIssue(){
        try{
            List<String> caseFieldSetList = new List<String>();
            List<Schema.FieldSetMember> FieldSetListFromCase  = SobjectType.Case.FieldSets.courierIssue.getFields();
            for(Schema.FieldSetMember fieldsToAdd : FieldSetListFromCase){
                caseFieldSetList.add(String.valueOf(fieldsToAdd.sobjectfield));
            }
            if(caseFieldSetList.size()>0){
                return caseFieldSetList;
            }
        }catch(Exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static List<OrderItem> getOrderIfItHasLineItems(String recId){
        try {
            if(recId != null){
                Case cserec = [SELECT Id,OrderId__c From Case Where Id=:recId ];
                Order orderRec = new Order();
                List<OrderItem> itmList = new List<OrderItem>();
                Set<Id> subOrderIds = new Set<Id>();
                
                if(cseRec.OrderId__c != null){
                    orderRec = [SELECT Id, Name, ParentOrder__c FROM Order WHERE Id =: cseRec.OrderId__c];
                }
                if(orderRec.ParentOrder__c == null){
                    List<Order> subOrderList = [SELECT Id FROM Order WHERE ParentOrder__c =: orderRec.Id];
                    if(!subOrderList.isEmpty()){
                        for(Order orderRecord : subOrderList){
                            subOrderIds.add(orderRecord.Id);
                        }
                    }
                    if(!subOrderIds.isEmpty()){
                        itmList = [SELECT Refunded_Price__c,Brand__c, Status__c,Product_Name__c, Quantity, UnitPrice, Selling_Price__c, Id,SKU__C,OrderId,product2.Name,Order.ParentOrder__c,product2Id,Order.Name,Order.OrderNumber, Order.ParentOrder__r.Paid_Amount__c, Order.ParentOrder__r.CreatedDate, Order.CreatedDate,Order.Paid_Amount__c, Order.ParentOrder__r.Name, Order.ParentOrder__r.OrderNumber, Order.ParentOrder__r.Coupon_Code__c,  Order.ParentOrder__r.Coupon_Discount__c FROM OrderItem  Where OrderId IN: subOrderIds];
                    }
                }else{
                    itmList = [SELECT Brand__c, Refunded_Price__c, Status__c, Product_Name__c, Quantity, UnitPrice, Selling_Price__c, Id,SKU__C,OrderId,product2.Name,product2Id,Order.Name,Order.OrderNumber,Order.ParentOrder__c, Order.ParentOrder__r.Paid_Amount__c, Order.CreatedDate,Order.Paid_Amount__c, Order.ParentOrder__r.CreatedDate, Order.ParentOrder__r.OrderNumber,  Order.ParentOrder__r.Coupon_Code__c,  Order.ParentOrder__r.Coupon_Discount__c FROM OrderItem  Where OrderId =: cserec.OrderId__c];
                }
                
                return itmList;
            }
            
        } catch (Exception e) {
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static String updateSKUdetailsAndCreateRecordOfSKU( String recId,String ordId, List<Id> ordLinItmList, List<OrderItem> oliList) {
        try {
            List<String> skuString = new List<String>();
            List<Affected_SKU__c> affectedSKUsList = new List<Affected_SKU__c>(); 
            List<OrderItem> orderItemToUpdate = new List<OrderItem>();
            // List<User> currUserList = [SELECT Id, Profile.Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
            // User currUserRec = new User();
            // if(!currUserList.isEmpty()){
            //     currUserRec = currUserList[0];
            // }
            if(ordLinItmList.Size()>0){
                update oliList;
                Map<Id,OrderItem> ordMap = new Map<Id,OrderItem>([SELECT Id,Refunded_Price__c,SKU__c,Is_Already_Utilized__c,Product_Name__c,Affected_Quantity__c,Quantity,Selling_Price__c,UnitPrice,Total_Selling_Price__c,Brand__c From OrderItem Where Id IN:ordLinItmList ]);
                for(Id key : ordMap.keySet()){
                    if(ordMap.get(key).Is_Already_Utilized__c){
                    skuString.add(ordMap.get(key).SKU__c);
                    Affected_SKU__c affectedSKU = new Affected_SKU__c();
                    affectedSKU.Name = ordMap.get(key).SKU__c;
                    affectedSKU.Case__c = recId;
                    affectedSKU.Brand_Name__c = ordMap.get(key).Brand__c;
                    affectedSKU.Total_Quantity__c = ordMap.get(key).Quantity;
                    affectedSKU.Product_Name__c = ordMap.get(key).Product_Name__c;
                    affectedSKU.MRP__c = ordMap.get(key).UnitPrice;
                    affectedSKU.Selling_Price__c = ordMap.get(key).Selling_Price__c;
                    affectedSKU.Affected_Quantity__c = ordMap.get(key).Affected_Quantity__c;
                    affectedSKU.Created_By__c = 'CS Team';
                    affectedSKU.Refund_Amount__c = ordMap.get(key).Refunded_Price__c;
                    // Add other fields as needed for the Affected_SKU__c object
                    affectedSKUsList.add(affectedSKU);
                    OrderItem olToUpdate = new OrderItem();
                    olToUpdate.Id = ordMap.get(key).Id;
                    olToUpdate.Is_Already_Utilized__c = true;
                    orderItemToUpdate.add(olToUpdate);
                    }
                }
            }
            
            
            
            // Create a comma-separated string from the SKU values
            String commaSeparatedSKUs = String.join(skuString, ';');            
            Case newCase = new Case();
            if (recId != null ) {
                
                if(skuString.size()>0){
                    newCase.SKU_Details__c = commaSeparatedSKUs;
                }
                if(ordId != null){
                    newCase.OrderId__c = ordId;
                }
                newCase.Id = recId;
                
                
                update newCase;                
                
                List<String> splitSKUs = newCase.SKU_Details__c.split(';');                
                
                
                // Create a list to store the Affected_SKU__c records
                
                // Iterate over the split SKUs and create Affected_SKU__c records
                //   if(splitSKUs.size()>0){
                //     for (String sku : splitSKUs) {
                //         Affected_SKU__c affectedSKU = new Affected_SKU__c();
                //         affectedSKU.Name = sku;
                //         affectedSKU.Case__c = recId;
                //         affectedSKU.Brand_Name__c = recId;
                //         // Add other fields as needed for the Affected_SKU__c object
                //         affectedSKUsList.add(affectedSKU);
                //     }
                //   }
                
                // Insert the list of Affected_SKU__c records
                insert affectedSKUsList;
                update orderItemToUpdate;
            }
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static boolean getRecentProgress(String recId) {
        try {
            // Fetch necessary fields in the SOQL query
            boolean isCpdRemakrs = false;
            List<Case_Progress_Detail__c> recentProgress = [
                SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,
                LastReferencedDate, CS_Remarks__c, WH_Team_Remarks__c, Status__c, Case__c,
                Current_Action__c
                FROM Case_Progress_Detail__c
                WHERE (Case__c = :recId AND Current_Action__c = 'Requested more Info from CS Team')
                ORDER BY CreatedDate DESC LIMIT 1
            ];
            // Check if recentProgress exists and CS_Remarks__c is null
            if(recentProgress.size()>0){
                if(recentProgress != null && recentProgress[0].CS_Remarks__c == null){
                    isCpdRemakrs = true;
                }
            }
            
            return isCpdRemakrs;
        } catch (Exception e) {
            // Log specific error details
            System.debug('Error Message: ' + e.getMessage() + ' Error Line: ' + e.getLineNumber());
            // Handle the exception according to your logic, e.g., return false or throw a custom exception
            return false;
        }
    }
    
    
    @AuraEnabled
    public static String updateRecentProgress(String recId, String Remark) {
        try {
            Case_Progress_Detail__c recentProgress = [
                SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,
                 LastReferencedDate, CS_Remarks__c, WH_Team_Remarks__c, Status__c, Case__c,
                Current_Action__c
                FROM Case_Progress_Detail__c
                WHERE Case__c = :recId AND Current_Action__c = 'Requested more Info from CS Team'
                ORDER BY CreatedDate DESC LIMIT 1
            ];
            Case_Progress_Detail__c cpd = new Case_Progress_Detail__c();
            cpd.Id = recentProgress.id;
            cpd.CS_Remarks__c = Remark;
            cpd.Status__c = 'Responded';
            cpd.Responded_By__c = UserInfo.getUserId();
            cpd.Response_Time__c = System.now();
            update cpd;
            
            Case cse = new Case();
            cse.Id = recId;
            cse.more_Info_Requested__c = false;
            cse.Last_Response__c = System.Now();
            update cse;
            
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error Message: ' + e.getMessage() + ' Error Line: ' + e.getLineNumber());
            return null;
        }
    }    
}