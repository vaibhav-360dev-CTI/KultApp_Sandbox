import { LightningElement,api,track } from 'lwc';
import sendFollowUpResponse from '@salesforce/apex/followUpController.sendFollowUpResponse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class ResponseToFollwUp extends LightningElement {
      @api recordId;
      @track changeValue;
      @track followupresult ;
      @track error;

    handleChange(event){
        debugger;
        this.changeValue = event.target.value;
    }
    handleCancel() {
        debugger;
         this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave() {
        debugger;
        if (this.changeValue == undefined || this.changeValue == null || this.changeValue == '') {
                alert("Enter Response Note");
                return null;
            }
        sendFollowUpResponse({ recId: this.recordId, 
        respondNote :this.changeValue
        })
            .then(result => {
                this.followupresult = result;
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Record updated!",
                        variant: "success",
                    })
                );
               
            })
            .catch(error => {
                this.errors = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "This case cannot be both a parent and a child of another case!!",
                        variant: "Error",
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

}