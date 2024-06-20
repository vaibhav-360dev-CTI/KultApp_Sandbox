public class bulkCloseCasesController {
    @AuraEnabled
    
    public static List<Case> bulkCloseCasesMeth(){
        List<Case> CaseList = new List<Case>();
    try{
        
        CaseList = [Select Id,AccountId,CaseNumber,Order_Number__c,Account.Name,Subject,Type,Sub_Type__c,RecordType.Name,Origin,Status,Type_of_Call__c From Case WHERE RecordType.Name = 'Outbound Case'
        AND Origin = 'Bulk Upload' AND 	Status != 'Closed' AND Type_of_Call__c != 'Sales' ];
        
        System.debug('Number of Cases: ' + CaseList.size());
        System.debug('CaseList=======>'+CaseList);
    }
    Catch(Exception e){
         System.debug('Error =====>' + e.getMessage() + ' at Line Number====>' + e.getLineNumber());
    }
    return CaseList;
    }

    @AuraEnabled
    public static String updateCase(List<Case> caselist) {
        try {
            //List<String>closureRemark, List<String> casesIds
           // Set<Id> setOfCaseId = new Set<Id>();
            //List<Case> casesToUpdate = [SELECT Id, Case_Reason_Description__c,Status FROM Case WHERE Id IN :casesIds];
            //System.debug('casesToUpdate=========>' + casesToUpdate);
            if(!caselist.isEmpty()){
                for (Case cs : caselist) {
                   
                    cs.Status = 'Closed';
                    
                }
                update caselist;
                System.debug('caselist=======>'+caselist);
                return 'Success: Cases have been closed';
            } else {
                return 'No cases found to update.';
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + ' at Line Number: ' + e.getLineNumber());
            return 'Error: ' + e.getMessage();
        }
    }



}