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

    handleFilesChange: function(component, event, helper){
        debugger;
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            component.set('v.isUploaded', true);
        }else{
            component.set('v.isUploaded', false);
        }
        component.set("v.fileName", fileName);
    },

    submitDetails: function (component, event, helper) {
        debugger;
        if (component.get('v.followUpRemarks') == null || component.get('v.followUpRemarks') == undefined || component.get('v.followUpRemarks') == '') {
            helper.showToast('Please Enter Follow Up Remarks', 'Alert', 'warning');
            return;
        }
        if(component.get('v.isUploaded')){
            helper.uploadHelper(component, event);
        }else{
            helper.sendFollowUp(component, event, helper);
        }
        // if(component.get('v.isUploaded')){
        //     var action = component.get('c.sendFollowUpWithAttachment');
        //     action.setParams({
        //         recId: component.get('v.recordId'),
        //         remarks: component.get('v.followUpRemarks'),
        //         fileName: file.name,
        //         base64Data: encodeURIComponent(getchunk),
        //         contentType: file.type,
        //         fileId: attachId
        //     }); 
        // }else{
        //     var action = component.get('c.sendFollowUp');
        //     action.setParams({
        //     recId: component.get('v.recordId'),
        //     remarks: component.get('v.followUpRemarks')
        //     });
        // }
        // action.setCallback(this, function (response) {
        //     var state = response.getState();
        //     if (state === 'SUCCESS') {
        //         if(component.get('v.isUploaded')){
        //             if (component.find("fuploader").get("v.files").length > 0) {
        //                 helper.uploadHelper(component, event);
        //             } else {
        //                 helper.showToast('Please Select a Valid File', 'Alert', 'warning');
        //                 return;
        //             }
        //         }
        //         helper.showToast('Follow Up Request Sent Successfully', 'Success', 'success');
        //         if(!component.get('v.isUploaded')){
        //             var dismissActionPanel = $A.get("e.force:closeQuickAction");
        //             dismissActionPanel.fire();
        //             $A.get('e.force:refreshView').fire();
        //         }
        //     } else {
        //         helper.showToast('Some Error Occured!', 'Error', 'error');
        //     }
        // });
        // $A.enqueueAction(action);
    }
})