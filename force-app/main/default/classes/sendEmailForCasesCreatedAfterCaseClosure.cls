public with sharing class sendEmailForCasesCreatedAfterCaseClosure {

    
    @InvocableMethod(label='Send Email After Case Closure Email received')
    public static void sendEmail(List<InputVariables> inpVar){
        Id passedCaseId = Id.valueOf(inpVar[0].caseId);
        String passedEmailId = inpVar[0].emailId;
        EmailTemplate et = [SELECT Id,Subject, Body,HTMLvalue FROM EmailTemplate WHERE DeveloperName ='Email_To_Case_Response'];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'appdevelopers@kult.app'];
        Case caseRec = [SELECT Id, CaseNumber FROM Case WHERE Id=:passedCaseId LIMIT 1];

Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
if ( owea.size() > 0 ) {
    email.setOrgWideEmailAddressId(owea[0].Id);
}
email.setTemplateId(et.Id);
email.setToAddresses(new String[] {passedEmailId});
email.setSubject(et.subject);
String body = et.HTMLvalue;
body = body.replace('{!Case.CaseNumber}', caseRec.CaseNumber);
email.setHTMLBody(body);
String messageId = Cases.generateThreadingMessageId(passedCaseId);
email.setReferences(messageId);
Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});

    }

    public class InputVariables{
        @InvocableVariable
        Public String caseId;
        @InvocableVariable
        Public String emailId;
    }

    public class ReturnVariables{
        @InvocableVariable
        Public String message;
    }
}