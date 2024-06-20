@isTest
public class contentDocumentLinkTriggerHelperTest {
    @isTest
    static void testUpdateCaseLastResponseTime() {
        Account acc = New Account();
        acc.Name = 'Testing';
        acc.Phone = '12345678';
        insert acc;
        
        case cs = new Case();
        cs.AccountId = acc.Id;
        cs.Origin = 'Email';
        cs.Status = 'New';
        CS.Subject = 'Test Case';
        insert cs;
        
         ContentVersion version = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test content')
        );
        insert version;
        
        ContentVersion insertedVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :version.Id];

        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = cs.Id,
            ContentDocumentId = insertedVersion.ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl;
        
        List<ContentDocumentLink> attList = new List<ContentDocumentLink>{ cdl };
            
        Test.startTest();
        contentDocumentLinkTriggerHelper.updateCaseLastResponseTime(attList);
        Test.stopTest();    
    }
}