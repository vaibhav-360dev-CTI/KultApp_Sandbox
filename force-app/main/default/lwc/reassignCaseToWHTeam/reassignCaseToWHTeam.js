import { LightningElement ,api,wire,track} from 'lwc';
import reAssignCaseToCSTeam from '@salesforce/apex/moveToWarehouseController.reAssignCaseToWHTeam';
import getAllUser from '@salesforce/apex/moveToWarehouseController.getAllWHUser';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecordNotifyChange } from "lightning/uiRecordApi";

let i=0;

export default class ReAssginCaseToCSTeam extends LightningElement {

    @api recordId;
    @track reAssignmnetReason;
    userId
    result;
    error;
    inpName;
    items;

    @track error;
    data;

    @track items = [];
    selectedContactId;
    @track value = '';

    get statusOptions() {
        return this.items;
    }
   
    connectedCallback() {
        debugger;
        this.callApexMethod();
    }

    handleChange(event) {
        debugger;
        this.inpName = event.target.name;
        if(this.inpName == 'userName'){
            this.userId = event.detail.value;
        }
        if(this.inpName == 'AssignReason'){
            this.reAssignmnetReason = event.target.value;
        }
        
        
    }

    handleSave() {
        debugger;
        if (this.reAssignmnetReason != null || this.reAssignmnetReason != '' || this.reAssignmnetReason != undefined) {
            reAssignCaseToCSTeam({ recId: this.recordId, reAssignmnetReason: this.reAssignmnetReason, usrId : this.userId })
                .then((result) => {
                    this.result = result;
                    const event = new ShowToastEvent({
                        title: 'Success',
                        variant: 'Success',
                        message: 'Case has been Successfully Re Assigned',
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


    callApexMethod() {
        getAllUser()
            .then(result => {
                
                    this.data =result;
                    for(i=0; i<this.data.length; i++) {
                        console.log('id === >' + this.data[i].Id);
                        this.items = [...this.items ,{value: this.data[i].Id , label: this.data[i].Name}];                                   
                    }                
                     this.error = undefined;
                     console.log('list data ==>' + this.items);
                
            })
            .catch(error => {
                this.error = error;
                
            });
    }


}