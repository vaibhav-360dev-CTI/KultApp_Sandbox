import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getCaseById from '@salesforce/apex/referBackToCsTeamController.getCaseById';
import getCaseAndOrderDetails from '@salesforce/apex/referBackToCsTeamController.getCaseAndOrderDetails';
import getCaseTeamAndType from '@salesforce/apex/referBackToCsTeamController.getCaseTeamAndType';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getPicklistValues} from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import REFERBACKREASON_FIELD from '@salesforce/schema/Case.Refer_Back_Reason__c';
import Tech_Issue from '@salesforce/schema/Case.Tech_Issue_Type__c';
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import Id from '@salesforce/user/Id'
import ProfileName from '@salesforce/schema/User.Profile.Name'; 
const MAX_FILE_SIZE = 4718592;
const CHUNK_SIZE = 750000;
export default class ReferBackToCSTeam extends LightningElement {



    @track ListOfCaseRecords = [];
    @track error;
    @track wareHouseOrderRelated = false;
    @track refundResolved = false;
    @track result;
    @track referBack;
    @track awbNumber;
    @track focOrderId;
    @track RequestApprove = false;
    @track RequestReject = false;
    @track NeedMoreInfo = false;
    @track SendUpdate = false;
    @track resolved = false;
    @track referBackReason;
    @track resolutionRemarks;
    @track refundAmount;
    @track approvalRemarks;
    @track rejectionRemarks;
    @track rejectionReason;
    @track describeInformationNeeded;
    @track updateDesc;
    @track orderId;
    @track orderRefundAmount;
    @track adminResolved = false;
    @track techIssue;
    @track techIssueList=[];
    @track isLoading=false;
    returnValue;
    RefrebackOption=[];
    userProfileName;
    fileData = {
        'filename': null,
        'base64': null,
        'recordId': this.recordId
    }


    @api recordId;

    @wire(getRecord, {recordId: Id, fields: [ProfileName]})
    userDetails({data,error}){
        debugger;
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.displayValue != null) {
                this.userProfileName = data.fields.Profile.displayValue;
                if(this.userProfileName == "System Administrator"){
                    this.adminResolved = true;
                }
            }
    }
}

    @wire(getPicklistValues, {recordTypeId: '012000000000000AAA', fieldApiName: REFERBACKREASON_FIELD})
    referbackField({data,error}){
        if(data){
            console.log(data);
            this.RefrebackOption = this.getPicklist(data);
        }else{
            console.log(error);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '012000000000000AAA', fieldApiName: Tech_Issue})
    techIssueField({data,error}){
        if(data){
            console.log(data);
            this.techIssueList = this.getPicklist(data);
        }else{
            console.log(error);
        }
    }

    getPicklist(data){
        return data.values.map(item=>({label:item.label, value: item.value}));
    }

    connectedCallback() {
        debugger;
        console.log('recordId====>' + this.recordId);
        setTimeout(() => {
            this.getCaseDetails();
            this.getCaseTeamAndType();
        }, 300);
    }

    getCaseTeamAndType() {
        debugger;
        getCaseTeamAndType({ caseId: this.recordId })
            .then((result) => {
                if (result == 'showFOCandAWB') {
                    this.wareHouseOrderRelated = true;
                    this.refundResolved = false;
                }else if (result == 'showRefundAmount') {
                    this.refundResolved = true;
                    this.wareHouseOrderRelated = false;
                } else {
                    console.log('No cases found for the provided ID');
                }
            }).catch((err) => {
                console.error('Error retrieving contacts:', err);
            });
    }

    getCaseDetails() {
        debugger;
        getCaseById({ caseId: this.recordId })
            .then((result) => {
                if (result) {
                    this.ListOfCaseRecords.push(result);
                    this.approvalRemarks = result.Approval_Remarks__c;
                    //this.refundAmount = result.OrderId__r.Refund_Amount__c;

                    // this.rejectionRemarks = result.Rejection_Remarks__c;
                    this.rejectionReason = result.Rejection_Reason__c;

                    // this.describeInformationNeeded = result.Describe_Information_Needed__c;
                    // this.resolutionRemarks = this.describeInformationNeeded;

                    
                    // if(result.Refund_Type__c == 'Full'){
                    //     this.refundAmount = result.Refund_Amount__c;
                    // }
                    this.refundAmount = result.Refund_Amount__c;

                    if(result.Refund_Type__c != 'Special Case Refund'){
                            this.disableRefundAmt = true;
                        }


                    console.log('Cases retrieved successfully');
                } else {
                    console.log('No cases found for the provided ID');
                }
            }).catch((err) => {
                console.error('Error retrieving contacts:', err);
            });
    }
    
    openfileUpload(event) {
        debugger;
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)
    }

    handelreferbackChange(event) {
        debugger;
        this.referBack = event.target.value;
        this.referBackReason = this.referBack;

        // if (this.referBack === 'Refund Processed' || this.referBack === 'Cancellation Processed') {
        //     this.RequestApprove = true;
        //     this.RequestReject = false;
        //     this.NeedMoreInfo = false;
        // }
        // else if (this.referBack === 'Refund Rejected' || this.referBack === 'Cancellation Rejected') {
        //     this.RequestApprove = false;
        //     this.RequestReject = true;
        //     this.NeedMoreInfo = false;
        // }
        if(this.referBack === 'Resolved'){
            this.resolved = true;
            this.NeedMoreInfo = false;
            this.SendUpdate = false;
        }
        else if (this.referBack === 'Need More Info') {
            this.RequestApprove = false;
            this.RequestReject = false;
            this.NeedMoreInfo = true;
            this.resolved = false;
            this.SendUpdate = false;
        }
        else if (this.referBack === 'Send Update') {
            this.SendUpdate = true;
            this.resolved = false;
            this.NeedMoreInfo = false;
        }

    }

    handelTechIssue(event){
        this.techIssue = event.target.value;
    }

    handelApprovalremark(event) {
        debugger;
        this.approvalRemarks = event.target.value;
    }

    handleAWBNumber(event) {
        debugger;
        this.awbNumber = event.target.value;
    }

    handleRefundAmt(event){
        debugger;
        this.refundAmount = event.target.value;
    }

    handleFOCorderId(event) {
        debugger;
        this.focOrderId = event.target.value;
    }

    // handelRefundAmount(event) {
    //     debugger;
    //     this.refundAmount = event.target.value;
    // }

    // handelRejectionmark(event) {
    //     debugger;
    //     this.rejectionRemarks = event.target.value;
    // }

    handelRejectionreason(event) {
        debugger;
        this.rejectionReason = event.target.value;
    }

    handeldescribeInformation(event) {
        debugger;
        this.describeInformationNeeded = event.target.value;
    }

    handeldescribeUpdate(event) {
        debugger;
        this.updateDesc = event.target.value;
    }

    handelResolutionRemarks(event){
        debugger;
        this.resolutionRemarks  = event.target.value;
    }


    handleSave() {
        debugger;

        if (this.referBack == undefined || this.referBack == null || this.referBack == '') {
            alert("Enter Refer Back Reason");
            return null;
        }

        if (this.referBack == 'Refund Processed' || this.referBack === 'Cancellation Processed') {
            if (this.approvalRemarks == undefined || this.approvalRemarks == null || this.approvalRemarks == '') {
                alert("Enter Approval Remarks");
                return null;
            }

            // if (this.refundAmount == undefined || this.refundAmount == null || this.refundAmount == '') {
            //     alert("Enter Refund Amount");
            //     return null;
            // }
        }

        if (this.referBack == 'Refund Rejected' || this.referBack === 'Cancellation Rejected') {
            // if (this.rejectionRemarks == undefined || this.rejectionRemarks == null || this.rejectionRemarks == '') {
            //     alert("Enter Rejection Remarks");
            //     return null;
            // }

            if (this.rejectionReason == undefined || this.rejectionReason == null || this.rejectionReason == '') {
                alert("Enter Rejection Reason");
                return null;
            }
        }


        if (this.referBack == 'Need More Info') {
            if (this.describeInformationNeeded == undefined || this.describeInformationNeeded == null || this.describeInformationNeeded == '') {
                alert("Enter Describe Info Needed");
                return null;
            }
        }

        if (this.referBack == 'Resolved') {
            if (this.resolutionRemarks == undefined || this.resolutionRemarks == null || this.resolutionRemarks == '') {
                alert("Enter Resolution Remarks");
                return null;
            }
        }

        if (this.referBack == 'Send Update') {
            if (this.updateDesc == undefined || this.updateDesc == null || this.updateDesc == '') {
                alert("Enter Send Update Details");
                return null;
            }
        }
        this.isLoading = true;
        debugger;
        const {base64, filename, recordId} = this.fileData;
        getCaseAndOrderDetails({
            caseId: this.recordId,
            referBackReason: this.referBackReason,
            refundAmount: this.refundAmount,
            approvalRemarks: this.approvalRemarks,
            //rejectionRemarks: this.rejectionRemarks,
            rejectionReason: this.rejectionReason,
            describeInformationNeeded: this.describeInformationNeeded,
            //orderId:this.orderId,
            orderRefundAmount: this.orderRefundAmount,
            resolutionRemarks: this.resolutionRemarks,
            updateDesc : this.updateDesc,
            base64: base64,
            filename: filename,
            awbNumber: this.awbNumber,
            focOrderId: this.focOrderId,
            techIssueType: this.techIssue,
            isRefundCase: this.refundResolved
        })
            .then((result) => {
                console.log("result===>" + JSON.stringify(result));
                this.returnValue = result;
                if(this.returnValue == 'Success'){
                this.showToast('Success', 'Records saved successfully', 'success');
                this.handleClose();
                getRecordNotifyChange([{ recordId: this.recordId }]);
                }else{
                    this.showToast('Error', this.returnValue, 'error');
                }
                this.isLoading = false;
            }).catch((err) => {
                console.log("err===>" + JSON.stringify(err));
                this.error = err;
                this.showToast('Error', 'Error occurred while saving records', 'error');
                this.isLoading = false;
            });

    }

    handleCancel() {
        this.handleClose();
    }

    handleClose() {
        const closeActionEvent = new CloseActionScreenEvent();
        this.dispatchEvent(closeActionEvent);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

}