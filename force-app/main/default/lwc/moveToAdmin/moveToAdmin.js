import { LightningElement, api, track, wire } from 'lwc';
import AssignToAdminQueue from '@salesforce/apex/moveToWarehouseController.AssignToAdminQueue';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecordNotifyChange } from "lightning/uiRecordApi";


export default class MoveToAdmin extends LightningElement {

    @api recordId;
    result;
    error;
    reassignReason;

    handleChange(event) {
        this.reassignReason = event.detail.value;
    }

    handleSave() {
        debugger;
        if (this.reassignReason != null || this.reassignReason != '' || this.reassignReason != undefined) {
            AssignToAdminQueue({ RecId: this.recordId, reassignReason: this.reassignReason })
                .then((result) => {
                    this.result = result;
                    const event = new ShowToastEvent({
                        title: 'Case Assigned SuccessFully',
                        variant: 'Success',
                        message: 'Case Is In Admin Queue',
                    });
                    this.dispatchEvent(event);
                    this.closeQuickAction();
                    getRecordNotifyChange([{ recordId: this.recordId }]);
                }).catch((err) => {
                    this.error = err;
                });
        } else {
            const event = new ShowToastEvent({
                title: 'Case Assignment',
                variant: 'error',
                message: 'Please enter the reason to Reason To The Reassignment',
            });
            this.dispatchEvent(event);
        }
    }

    closeAction(){
        this.closeQuickAction();
    }

    closeQuickAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}