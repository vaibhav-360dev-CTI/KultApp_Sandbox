public class csOutboundCallController {
    
    @AuraEnabled(cacheable=true)
    public static Case getParentCaseDetails(Id recordId){
        try{
            System.debug(' case recordId==>'+recordId);
            Case caseRec = [select id,Type_of_Call__c,Call_Status__c,Interest_Level__c,Appointment_Booked__c,Order_Placed__c,Callback_Requested__c,CSE_Remarks__c from Case where Id =: recordId];
            System.debug('caseRec==>'+caseRec);
            return caseRec;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateCaseDetails(Case caseRec, Boolean close){
        system.debug('Case to update details==>'+caseRec);
        if(caseRec != null){
            if(close){
                caseRec.Status = 'Closed';
            }
            update caseRec;
        }
    }
    
    @AuraEnabled(cacheable= true)
    public static Map<String, List<String>> getAllPickListVal(Map<String, String> ObjectByField){
        Map<String, List<String>> picklistValByField = new Map<String, List<String>>();
        for(String fields : ObjectByField.keySet()){
            picklistValByField.put(fields, getPicklistValues(ObjectByField.get(fields), fields));
        }
        return picklistValByField;
    }
    
    @AuraEnabled(cacheable= true)
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
        
    
    
}