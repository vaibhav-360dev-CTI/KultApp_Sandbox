import { LightningElement,api,track } from 'lwc';
import getTaskOfCaseBasedOnAccountId from '@salesforce/apex/taskCaseHelper.getTaskOfCaseBasedOnAccountId';

export default class TasksOfCase extends LightningElement {
    @api recordId;
    @track show1 = false;
    @track show2 = false;
    contacts;

    connectedCallback(){
        setTimeout(() => {
            this.doSearch();  
        },300);
    }

    doSearch() {
        getTaskOfCaseBasedOnAccountId({ recId: this.recordId})
            .then(result => {
                this.contacts = result;
                if(this.contacts == true){
                    this.show1 = true;
                    this.show2 = false;
                }else if(this.contacts == false){
                    this.show1 = false;
                    this.show2 = true;
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.contacts = undefined;
            });
    }
}