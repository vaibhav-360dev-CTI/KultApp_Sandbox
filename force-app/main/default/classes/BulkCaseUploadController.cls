public class BulkCaseUploadController {
    @AuraEnabled
    public static void processData(String fileData,String sobjectName,List<String> fields, String typeOfCase){

        System.debug('typeOfCase==> ' + typeOfCase);
        Id orderRelatedRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Order Related').getRecordTypeId();
        //Id serviceRelatedRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Service Related').getRecordTypeId();

        System.debug('fileData === >'+fileData);
        System.debug('fields === >'+fields);
        List<Asset> assetListToRecord = new List<Asset>();
        List<case> CaseListToRecord = new List<case>();
        map<String,String> apiNameByLabelName 	= new map<String,String>();
        Map<String,String> mapIfContEmailConId = new Map<String,String>();
        Map<String,String> mapOfProductNameProdId = new Map<String,String>();
        
        for(Contact con : [SELECT Id,Email FROM Contact]){
            if(con.Email !=null){
                mapIfContEmailConId.put(con.Email,con.Id);
            }
        }
        
        for(Product2 pro : [SELECt Id,Name FROM Product2]){
            mapOfProductNameProdId.put(pro.Name,pro.id);
        }
        
        List<Bulk_Case_Upload_Mapping__mdt> gsrCSVFileFormatList = [SELECT Case_Field_API_Name__c,Id,Label,Sequence__c FROM Bulk_Case_Upload_Mapping__mdt];
        for(Bulk_Case_Upload_Mapping__mdt gsrm : gsrCSVFileFormatList) {
            apiNameByLabelName.put(gsrm.Label,gsrm.Case_Field_API_Name__c);
        }       
        List<sObject> recordList = new List<sObject>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sobjectName);
        try{
            if(fileData!=null) { 
                String[] fileLines = new String[]{};
                    fileLines = fileData.split('\n');
                for (Integer i=1,j=fileLines.size();i<j;i++){
                    String[] inputvalues = new String[]{};
                        inputvalues = fileLines[i].split(',');
                    sObject obj = targetType.newSObject();
                    integer rowsize=inputvalues.size(); 
                    for(integer l=0;l<rowsize;l++){     
                        if(String.isNotBlank(inputvalues[l])) {
                            String value= inputvalues[l].length()>255 ? inputvalues[l].substring(0,254) : inputvalues[l];
                            if(value != null){
                                System.debug('value ==== >'+value);
                                System.debug('Label Name === >'+apiNameByLabelName.get(fields.get(l)));
                                if(apiNameByLabelName.get(fields.get(l)) == 'Date_Of_Order__c'){
                                    obj.put(String.valueOf(apiNameByLabelName.get(fields.get(l))),Date.valueOf(value));
                                }
                                else{
                                    obj.put(apiNameByLabelName.get(fields.get(l)),value);
                                }
                            }
                        }
                    }
                    recordList.add(obj);
                }
            }
            System.debug('recordList Size ==== >'+recordList.size());
            Set<String> orderNumbersSet = new Set<String>();
            List<Order> orderList = new List<Order>();
            Map<String, Order> orderByOrderNo = new Map<String, Order>();
            
            if(recordList.size()>0){
                for(sObject record : recordList){
                    orderNumbersSet.add((String)record.get('Order__c'));
                }

                orderList = [SELECT Id, Name, AccountId FROM Order WHERE Name In: orderNumbersSet];

                if(!orderList.isEmpty()){
                    for(Order orRec : orderList){
                        orderByOrderNo.put(orRec.Name, orRec);
                    }
                }


                for(sObject record : recordList){
                    Case caseRec = new case();   
                    if(record.get('Date_Of_Order__c') !=null){
                        caseRec.Date_Of_Order__c =Date.valueOf((Date)record.get('Date_Of_Order__c'));
                    }
                    if(record.get('Order__c') !=null){
                        caseRec.Order__c = (String)record.get('Order__c');
                        if(orderByOrderNo.get((String)record.get('Order__c')) != null){
                            Order orderRec = orderByOrderNo.get((String)record.get('Order__c'));
                            caseRec.OrderId__c = orderRec.Id;
                            if(orderRec.AccountId != null){
                                caseRec.AccountId = orderRec.AccountId;
                            }
                            System.debug('caseRec.OrderId__c==> ' + caseRec.OrderId__c);

                        }
                        
                    }
                    if(record.get('Shipping_Mobile_No__c') !=null){
                        caseRec.Shipping_Mobile_No__c	 = (String)record.get('Shipping_Mobile_No__c');
                    }
                    if(record.get('Reason') !=null){
                        caseRec.Reason	 = (String)record.get('Reason');
                    }
                    if(record.get('Item__c') !=null){
                        caseRec.Item__c	 = (String)record.get('Item__c');
                    }
                    if(record.get('OOS_Quantity__c') !=null){
                        caseRec.OOS_Quantity__c	 = (String)record.get('OOS_Quantity__c');
                    }
                    if(record.get('OOS_SKU_Code__c') !=null){
                        caseRec.SKU_Details__c	 = (String)record.get('OOS_SKU_Code__c');
                    }
                    if(record.get('Remarks_mentioned__c') !=null){
                        caseRec.Remarks_mentioned__c = (String)record.get('Remarks_mentioned__c');
                    }
                    if(record.get('Current_PIN_Code__c') !=null){
                        caseRec.Current_PIN_Code__c = (String)record.get('Current_PIN_Code__c');
                    }
                     if(record.get('City_Name__c') !=null){
                        caseRec.City_Name__c = (String)record.get('City_Name__c');
                    }
                     if(record.get('Courier_Partner__c') !=null){
                        caseRec.Courier_Partner__c = (String)record.get('Courier_Partner__c');
                    }
                     if(record.get('AWB_Number__c') !=null){
                        caseRec.AWB_Number__c = (String)record.get('AWB_Number__c');
                    }
                     if(record.get('Actual_Order_Status__c') !=null){
                        caseRec.Actual_Order_Status__c = (String)record.get('Actual_Order_Status__c');
                    }
                    if(typeOfCase == 'PinCodeService'){
                        caseRec.RecordTypeId = orderRelatedRecordTypeId;
                        caseRec.Subject = 'Pin Code Not Serviceable';
                    }else if(typeOfCase == 'OutOfStock'){
                        caseRec.RecordTypeId = orderRelatedRecordTypeId;
                        caseRec.Subject = 'Out of Stock';
                    }else if(typeOfCase == 'DeliveryIssue'){
                        caseRec.RecordTypeId = orderRelatedRecordTypeId;
                        caseRec.Subject = 'Delivery Issue';
                    }else if(typeOfCase == 'LostInTransit'){
                        caseRec.RecordTypeId = orderRelatedRecordTypeId;
                        caseRec.Subject = 'Lost in Transit';
                    }else if(typeOfCase == 'DeleayInDelivery'){
                        caseRec.RecordTypeId = orderRelatedRecordTypeId;
                        caseRec.Subject = 'Delay in Delivery';
                    }else if(typeOfCase == 'RToOrders'){
                        caseRec.RecordTypeId = orderRelatedRecordTypeId;
                        caseRec.Subject = 'RTO Orders';
                    }
                    
                    caseRec.Status	 = 'New';
                    caseRec.Origin	 = 'Bulk Upload';
                    CaseListToRecord.add(caseRec);
                }  
                if(CaseListToRecord.size()>0){
                    insert CaseListToRecord;
                    for(Case caseRec : CaseListToRecord){
                        Id userId = userinfo.getUserId();
                        System.debug('caseRec.OwnerId==> ' + caseRec.OwnerId);
                        sendingCustomNotification(userId, caseRec.Id, 'Case Created Using Bulk Upload', 'A case has been created using bulk upload, kindly check and do the needful');
                    }
                    System.debug('Case record inserted Size ==== >'+CaseListToRecord.size());
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }

    public static void sendingCustomNotification(String OwnerId, String caseId, String notificationTitle, String notificationBody){

        System.debug('caseId====>'+caseId);
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                     WHERE DeveloperName='Refund_Team_Member'];

                                                                                           
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(notificationTitle);
            notification.setBody(notificationBody);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(caseId);                         
            Set<String> addressee = new Set<String>();
            addressee.add(OwnerId);                         
            try {
                notification.send(addressee);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
         
    }
    
}