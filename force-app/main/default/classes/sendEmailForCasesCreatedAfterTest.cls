@isTest
public class sendEmailForCasesCreatedAfterTest {
    @isTest
    static void testSendEmail() {
        // Create test data for Folder
        //Folder testFolder = new Folder(Name = 'Case Email Templates ', DeveloperName = 'Case_Email_Templates');
        //insert testFolder;

        // Create test data for EmailTemplate
        EmailTemplate testEmailTemplate = new EmailTemplate(
            DeveloperName = 'Email_To_Case_Response',
            FolderId = null,
            TemplateType = 'text',
            Subject = 'Test Subject',
            Body = 'Test Body',
            HTMLvalue = '<html><body>This is a test email</body></html>'
        );
        insert testEmailTemplate;

        // Create test data for OrgWideEmailAddress
       // OrgWideEmailAddress testOWEA = new OrgWideEmailAddress(Address = 'appdevelopers@kult.app');
       // insert testOWEA;

        // Create test data for Case
        Case testCase = new Case();
        testCase.Status = 'New'; 
        insert testCase;

        // Create test data for InputVariables
        sendEmailForCasesCreatedAfterCaseClosure.InputVariables testInput = new sendEmailForCasesCreatedAfterCaseClosure.InputVariables();
        testInput.caseId = testCase.Id;
        testInput.emailId = 'test@example.com';
        List<sendEmailForCasesCreatedAfterCaseClosure.InputVariables> testInputList = new List<sendEmailForCasesCreatedAfterCaseClosure.InputVariables>{testInput};

        Test.startTest();
        sendEmailForCasesCreatedAfterCaseClosure.sendEmail(testInputList);
        Test.stopTest();

        // Perform assertions as needed
    }
}