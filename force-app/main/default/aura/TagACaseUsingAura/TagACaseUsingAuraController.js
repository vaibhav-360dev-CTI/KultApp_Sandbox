({
    handleLWCEvent : function(component, event, helper) {
        debugger;
        //alert('LWC event handled');
        const childcompname= event.detail;
        $A.get("e.force:closeQuickAction").fire(); 
        $A.get("e.force:refreshView").fire(); 
    }
})