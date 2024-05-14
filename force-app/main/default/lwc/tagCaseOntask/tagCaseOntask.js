import { LightningElement, api, track } from 'lwc';
import modal from "@salesforce/resourceUrl/custommodalcss";
import { loadStyle } from "lightning/platformResourceLoader";
import tagCaseOnTask from '@salesforce/apex/taskTriggerHelper.tagCaseOnTask';
import getAllCasesTasksAndCurrentTask from '@salesforce/apex/taskTriggerHelper.getAllCasesTasksAndCurrentTask';
import taggedCase from '@salesforce/apex/taskTriggerHelper.taggedCase';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';




const Taskcolumns = [
    { label: 'CaseNumber', fieldName: 'CaseNumber', type: 'AutoNumber' },
    { label: 'Subject', fieldName: 'Subject', type: 'text' },
    { label: 'Customer Phone No', fieldName: 'customerPhone', type: 'text' },
    { label: 'Call Direction', fieldName: 'Exotel_CTI__Call_Direction__c', type: 'text' },
    { label: 'Start Time', fieldName: 'Exotel_CTI__Start_Time__c', type: 'text' },
];

let i = 0;

export default class TagCaseOntask extends LightningElement {

    @api recordId;
    columns = Taskcolumns;
    @track TaskData = [];
    @track thisTask = [];
    @track show1stPage = false;
    @track showUnder1stPage = false;
    @track showUnder2ndPage = false;
    @track show2ndPage = false;
    @track showCase = false;
    data = [];
    @track items = [];
    @track preSelectedRows = [];
    selectedTaskId = [];
    TaskList = [];
    @track selectedRowsFromPage1 = [];
    wrapObject = {};
    result;
    error;
    @track value = '';

    get AllCases() {
        return this.items;
    }


    @api childcompname = 'CloseScreenAction';




    connectedCallback() {
        debugger;
      //  loadStyle(this, modal);
        setTimeout(() => {
            this.callApexMethod1();
            this.callApexMethod2();
        }, 700);
    }



    callApexMethod1() {
        debugger;
        tagCaseOnTask({ recId: this.recordId })
            .then(result => {
                if (result != null || result != undefined) {
                    if (result.CurrTaskList != undefined) {
                        for (i = 0; i < result.CurrTaskList.length; i++) {
                            this.thisTask = result.CurrTaskList;
                            this.preSelectedRows.push(this.thisTask[0].Id);
                            this.show1stPage = true;
                        }
                        result.CurrTaskList.forEach(element => {
                            if (element.Case__r.CaseNumber) {
                                element.CaseNumber = element.Case__r.CaseNumber;
                            }
                        });
                    }
                    if (result.taskList != undefined) {
                        for (i = 0; i < result.taskList.length; i++) {
                            this.TaskData = result.taskList;
                            this.showUnder1stPage = true;
                        }
                        result.taskList.forEach(element => {
                            if (element.Exotel_CTI__Call_Direction__c == 'Inbound') {
                                element.customerPhone = element.Exotel_CTI__From__c;
                            }
                            if(element.Exotel_CTI__Call_Direction__c == 'OutBound'){
                                element.customerPhone = element.Exotel_CTI__To__c;
                            }
                        });
                    }
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.TaskData = undefined;
            });
    }

    callApexMethod2() {
        debugger;
        getAllCasesTasksAndCurrentTask({ recId: this.recordId })
            .then(result => {
                if (result != null || result != undefined) {
                    if (result.CurrentTaskList != undefined) {
                        for (i = 0; i < result.CurrentTaskList.length; i++) {
                            this.thisTask = result.CurrentTaskList;
                            this.preSelectedRows.push(this.thisTask[0].Id);
                            this.show2ndPage = true;
                            this.show1stPage = false;
                        }
                    }
                    if (result.tuskList != undefined) {
                        for (i = 0; i < result.tuskList.length; i++) {
                            this.TaskData = result.tuskList;
                            this.showUnder2ndPage = true;
                        }
                        result.tuskList.forEach(element => {
                            if (element.Exotel_CTI__Call_Direction__c == 'Inbound') {
                                element.customerPhone = element.Exotel_CTI__From__c;
                            }
                            if(element.Exotel_CTI__Call_Direction__c == 'OutBound'){
                                element.customerPhone = element.Exotel_CTI__To__c;
                            }
                        });
                    }
                    if (result.caseList != undefined) {
                        this.data = result.caseList;
                        for (i = 0; i < this.data.length; i++) {
                            console.log('id === >' + this.data[i].Id);
                            this.items = [...this.items, { value: this.data[i].Id, label: this.data[i].CaseNumber }];
                            this.showCase = true;
                        }
                    }
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.thisTask = undefined;
            });
    }

    handleRowSelection(event) {
        debugger;
        var selectedRows = event.detail.selectedRows;
        this.TaskList = selectedRows;
        var TaskListToIterate = this.TaskList;
        var TaskIdList = [];
        for (var i in TaskListToIterate) {
            TaskIdList.push(TaskListToIterate[i].Id);
        }
        this.selectedTaskId = TaskIdList;
        this.selectedRowsFromPage1 = event.detail.selectedRows;

    }

    handleChange(event) {
        debugger;
        this.caseId = event.detail.value;
    }
    closeAction() {
        debugger;
        
        const storeEvent = new CustomEvent('myfirstevent', {
            detail: 'CloseQuickAction'
        }
        );
        this.dispatchEvent(storeEvent)
        this.dispatchEvent(new CloseActionScreenEvent());
    }


    handleSave() {
        debugger;
        var obj = {
            'TaskId': this.preSelectedRows,
            'relatedTaskId': this.selectedTaskId,
            'CaseId': this.caseId
        };
        this.wrapObject = obj;

        taggedCase({ jsonData: JSON.stringify(this.wrapObject) })
            .then(result => {
                this.result = result;
                const event = new ShowToastEvent({
                    title: 'Toast message',
                    message: 'updated Successfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                const storeEvent = new CustomEvent('myfirstevent', {
                    detail: 'CloseQuickAction'
                }
                );
                this.dispatchEvent(storeEvent)
            })
            .catch(error => {
                this.error = error;
                const event = new ShowToastEvent({
                    title: 'Toast message',
                    message: 'Some Error Occured',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            })

    }
}