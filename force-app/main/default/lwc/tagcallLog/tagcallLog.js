import { LightningElement, track, api, wire } from 'lwc';
import tagCallLog from '@salesforce/apex/TagcCallLogHelper.tagCallLog';
import updateCaseOntask from '@salesforce/apex/TagcCallLogHelper.updateCaseOntask';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const Taskcolumns = [
    //{ label: 'WhatId', fieldName: 'WhatId', type: '' },
    { label: 'Customer Number', fieldName: 'Exotel_CTI__From__c', type: 'Phone' },
    { label: 'Subject', fieldName: 'Subject', type: 'text' },
    { label: 'Start Time', fieldName: 'Exotel_CTI__Start_Time__c', type: 'text' },
    { label: 'End Time', fieldName: 'Exotel_CTI__End_Time__c', type: 'text' },
    { label: 'Call Direction', fieldName: 'Exotel_CTI__Call_Direction__c', type: 'text' },
];
export default class TagcallLog extends LightningElement {


    columns = Taskcolumns;
    @api recordId;
    @track TaskData = [];
    result;
    error;
    showUnder2ndPage = false;
    SelectedId = [];
    selectedTask;
    

    connectedCallback() {
        setTimeout(() => {
            this.fetchCallLog();
                }, 200);
    }

    fetchCallLog() {
        debugger;
        tagCallLog({ recId: this.recordId })
            .then(data => {
                this.TaskData = data;
                this.showUnder2ndPage = true;
                console.log('Data', data);
            })
            .catch(error => {
                this.showToast();
                this.handleCancel();
                console.error('Error:', error);
            });
    }

    OnlyOneSelection = event => {
        debugger;
        var selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            for(var i in selectedRows){
                this.SelectedId.push(selectedRows[i].Id);
            }
        }
    }



    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'No Tasks',
            message: 'Curretnly there are No task',
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleSave(){
        debugger;
        updateCaseOntask({ recId:this.recordId , taskIds: this.SelectedId })
            .then(result => {
                this.selectedTask = result;
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
                        message: "",
                        variant: "Error",
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }
}