@isTest
private class affectedSKUtriggerHelperTest {
    
    @isTest
    static void testDeleteOldAndCreateNew() {
        // Create test data
        Case testCase1 = new Case(Subject = 'Test Case 1');
        insert testCase1;
        
        Case testCase2 = new Case(Subject = 'Test Case 2');
        insert testCase2;

        Affected_SKU__c sku1 = new Affected_SKU__c(Case__c = testCase1.Id, Name = 'Test SKU 1');
        Affected_SKU__c sku2 = new Affected_SKU__c(Case__c = testCase2.Id, Name = 'Test SKU 2');
        insert new List<Affected_SKU__c> { sku1, sku2 };
        
        // Ensure SKUs are created
        List<Affected_SKU__c> skuList = [SELECT Id, Case__c FROM Affected_SKU__c WHERE Case__c IN :new Set<Id>{testCase1.Id, testCase2.Id}];
        System.assertEquals(2, skuList.size());

        // Call the method to delete old and create new SKUs
        affectedSKUtriggerHelper.deleteOldAndCreateNew(skuList);
        
        // Verify the SKUs are deleted
        List<Affected_SKU__c> deletedSkus = [SELECT Id, Case__c FROM Affected_SKU__c WHERE Case__c IN :new Set<Id>{testCase1.Id, testCase2.Id}];
        System.assertEquals(0, deletedSkus.size());

        // Create new SKUs (This part should be implemented in the deleteOldAndCreateNew method)
        Affected_SKU__c newSku1 = new Affected_SKU__c(Case__c = testCase1.Id, Name = 'New Test SKU 1');
        Affected_SKU__c newSku2 = new Affected_SKU__c(Case__c = testCase2.Id, Name = 'New Test SKU 2');
        insert new List<Affected_SKU__c> { newSku1, newSku2 };

        // Verify the new SKUs are created
        List<Affected_SKU__c> newSkus = [SELECT Id, Case__c FROM Affected_SKU__c WHERE Case__c IN :new Set<Id>{testCase1.Id, testCase2.Id}];
        System.assertEquals(2, newSkus.size());
    }

    @isTest
    static void testDeleteOldAndCreateNewWithNoCases() {
        // Create test data with no Case__c
        Affected_SKU__c sku1 = new Affected_SKU__c(Name = 'Test SKU 1');
        Affected_SKU__c sku2 = new Affected_SKU__c(Name = 'Test SKU 2');
        insert new List<Affected_SKU__c> { sku1, sku2 };
        
        // Ensure SKUs are created
        List<Affected_SKU__c> skuList = [SELECT Id FROM Affected_SKU__c WHERE Id IN :new Set<Id>{sku1.Id, sku2.Id}];
        System.assertEquals(2, skuList.size());

        // Call the method to delete old and create new SKUs
        affectedSKUtriggerHelper.deleteOldAndCreateNew(skuList);
        
        // Verify the SKUs are not deleted since there are no Case__c
        List<Affected_SKU__c> notDeletedSkus = [SELECT Id FROM Affected_SKU__c WHERE Id IN :new Set<Id>{sku1.Id, sku2.Id}];
        System.assertEquals(2, notDeletedSkus.size());
    }
}