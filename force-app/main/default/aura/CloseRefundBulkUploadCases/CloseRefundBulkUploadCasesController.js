({
    doInit : function(component, event, helper) {
    debugger;
    var action = component.get('c.closeCase');
    action.setParams({
        caseId : component.get('v.recordId')
    });
    action.setCallback(this, function(response){
        var state = response.getState();
        if(state === 'SUCCESS'){
            helper.showToast('Case Successfully Closed', 'Success', 'success');
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
        }else{
            helper.showToast('Some Error Occured', 'Error', 'error');
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
        }
    });
    $A.enqueueAction(action);
    }
})