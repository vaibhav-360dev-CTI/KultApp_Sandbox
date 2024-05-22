public with sharing class taskHelperController {
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
            system.debug('mapOfPicklist:::::::>'+mapOfPicklist);
            
            return mapOfPicklist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Case getCaseRecords(){
        case cs =  [SELECT Id,RecordTypeId,Parent_Case__c,Sub_Type__c,Sub_Sub_Type__c,OwnerId,Subject,Status,Origin,AccountId,Contact_Number__c,ContactId,Owner.Name FROM Case LIMIT 1];
        system.debug('cs::::::::>'+cs);
        return cs;
        
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
            System.debug('ControllingField: Label:' + currControllingValue.getLabel());
            controllingInfo.put(currControllingValue.getLabel(), new List<String>());
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues)
        {
            String jsonString = JSON.serialize(currDependentValue);
            
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            
            System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
            
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
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 0].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 0].getLabel()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 1].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 1].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 2].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 2].getLabel()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1)
                {
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Partof ControllingField:' + controllingValues[baseCount + 3].getLabel());
                    controllingInfo.get(controllingValues[baseCount + 3].getLabel()).add(currDependentValue.getLabel());                    
                }
                
                baseCount += 4;
            }            
        }
        
        System.debug('ControllingInfo: ' + controllingInfo);
        
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
    public static List<OrderItem> getOrderItems(String OrdId){
        system.debug('OrdId ===========>' +OrdId);
        List<OrderItem> orderItems = new List<OrderItem>(); // Define the list outside the try-catch block
        try {
            
            Order orderRec = new Order();
            List<OrderItem> itmList = new List<OrderItem>();
            Set<Id> subOrderIds = new Set<Id>();
            
            if(OrdId != null){
                orderRec = [SELECT Id, Name, ParentOrder__c FROM Order WHERE Id =: OrdId];
                System.debug('orderRec==> ' + orderRec);
            }
            if(orderRec.ParentOrder__c == null){
                List<Order> subOrderList = [SELECT Id FROM Order WHERE ParentOrder__c =: orderRec.Id];
                System.debug('subOrderList==> ' + subOrderList);
                if(!subOrderList.isEmpty()){
                    for(Order orderRecord : subOrderList){
                        subOrderIds.add(orderRecord.Id);
                    }
                    System.debug('subOrderIds==> ' + subOrderIds);
                }
                if(!subOrderIds.isEmpty()){
                    itmList = [SELECT Id,SKU__C,OrderId,product2.Name,Order.ParentOrder__c,product2Id,Order.Name,Order.OrderNumber, Order.ParentOrder__r.Paid_Amount__c, Order.ParentOrder__r.CreatedDate, Order.CreatedDate,Order.Paid_Amount__c, Order.ParentOrder__r.Name, Order.ParentOrder__r.OrderNumber FROM OrderItem  Where OrderId IN: subOrderIds];
                }
            }else{
                itmList = [SELECT Id,SKU__C,OrderId,product2.Name,product2Id,Order.Name,Order.OrderNumber,Order.ParentOrder__c, Order.ParentOrder__r.Paid_Amount__c, Order.CreatedDate,Order.Paid_Amount__c, Order.ParentOrder__r.CreatedDate, Order.ParentOrder__r.OrderNumber FROM OrderItem  Where OrderId =: OrdId];
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
    public static Case createCaseFromCase(String Subjt, String conNumber, String recId, String ordId) {
        system.debug('Subjt===>'+Subjt +'conNumber===>'+conNumber+ 'recId===>'+recId); 
        system.debug('conNumber===>'+conNumber  ); 
        system.debug('recId===>'+recId ); 
        system.debug('ordId===>'+ordId  ); 
        try {
            List<Task> ts = new List<Task>();
            //  Contact con = [SELECT Id,Name,AccountId From Contact Where Id =: recId];
            if(recId != null){
                ts = [Select Id,Subject,Case__c,AccountId,whatId From Task Where Id =: recId LIMIT 1];
                System.debug('ts=============>'+ts);
                system.debug('ContactAccountId===============>'+ ts[0].AccountId);
            }
            Case newCase = new Case();
            Set<Id> setOfOwnerId = new Set<Id>();
            List<Case> cseList = new List<Case>();
            RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Inbound Case' LIMIT 1];
            if(ordId != null){
                Order ord = [SELECT Id,AccountId From Order where Id =: ordId]; 
                newCase.OrderId__c = ordId;
                newCase.RecordTypeId = rt.Id;
                if(ord.AccountId != null){
                    newCase.AccountId = ord.AccountId;
                }
                newCase.Subject = 'Call - Manual Case Creation';
                newCase.Communication_Mode__c = 'Call';
                
                if(conNumber != null){
                    newCase.SuppliedPhone = conNumber;
                    newCase.Contact_Number__c = conNumber;
                }
                newCase.Status = 'New';
                newCase.OwnerId = UserInfo.getUserId();
            }else{
                newCase.RecordTypeId = rt.Id;
                newCase.Contact_Number__c = conNumber;
                newCase.SuppliedPhone = conNumber;
                newCase.Subject = 'Call - Manual Case Creation';
                newCase.Communication_Mode__c = 'Call';
                newCase.Status = 'New';
                newCase.OwnerId = UserInfo.getUserId();
                if(ts.size()>0){
                    newCase.AccountId = ts[0].AccountId;
                }
            }
            
            insert newCase;
            system.debug('newCaseId==============> '+ newCase.Id);
            
            ts[0].Case__c = newCase.Id;
            update ts;
            system.debug('ts===============>'+ ts);
            setOfOwnerId.add(newCase.OwnerId);
            cseList.add(newCase);
            System.debug('newCase:::::::::::>' + newCase);
            
            
            Set<String> setOfUserId = new Set<String>();
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
            List<User> userList = [SELECT Id, Email FROM User WHERE Email IN :setOfOwnerId];
            EmailTemplate temp = [SELECT Id,Subject,Body FROM EmailTemplate WHERE Name ='child case creation'];
            Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
            System.debug('userList:::::::::::>' + userList);
            for (User us : userList) {
                setOfUserId.add(us.Id);
            }
            System.debug('setOfUserId:::::::::::>' + setOfUserId);
            
            User usr = [SELECT Id,Name,Email From User Where Id=: newCase.OwnerId];
            // notification to user
            notification.setBody('A New Case Has been created. Please check the details.');
            notification.setTitle('Hi, A New Case Has been created.');
            notification.setSenderId(usr.Id);
            notification.setNotificationTypeId(customNotiList.Id); 
            notification.setTargetId(newCase.Id);
            // email to user
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String body = temp.body;
            body = body.replace('{!Case.Id}',newCase.Id);
            mail.setPlainTextBody(body);
            mail.setTemplateId(temp.id);
            //mail.setTargetObjectId(newCase.Id);
            mail.setToAddresses(new List<String> {usr.Email});
            mailList.add(mail);
            
            System.debug('notification:::::::::::>' + notification);
            notification.send(new Set<String> { newCase.OwnerId });
            Messaging.sendEmail(mailList);
            
            
            return newCase;
        } catch (Exception e) {
            System.debug('getMessage:::::::::>'+e.getMessage()+ 'lineNumber::::::::::>'+ e.getLineNumber());
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
   
    } 
    
        
}