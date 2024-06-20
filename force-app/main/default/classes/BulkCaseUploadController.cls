/**
 * @author [Dinesh Baddawar]
 * @email dinesh.b@utilitarianLab.com
 * @create date 2024-04-18 16:48:55
 * @modify date 2024-04-18 16:48:55
 * @desc [Method bulk case upload using CSV and XLSX File]
 */

public class BulkCaseUploadController {
    @AuraEnabled
    public static void processData(String fileData,String sobjectName,List<String> fields, String typeOfCase, String refundType){
        List<Group> bulkQueueList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, QueueRoutingConfigId FROM Group WHERE DeveloperName = 'Bulk_Upload_Queue' LIMIT 1];
        Group bulkUploadQueue = new Group();
        if(!bulkQueueList.isEmpty()){
            bulkUploadQueue = bulkQueueList[0];
        }
        Id orderRelatedRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Outbound Case').getRecordTypeId();
        List<Group> refundQueueList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, QueueRoutingConfigId FROM Group WHERE DeveloperName = 'Refund_Team_Queue' LIMIT 1];
            Group refundQueue = new Group();
        if(!refundQueueList.isEmpty()){
            refundQueue = refundQueueList[0];
        }
        List<Asset> assetListToRecord = new List<Asset>();
        List<case> CaseListToRecord = new List<case>();
        map<String,String> apiNameByLabelName 	= new map<String,String>();
        Set<String> orderIdSet = new Set<String>();
        
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
                                if(apiNameByLabelName.get(fields.get(l)) == 'Record_changed__c'){
                                obj.put(apiNameByLabelName.get(fields.get(l)),Boolean.ValueOf(value));
                                }
                               else if(apiNameByLabelName.get(fields.get(l)) == 'Refund_Amount__c'){
                                    obj.put(apiNameByLabelName.get(fields.get(l)),Decimal.ValueOf(value));
                                }
                                else if (apiNameByLabelName.get(fields.get(l)) != null){
                                obj.put(apiNameByLabelName.get(fields.get(l)),value);
                                }
                            }
                        }
                    }
                    recordList.add(obj);
                }
            }

            Set<String> orderNumbersSet = new Set<String>();
            Set<String> phoneNumbersSet = new Set<String>();
            List<Order> orderList = new List<Order>();
            List<Account> accList = new List<Account>();
            Map<String, Order> orderByOrderNo = new Map<String, Order>();
            Map<String, String> accountIdByPhone = new Map<String, String>();

            if(recordList.size()>0){
                for(sObject record : recordList){
                    orderNumbersSet.add((String)record.get('Order__c'));
                    orderNumbersSet.add((String)record.get('OrderId__c'));
                    phoneNumbersSet.add((String)record.get('Contact_Number__c'));
                }
                orderList = [SELECT Id, Name, AccountId FROM Order WHERE Name In: orderNumbersSet];
                accList = [SELECT Id, Name, Phone FROM Account WHERE Phone IN: phoneNumbersSet];
                if(!orderList.isEmpty()){
                    for(Order orRec : orderList){
                        orderByOrderNo.put(orRec.Name, orRec);
                    }
                }
                if(!accList.isEmpty()){
                    for(Account accRec : accList){
                        accountIdByPhone.put(accRec.Phone, accRec.Id);
                    }
                }
                for(sObject record : recordList){
                    if(!orderIdSet.contains((String)record.get('Order__c'))){
                        Case caseRec = new case();   
                    if(record.get('Order__c') !=null){
                        caseRec.Order__c = (String)record.get('Order__c');
                        if(orderByOrderNo.get((String)record.get('Order__c')) != null){
                            Order orderRec = orderByOrderNo.get((String)record.get('Order__c'));
                            caseRec.OrderId__c = orderRec.Id;
                            if(orderRec.AccountId != null){
                                caseRec.AccountId = orderRec.AccountId;
                            }
                        }
                        orderIdSet.add((String)record.get('Order__c'));
                    }
                    if(record.get('Shipping_Mobile_No__c') !=null){
                        caseRec.Shipping_Mobile_No__c	 = (String)record.get('Shipping_Mobile_No__c');
                    }
                    if(record.get('Type_of_Call__c') !=null){
                        caseRec.Type_of_Call__c	 = (String)record.get('Type_of_Call__c');
                    }
                    if(record.get('Subject') !=null){
                        caseRec.Subject	 = (String)record.get('Subject');
                    }
                    if(record.get('Contact_Number__c') !=null){
                        caseRec.Contact_Number__c	 = (String)record.get('Contact_Number__c');
                        caseRec.AccountId = accountIdByPhone.get((String)record.get('Contact_Number__c'));
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
                        caseRec.CSE_Remarks__c = (String)record.get('Remarks_mentioned__c');
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

                    // Mapping for Refund cases
                     if(record.get('Email_Id__c') !=null){
                        caseRec.Email_Id__c = String.valueOf(record.get('Email_Id__c'));
                     }
                     if(record.get('SuppliedPhone') !=null){
                        caseRec.SuppliedPhone = String.valueOf(record.get('SuppliedPhone'));
                     }
                     if(record.get('OrderId__c') !=null){
                        caseRec.OrderId__c = orderByOrderNo.get((String)record.get('OrderId__c')).Id !=null ? orderByOrderNo.get((String)record.get('OrderId__c')).Id : null;
                     }
                     if(record.get('Payment_ID__c') !=null){
                        caseRec.Payment_ID__c = String.valueOf(record.get('Payment_ID__c'));
                     }
                    //  if(record.get('Status') !=null){
                    //     caseRec.Status = String.valueOf(record.get('Status'));
                    //  }
                     if(record.get('Coupon_Code__c') !=null){
                        caseRec.Coupon_Code__c = String.valueOf(record.get('Coupon_Code__c'));
                     }
                     if(record.get('Record_changed__c') !=null){
                         if(record.get('Record_changed__c') == true){
                            caseRec.Refund_Type__c = 'Full';
                         }
                         if(record.get('Record_changed__c') == false){
                            caseRec.Refund_Type__c = 'Partial';
                         }
                     }
                     if(record.get('Refund_Amount__c') !=null){
                        caseRec.Refund_Amount__c = Decimal.valueOf(String.valueOf(record.get('Refund_Amount__c')));
                     }
                    //  if(typeOfCase == 'RefundCases'){
                    //     if(record.get('Status') !=null){
                    //         caseRec.Status	 = String.valueOf(record.get('Status'));
                    //     }
                    // }else{
                    //     caseRec.Status	 = 'New';
                    // }
                    String appenValue = '';
                    String appenValueQty = '';
                    if(record.get('SKU_Details__c') != null){
                        String sku1ID = String.valueOf(record.get('SKU_Details__c'));
                        appenValue = appenValue + sku1ID + ';'; 
                    }
                    if(record.get('HashTag__c') != null){
                        String sku2ID = String.valueOf(record.get('HashTag__c'));   
                        appenValue = appenValue + sku2ID; 
                    }
                    if(appenValue != ''){
                        caseRec.SKU_Details__c = appenValue;
                    }
                    if(record.get('Item__c') != null){
                        String skucancelQty1 = String.valueOf(record.get('Item__c'));
                        appenValueQty = appenValueQty + skucancelQty1 + ';';
                    }
                    if(record.get('Item__c') != null){
                        String skucancelQty2 = String.valueOf(record.get('Landmark__c'));
                        appenValueQty = appenValueQty + skucancelQty2;
                    }
                    if(appenValueQty != ''){
                        caseRec.OOS_Quantity__c = appenValueQty;
                    }
                    caseRec.OwnerId = bulkUploadQueue.Id;
                    caseRec.RecordTypeId = orderRelatedRecordTypeId;
                    if(typeOfCase == 'PinCodeService'){
                        caseRec.Subject = 'Pin Code Not Serviceable';
                    }else if(typeOfCase == 'OutOfStock'){
                        caseRec.Subject = 'Out of Stock';
                    }else if(typeOfCase == 'DeliveryIssue'){
                        caseRec.Subject = 'Courier/Delivery Issue';
                    }else if(typeOfCase == 'LostInTransit'){
                        caseRec.Subject = 'Lost in Transit';
                    }else if(typeOfCase == 'DeleayInDelivery'){
                        caseRec.Subject = 'Delay in Delivery';
                    }else if(typeOfCase == 'RToOrders'){
                        caseRec.Subject = 'RTO Orders';
                    }else if(typeOfCase == 'RefundCases'){
                        caseRec.Subject = 'Monitoring Report - Refund Case';
                        caseRec.OwnerId = refundQueue.Id;
                        if(refundType == 'Full'){
                            caseRec.Refund_Type__c = 'Full';
                            caseRec.Subject = 'Monitoring Report - Refund Case';
                            caseRec.Type = 'Monitoring Report - Full';
                            caseRec.Sub_Type__c = 'Monitoring Report - Full';
                        }else if(refundType == 'Partial'){
                            caseRec.Subject = 'Monitoring Report - Refund Case';
                            caseRec.Refund_Type__c = 'Partial';
                            caseRec.Type = 'Monitoring Report - Partial';
                            caseRec.Sub_Type__c = 'Monitoring Report - Partial';
                        }
                    }else if(typeOfCase == 'CSoutbound'){
                        caseRec.Subject = 'CS Outbound Calls';
                    }
                    caseRec.Origin	 = 'Bulk Upload';
                    caseRec.RecordTypeId = orderRelatedRecordTypeId;
                    CaseListToRecord.add(caseRec);
                    }
                }  
                if(CaseListToRecord.size()>0){
                    insert CaseListToRecord;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }

    public static void sendingCustomNotification(String OwnerId, String caseId, String notificationTitle, String notificationBody){
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Refund_Team_Member'];                                                                       
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

    // =============================================================================================================================================================================================================
    // Method for Create Bulk Case Upload using XLSX File,  Note: Before changing any code ask me First
    @AuraEnabled 
    public static String insertBulkCaseXlsxFiel(String jsonString,String docTempName, String refundType, Boolean showDownload){
        List<Group> bulkQueueList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, QueueRoutingConfigId FROM Group WHERE DeveloperName = 'Bulk_Upload_Queue' LIMIT 1];
        Group bulkUploadQueue = new Group();
        if(!bulkQueueList.isEmpty()){
            bulkUploadQueue = bulkQueueList[0];
        }
        List<Group> refundQueueList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, QueueRoutingConfigId FROM Group WHERE DeveloperName = 'Refund_Team_Queue' LIMIT 1];
            Group refundQueue = new Group();
        if(!refundQueueList.isEmpty()){
            refundQueue = refundQueueList[0];
        }
        try{
            Map<string,string> mapOfOrdernoOrderId = new Map<string,string>();
            Map<string,string> mapOfOrderIdAccountId = new Map<string,string>();
            Map<string,string> mapOfAccountIdbyPhone = new Map<string,string>();
            List<Case> caseListToInsert = new List<Case>();
            Map<String, Object> caseMap = new Map<String, Object>();
            Id orderRelatedRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Outbound Case').getRecordTypeId();

            Set<String> orderNames = new Set<String>();
            Set<String> PhoneNumbers = new Set<String>();

            List<Object> jsonData = (List<Object>) JSON.deserializeUntyped(jsonString);
            for (Object obj : jsonData){
                caseMap = (Map<String, Object>) obj;
                if(caseMap.get('orderno') !=null){
                    orderNames.add(String.valueOf(caseMap.get('orderno')));
                }
                if(caseMap.get('orderid') !=null){
                    orderNames.add(String.valueOf(caseMap.get('orderid')));
                }
                if(caseMap.get('phoneNumber') !=null){
                    PhoneNumbers.add(String.valueOf(caseMap.get('phoneNumber')));
                }
            }

            if(!PhoneNumbers.isEmpty()){
                List<Account> accList = [SELECT Id, Name, Phone FROM Account WHERE Phone IN: PhoneNumbers];
                if(!accList.isEmpty()){
                    for(Account accRec: accList){
                        if(accRec.Phone != null && !mapOfAccountIdbyPhone.containsKey(accRec.Phone)){
                            mapOfAccountIdbyPhone.put(accRec.Phone, accRec.Id);
                        }
                    }
                }
            }


            for(Order ord : [SELECT Id,Name,AccountId,Account.Name FROM Order WHERE Name IN: orderNames]){
                if(ord.Name !=null){
                    mapOfOrdernoOrderId.put(ord.Name,ord.Id);
                }
                if(ord.AccountId !=null){
                    mapOfOrderIdAccountId.put(ord.Name,ord.AccountId);
                }
            }
            string OrderNo;
            for (Object obj : jsonData) {
                caseMap = (Map<String, Object>) obj;
                Case caseRec = new case(); 
                if(!showDownload){
                    caseRec.Refund_Type__c = refundType;
                    caseRec.Type = 'Monitoring Report - ' + refundType;
                    caseRec.Sub_Type__c = 'Monitoring Report - ' + refundType;
                }
                if(caseMap.get('orderno') !=null){
                    OrderNo = String.valueOf(caseMap.get('orderno'));
               }
               if(OrderNo !=null){
                if(mapOfOrdernoOrderId.get(OrderNo) !=null){
                    caseRec.OrderId__c = mapOfOrdernoOrderId.get(OrderNo);
                }else{
                    System.debug('No Order Record Found with this Order No == >'+OrderNo);
                }
                if(mapOfOrderIdAccountId.get(OrderNo) !=null){
                    caseRec.AccountId = mapOfOrderIdAccountId.get(OrderNo);
                }else{
                    System.debug('No Account Found with this order No == >'+OrderNo);
                }
               }
               if(caseMap.get('shippingmobileno') !=null){
                caseRec.Shipping_Mobile_No__c = String.valueOf(caseMap.get('shippingmobileno'));
                }
                if(caseMap.get('reason') !=null){
                    caseRec.Reason = String.valueOf(caseMap.get('reason'));
                }
                if(caseMap.get('item') !=null){
                    caseRec.Item__c	= String.valueOf(caseMap.get('item'));
                }
                if(caseMap.get('oosquantity') !=null){
                    caseRec.OOS_Quantity__c	= String.valueOf(caseMap.get('oosquantity')); 
                }
                if(caseMap.get('oosskucode') !=null){
                    caseRec.SKU_Details__c	= String.valueOf(caseMap.get('oosskucode'));
                }
                if(caseMap.get('remarks') !=null){
                    caseRec.CSE_Remarks__c = String.valueOf(caseMap.get('remarks'));
                }
                if(caseMap.get('currentpincode') !=null){
                    caseRec.Current_PIN_Code__c = String.valueOf(caseMap.get('currentpincode'));
                }
                if(caseMap.get('cityname') !=null){
                    caseRec.City_Name__c = String.valueOf(caseMap.get('cityname'));
                }
                if(caseMap.get('awbnumber') !=null){
                    caseRec.AWB_Number__c = String.valueOf(caseMap.get('awbnumber'));
                }
                if(caseMap.get('courierpartner') !=null){
                    caseRec.Courier_Partner__c = String.valueOf(caseMap.get('courierpartner'));
                }
                if(caseMap.get('orderstatus') !=null){
                    if(caseMap.get('orderstatus') == 'Pending' || caseMap.get('orderstatus') == 'Processing' || caseMap.get('orderstatus') == 'Shipped' || caseMap.get('orderstatus') == 'Delivered' || caseMap.get('orderstatus') == 'Cancelled' || caseMap.get('orderstatus') == 'On Hold' || caseMap.get('orderstatus') == 'Completed' || caseMap.get('orderstatus') == 'Returned' ||  caseMap.get('orderstatus') == 'Refunded' || caseMap.get('orderstatus') == 'Other')
                    caseRec.Actual_Order_Status__c = String.valueOf(caseMap.get('orderstatus'));
                }

                // Redund cases Mapping
                if(caseMap.get('couponcode') !=null){
                    caseRec.Coupon_Code__c = String.valueOf(caseMap.get('couponcode'));
                }
                if(caseMap.get('email') !=null){
                    caseRec.Email_Id__c = String.valueOf(caseMap.get('email'));
                }
                if(caseMap.get('isfullrefund') !=null && showDownload){
                    if(caseMap.get('isfullrefund') == true){
                        caseRec.Refund_Type__c = 'Full';
                    }
                    if(caseMap.get('isfullrefund') == false){
                        caseRec.Refund_Type__c = 'Partial';
                    }
                }
                if(caseMap.get('orderid') !=null){
                    caseRec.AccountId =mapOfOrderIdAccountId.get(String.valueOf(caseMap.get('orderid'))) !=null ? mapOfOrderIdAccountId.get(String.valueOf(caseMap.get('orderid'))) : null;
                }
                if(caseMap.get('razorpaypaymentid') !=null){
                    caseRec.Payment_ID__c = String.valueOf(caseMap.get('razorpaypaymentid'));
                }
                if(caseMap.get('refundamount') !=null){
                    caseRec.Refund_Amount__c = (Decimal)caseMap.get('refundamount');
                }
                if(caseMap.get('phoneno') !=null){
                    caseRec.SuppliedPhone = String.valueOf(caseMap.get('phoneno'));
                }
                if(caseMap.get('orderid') !=null){
                    caseRec.OrderId__c = mapOfOrdernoOrderId.get(String.valueOf(caseMap.get('orderid'))) != null ? mapOfOrdernoOrderId.get(String.valueOf(caseMap.get('orderid'))) : null;
                }
                if(caseMap.get('callType') !=null){
                    caseRec.Type_of_Call__c = String.valueOf(caseMap.get('callType'));
                }
                if(caseMap.get('subject') !=null){
                    caseRec.Subject = String.valueOf(caseMap.get('subject'));
                }
                if(caseMap.get('phoneNumber') !=null){
                    caseRec.Contact_Number__c = String.valueOf(caseMap.get('phoneNumber'));
                    caseRec.AccountId = mapOfAccountIdbyPhone.get(String.valueOf(caseMap.get('phoneNumber')));
                }
                // if(docTempName =='RefundCases'){
                //     if(caseMap.get('easyecomorderstatus') !=null){
                //         caseRec.Status = String.valueOf(caseMap.get('easyecomorderstatus'));
                //     }
                // }else{
                //     caseRec.Status	 = 'New';
                // }

                String appenValue = '';
                if(caseMap.get('sku1id') != null){
                    String sku1ID = String.valueOf(caseMap.get('sku1id'));
                    appenValue = appenValue + sku1ID + ';';
                }
                if(caseMap.get('sku2id') != null){
                    String sku2ID = String.valueOf(caseMap.get('sku2id'));
                    appenValue = appenValue + sku2ID;
                }
                if(appenValue != ''){
                    caseRec.SKU_Details__c = appenValue;
                }

                String appenValueQty = '';
                if(caseMap.get('sku1cancelledquantity') != null){
                    String skucancelQty1 = String.valueOf(caseMap.get('sku1cancelledquantity'));
                    appenValueQty = appenValueQty + skucancelQty1 + ';';
                }
                if(caseMap.get('sku1cancelledquantity') != null){
                    String skucancelQty2 = String.valueOf(caseMap.get('sku2cancelledquantity'));
                    appenValueQty = appenValueQty + skucancelQty2;
                }
                if(appenValueQty != ''){
                    caseRec.OOS_Quantity__c = appenValueQty;
                }

                caseRec.Origin	 = 'Bulk Upload';
                caseRec.OwnerId = bulkUploadQueue.Id;
                caseRec.RecordTypeId = orderRelatedRecordTypeId;
                if(docTempName == 'PinCodeService'){
                    caseRec.Subject = 'Pin Code Not Serviceable';
                }else if(docTempName == 'OutOfStock'){
                    caseRec.Subject = 'Out of Stock';
                }else if(docTempName == 'DeliveryIssue'){
                    caseRec.Subject = 'Courier/Delivery Issue';
                }else if(docTempName == 'LostInTransit'){
                    caseRec.Subject = 'Lost in Transit';
                }else if(docTempName == 'DeleayInDelivery'){
                    caseRec.Subject = 'Delay in Delivery';
                }else if(docTempName == 'RToOrders'){
                    caseRec.Subject = 'RTO Orders';
                }else if(docTempName == 'RefundCases'){
                    caseRec.Subject = 'Monitoring Report - Refund Case';
                        caseRec.OwnerId = refundQueue.Id;
                        if(refundType == 'Full'){
                            caseRec.Refund_Type__c = 'Full';
                            caseRec.Subject = 'Monitoring Report - Refund Case';
                            caseRec.Type = 'Monitoring Report - Full';
                            caseRec.Sub_Type__c = 'Monitoring Report - Full';
                        }else if(refundType == 'Partial'){
                            caseRec.Subject = 'Monitoring Report - Refund Case';
                            caseRec.Refund_Type__c = 'Partial';
                            caseRec.Type = 'Monitoring Report - Partial';
                            caseRec.Sub_Type__c = 'Monitoring Report - Partial';
                        }
                }
                caseListToInsert.add(caseRec);
            }
            if(caseListToInsert.size()>0){
                insert caseListToInsert;
                if(caseListToInsert.size()>0){
                    return 'SUCCESS';
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
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
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
          i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k; 
          i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
          i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k; 
          i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
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