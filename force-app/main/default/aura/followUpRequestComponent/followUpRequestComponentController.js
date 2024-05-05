({
    closeModel: function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },


    // doInit: function (component, event, helper) {
    //     debugger;
    //     var action = component.get('c.checkFollowUpStatu');
    //     action.setParams({
    //         recId: component.get('v.recordId')
    //     });
    //     action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         if (state === 'SUCCESS') {
    //             if (response.getReturnValue() == 'Open') {
    //                 helper.showToast('Recent Follow-up Is Sitll Not yet Responded', 'Error', 'error');
    //                 var dismissActionPanel = $A.get("e.force:closeQuickAction");
    //                 dismissActionPanel.fire();
    //                 $A.get('e.force:refreshView').fire();
    //             }
    //             else {
    //                 component.set('v.showTrue', true);
    //             }
              
    //         } else {
    //             helper.showToast('Some Error Occured!', 'Error', 'error');
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },

    submitDetails: function (component, event, helper) {
        debugger;
        if (component.get('v.followUpRemarks') == null || component.get('v.followUpRemarks') == undefined || component.get('v.followUpRemarks') == '') {
            helper.showToast('Please Enter Follow Up Remarks', 'Alert', 'warning');
            return;
        }
        var action = component.get('c.sendFollowUp');
        action.setParams({
            recId: component.get('v.recordId'),
            remarks: component.get('v.followUpRemarks')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                helper.showToast('Follow Up Request Sent Successfully', 'Success', 'success');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
            } else {
                helper.showToast('Some Error Occured!', 'Error', 'error');
            }
        });
        $A.enqueueAction(action);
    }
})