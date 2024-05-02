import { LightningElement, api, track } from 'lwc';
import getRelatedCases from '@salesforce/apex/CaseHelperControllers.mergeCaseBasedOnAccIdConIdEmailIdPhoneNumberInstagram';
import { CloseActionScreenEvent } from 'lightning/actions';
import mergeDuplicateCases from '@salesforce/apex/CaseHelperControllers.mergeDuplicateCases';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from "lightning/uiRecordApi";

const Casecolumns = [
    { label: 'Case Number', fieldName: 'CaseNumber', type: 'AuotNumber' },
    { label: 'Order No', fieldName: 'Order_Number__c', type: 'AuotNumber' },
    { label: 'Case Origin', fieldName: 'Origin', type: 'PickList' },
    { label: 'RecordType', fieldName: 'recordtype', type: 'text' },
    { label: 'Sub Type', fieldName: 'Sub_Type__c', type: 'text' },
    { label: 'Sub Sub type', fieldName: 'Sub_Sub_Type__c', type: 'text' },
    
];

export default class MergeDuplicateCase extends LightningElement {
    @api recordId;
    casesData;
    error;
    errors;
    @track selectedCase;
    @track recordIds;
    columns = Casecolumns;
    CaseList = [];
    selectedCaseId = [];
    @track preSelectedRows;
    show1stPage = false;
    show2ndPage = false;
    @track selectedRowsFromPage1 = [];
    @track selectedRowsObjects = [{}];
    onlyOneRowWhichIsSelectedId;

    connectedCallback() {
        setTimeout(() => {
            this.callApexMethod();
            this.callApexMethod2();
        }, 300);
    }



    callApexMethod() {
        debugger;
        getRelatedCases({ recId: this.recordId })
            .then(result => {
                
                if (result) {
                    result.forEach(element => {
                        if (element.OrderId__c) {
                            element.orderNumber = element.OrderId__r.Name;
                        }
                        if (element.RecordType.Name) {
                            element.recordtype = element.RecordType.Name;
                        }
                    });
                }
                this.casesData = result;
                // var setRows = [];
                // for (var i = 0; i < this.casesData.length; i++) {
                //     setRows.push(this.casesData[i].Id);
                // }
                // this.preSelectedRows = setRows;
                // this.selectedRowsObjects = this.preSelectedRows;
                this.error = undefined;
                this.show1stPage = true;
            })
            .catch(error => {
                this.error = error;
                this.casesData = undefined;
            });
    }

    handleBack() {
        this.show1stPage = true;
        this.show2ndPage = false;
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    
    handleRowSelection(event){
        var selectedRows = event.detail.selectedRows;
        this.CaseList = selectedRows;
        var CaseListToIterate = this.CaseList;
        var CaseIdList = [];
        for (var i in CaseListToIterate) {
            CaseIdList.push(CaseListToIterate[i].Id);
        }
        this.selectedCaseId = CaseIdList;
    }


    mergeRelatedCases() {
        debugger;
        mergeDuplicateCases({ cases: this.selectedCaseId })
            .then(result => {
                this.selectedCase = result;
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Record updated!",
                        variant: "success",
                    })
                );
                getRecordNotifyChange([{ recordId: this.recordId }]);
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
                getRecordNotifyChange([{ recordId: this.recordId }]);
            });
    }
}