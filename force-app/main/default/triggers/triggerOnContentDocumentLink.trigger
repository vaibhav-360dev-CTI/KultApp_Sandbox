trigger triggerOnContentDocumentLink on ContentDocumentLink (before insert, after insert, after update) {
	if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)){
        contentDocumentLinkTriggerHelper.updateCaseLastResponseTime(trigger.new);
    }
}