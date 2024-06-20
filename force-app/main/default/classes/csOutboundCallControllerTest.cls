@isTest
public class csOutboundCallControllerTest {
    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account',Phone = '213465789');
        insert acc;
        
        Case caseRec = new Case(
            AccountId = acc.Id,
            Type_of_Call__c = 'Sales',
            Call_Status__c = 'Cancelled',
            Interest_Level__c = 'Interested	',
            Appointment_Booked__c = 'Yes',
            Order_Placed__c = 'Yes',
            Callback_Requested__c = 'Yes',
            CSE_Remarks__c = 'Initial remarks'
        );
        insert caseRec;
    }

    @isTest
    static void testGetParentCaseDetails() {
        Case caseRec = [SELECT Id FROM Case LIMIT 1];
        Case result = csOutboundCallController.getParentCaseDetails(caseRec.Id);

    }

    @isTest
    static void testUpdateCaseDetails() {
        Case caseRec = [SELECT Id, CSE_Remarks__c FROM Case LIMIT 1];
        caseRec.CSE_Remarks__c = 'Updated remarks';
        csOutboundCallController.updateCaseDetails(caseRec);
        Case updatedCase = [SELECT CSE_Remarks__c FROM Case WHERE Id = :caseRec.Id];
        System.assertEquals('Updated remarks', updatedCase.CSE_Remarks__c, 'Expected CSE_Remarks__c to be updated');
    }

    @isTest
    static void testGetAllPickListVal() {
        Map<String, String> objectByField = new Map<String, String> {
            'Type_of_Call__c' => 'Case',
            'Call_Status__c' => 'Case'
        };
        Map<String, List<String>> result = csOutboundCallController.getAllPickListVal(objectByField);
    }

    @isTest
    static void testGetPicklistValues() {
        List<String> typeOfCallValues = csOutboundCallController.getPicklistValues('Case', 'Type_of_Call__c');
        List<String> callStatusValues = csOutboundCallController.getPicklistValues('Case', 'Call_Status__c');
    }
}