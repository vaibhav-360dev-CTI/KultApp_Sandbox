@isTest
public class dependentPicklistValAPEX_Test {
    
    @isTest
    static void testGetCountryStateDependencies() {
       
        
        Test.startTest();
        // Call the method to be tested
        Map<String, List<dependentPicklistValAPEX.State>> result = dependentPicklistValAPEX.getCountryStateDependencies(
            'Case', 'Type', 'Sub_Type__c'
        );
        Test.stopTest();
    }
}