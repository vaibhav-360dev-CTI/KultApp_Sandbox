public with sharing class affectedSKUtriggerHelper {
    public static void deleteOldAndCreateNew(List<Affected_SKU__c> skuList) {
        try{
            Set<Id> caseIds = new Set<id>();
            for(Affected_SKU__c skuRec : skuList){
                if(skuRec.Case__c != null){
                    caseIds.add(skuRec.Case__c);
                }
            }
            if(!caseIds.isEmpty()){
                delete [SELECT Id, Name FROM Affected_SKU__c WHERE Case__c IN :caseIds];
            }
        }catch(exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
        }
    }
}