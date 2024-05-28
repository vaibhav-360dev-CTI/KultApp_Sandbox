import { LightningElement,track,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getRecentProgress from '@salesforce/apex/CaseHelperControllers.getRecentProgress';
import updateRecentProgress from '@salesforce/apex/CaseHelperControllers.updateRecentProgress';
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SendRequestInfo extends LightningElement {

    remarks;
    @track caseResult;
    @track error;
    @api recordId;
    @track updateResult;
    connectedCallback() {
        setTimeout(() => {
            this.doSearch();
        },700);
        
    }
    @track recAvail = false;
    doSearch() {
        debugger;
        getRecentProgress({recId: this.recordId})
            .then(result => {
                if(result == true){
                    this.recAvail = true;
                }else{
                    this.recAvail = false;
                    const event = new ShowToastEvent({
                        title: 'Case Progress',
                        variant: 'Warning',
                        message: 'No Updation Is Required',
                    });
                    this.dispatchEvent(event);
                    this.closeAction();
                    getRecordNotifyChange([{ recordId: this.recordId }]);
                }
            })
            .catch(error => {
                this.error = error;
                this.recAvail = false;
            });
    }


    handleChange(event){
        debugger;
        this.remarks = event.detail.value;
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave() {
        debugger;
    
        updateRecentProgress({ recId: this.recordId, Remark: this.remarks })
            .then(result => {
                this.updateResult = result;
                const event = new ShowToastEvent({
                    title: 'Case Progress',
                    variant: 'success',
                    message: 'Case Progress is Created Successfully',
                });
                this.dispatchEvent(event);
                this.closeAction();
                getRecordNotifyChange([{ recordId: this.recordId }]);
                // getRecordNotifyChange({ recordId: this.recordId });
            })
            .catch(error => {
                this.error = error;
                this.updateResult = undefined;
                const event = new ShowToastEvent({
                    title: 'Case Progress',
                    variant: 'error',
                    message: 'An error occurred while updating Case Progress.',
                });
                this.dispatchEvent(event);
            });
    }
    
    
}