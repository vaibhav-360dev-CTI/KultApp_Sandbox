import { LightningElement, api, track } from 'lwc';
import bulkCloseCasesMeth from '@salesforce/apex/bulkCloseCasesController.bulkCloseCasesMeth';
import updateCase from '@salesforce/apex/bulkCloseCasesController.updateCase';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const Casecolumns = [
    { label: 'Case Number', fieldName: 'CaseNumber', type: 'text' },
    { label: 'Order Number', fieldName: 'Order_Number__c', type: 'text' },
    { label: 'Closure Remark', fieldName: 'Case_Reason_Description__c', type: 'text', editable: true },
    { label: 'AccountName', fieldName: 'AccountName', type: 'text' },
    { label: 'Subject', fieldName: 'Subject', type: 'text' },
    { label: 'Type', fieldName: 'Type', type: 'text' },
    { label: 'Sub Type', fieldName: 'Sub_Type__c', type: 'text' }
];

export default class BulkCloseCases extends LightningElement {
    columns = Casecolumns;
    @api recordId;
    @track CaseData = [];
    @track showUnder2ndPage = false;
    error;
    SelectedId = [];
    closureRemark = [];
    CaseList = [];
    closureRemarksUpdationList=[];
    draftValuesMap = new Map();
    @track val1 = {};
    @track casesToUpdate = [];


    connectedCallback() {
        setTimeout(() => {
            this.fetchCaseData();
        }, 500);
    }

    fetchCaseData() {
        bulkCloseCasesMeth()
            .then(data => {
                if (data.length > 0) {
                    this.CaseData = data;
                    this.showUnder2ndPage = true;
                } else {
                    this.showUnder2ndPage = false;
                    this.showToast('No Cases', 'Currently there are no cases.', 'warning');
                }
                if (data) {
                    data.forEach(element => {
                        if (element.AccountId) {
                            element.AccountName = element.Account.Name;
                        }

                    });
                }
                console.log('Data', data);
            })
            .catch(error => {
                this.showUnder2ndPage = false;
                this.showToast('Error', 'An error occurred while fetching case data.', 'error');
                console.error('Error:', error);
            });
    }

    handleRowSelection(event) {
        debugger;
        var selectedRows = event.detail.selectedRows;
        this.CaseList = selectedRows;
        var CaseListToIterate = this.CaseList;
        var CaseIdList = [];
        for (var i in CaseListToIterate) {
            CaseIdList.push(CaseListToIterate[i].Id);
        }
        this.SelectedId = CaseIdList;
    }
handleCellChange(event) {
    debugger;
    const drafts = event.detail.draftValues;

    drafts.forEach(draftValue => {
        const fields = Object.assign({}, draftValue);
        //console.log(JSON.stringify(fields['Id']));  // Debugging to check the Id
        this.val1 = JSON.parse(JSON.stringify(fields));
    });
    //this.draftValuesMap.set(this.val1.Id, this.val1.Case_Reason_Description__c);
    for(var i in this.casesToUpdate){
        if(this.casesToUpdate[i]['Id'] == this.val1.Id){
            this.casesToUpdate.splice(i,1);
        }
    }
    this.casesToUpdate.push(this.val1);
    console.log('this.casesToUpdate',JSON.stringify(this.casesToUpdate)); 
}



    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    handleSave() {
        debugger;
        if(this.casesToUpdate.length>0){
            this.SelectedId = this.casesToUpdate.map(caseItem => caseItem.Id)
        }
        updateCase({ caselist :  this.casesToUpdate})
        // ClosureRemark: this.closureRemark, casesIds: this.SelectedId
      
            .then(result => {
                this.showToast('Success', result, 'success');
                this.fetchCaseData();
                this.closeAction();
                //this.handleCellChange();

            })
            
            .catch(error => {
                this.showToast('Error', 'An error occurred while updating cases.', 'error');
                console.error('Error:', error);
            });
    }

    // async handleDraft(event){
    //     var drafts = event.detail.draftValues.slice().map((draftValue)=>{
    //         const fields = Object.assign({}, draftValue);
    //         cosole.log(fields);
    //     });
    // }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}