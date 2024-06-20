trigger TriggerOnAffectedSKU on Affected_SKU__c (before insert) {
    affectedSKUtriggerHelper.deleteOldAndCreateNew(trigger.new);
}