import { LightningElement, track, api, wire } from 'lwc';
import getAllPickListVal from '@salesforce/apex/csOutboundCallController.getAllPickListVal';
import getParentCaseDetails from '@salesforce/apex/csOutboundCallController.getParentCaseDetails';
import updateCaseDetails from '@salesforce/apex/csOutboundCallController.updateCaseDetails';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CsOutboundCalls extends LightningElement {
    @api recordId;
    @track parentCaseDetails = {};

    @wire(getParentCaseDetails, { recordId: '$recordId' })
    wiredDetails({ data, error }) {
        debugger;
        if (data) {
            this.parentCaseDetails = data;
            this.getAllPicklistValues();
        } else if (error) {
            console.error('Error==>' + error);
        }
    }

    objByField = {
        Type_of_Call__c: 'Case',
        Call_Status__c: 'Case',
        Interest_Level__c: 'Case',
        Appointment_Booked__c: 'Case',
        Order_Placed__c: 'Case',
        Callback_Requested__c: 'Case',
        CSE_Remarks__c: 'Case'
    };

    @track typeOfCallOptions = [];
    @track callStatusOptions = [];
    @track interestLevelOptions = [];
    @track appointmentOptions = [];
    @track orderPlacedOptions = [];
    @track callbackReqOptions = [];

    getAllPicklistValues() {
        getAllPickListVal({ ObjectByField: this.objByField })
            .then(result => {
                debugger;
                this.typeOfCallOptions = this.mapToLabelValuePair(result['Type_of_Call__c']);
                this.callStatusOptions = this.mapToLabelValuePair(result['Call_Status__c']);
                this.interestLevelOptions = this.mapToLabelValuePair(result['Interest_Level__c']);
                this.appointmentOptions = this.mapToLabelValuePair(result['Appointment_Booked__c']);
                this.orderPlacedOptions = this.mapToLabelValuePair(result['Order_Placed__c']);
                this.callbackReqOptions = this.mapToLabelValuePair(result['Callback_Requested__c']);
            })
            .catch(error => {
                console.error('Error==>' + error);
            });
    }

    mapToLabelValuePair(values) {
        return values.map(value => ({
            label: value, value: value
        }));
    }

    @track hideFields = false;
    handleChange(event) {
        debugger;
        const fieldName = event.target.name;
        const fieldValue = event.target.value;

        if(fieldName == 'Type_of_Call__c' && fieldValue == 'Sales'){
            this.hideFields = false;
        }else if(fieldName == 'Type_of_Call__c' && (fieldValue == 'Feedback' || fieldValue == 'Service')){
            this.hideFields = true;
        }

        this.parentCaseDetails = { ...this.parentCaseDetails, [fieldName]: fieldValue };
    }

    handleSave() {
        updateCaseDetails({ caseRec: this.parentCaseDetails })
            .then(result => {
                console.log('case updated==>' + result);
                this.showToast('Success', 'Case Updated!!!', 'success');
                this.handleCancel();
            })
            .catch(error => {
                console.error('Error updating case==>' + error);
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    handleCancel() {
        this.closeQuickAction();
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}