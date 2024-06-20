public class TagcCallLogHelper {
    @AuraEnabled
    public static List<Task> tagCallLog(String recId) {
        
        List<Task> taskList = new List<Task>();
        
        try {
            if (recId != null) {
                String suppliedPhones = '';
                String contactNumber = '';
                String shippingNo = '';
                String accPhone = '';

                Case cs = [SELECT Id, AccountId, CaseNumber, SuppliedPhone, Shipping_Mobile_No__c, Contact_Number__c, Account.Phone 
                           FROM Case 
                           WHERE Id = :recId];
                if (cs.Id != null) {
                    suppliedPhones = cs.SuppliedPhone != null ? '%' + cs.SuppliedPhone + '%': '';
                    contactNumber = cs.Contact_Number__c != null ? '%' + cs.Contact_Number__c + '%' : '';
                    shippingNo = cs.Shipping_Mobile_No__c != null ? '%' + cs.Shipping_Mobile_No__c + '%' : '';
                    accPhone = cs.Account.Phone != null ? '%' + cs.Account.Phone + '%': '';
                }

                taskList = [SELECT Id, WhoId, WhatId, WhoCount, WhatCount, Subject, ActivityDate, Case__c, Case__r.CaseNumber, CreatedDate, Exotel_CTI__From__c, Exotel_CTI__Call_Direction__c, Exotel_CTI__To__c, Exotel_CTI__Start_Time__c, Exotel_CTI__End_Time__c 
                            FROM Task 
                            WHERE Case__c = null 
                            AND Exotel_CTI__Call_Direction__c = 'InBound' 
                            AND (Subject LIKE : suppliedPhones OR Subject LIKE: contactNumber OR Subject LIKE: shippingNo OR Subject LIKE: accPhone)];
            }
            
        } catch (Exception e) {
            System.debug('Error =====>' + e.getMessage() + ' at Line Number====>' + e.getLineNumber());
        }
        return taskList;
    }

    @AuraEnabled
    public static String updateCaseOntask(String recId, List<String> taskIds){
        try{
            if(!taskIds.isEmpty()){
                List<Task>  taskList = [SELECT Id,Case__c FROM Task Where Id IN: taskIds ];
                for(Task taskRec : taskList){
                    if(recId != null){
                        taskRec.Case__c = recId;
                    }
                }
                update taskList; 
                return 'SUCCESS';
            }else{
                return null;
            }
        }catch(Exception e){
            System.debug('Error =====>' + e.getMessage() + ' at Line Number====>' + e.getLineNumber());
            return null;
        }
    }
}