import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getOrderLineItems from '@salesforce/apex/CaseHelperController.getOrderLineItems';

const FIELDS = ['Case.OrderId__c'];

export default class OrderDetailItems extends LightningElement {
    @api recordId;

    caseRecord;
    orderLineItems;
    orderValue;
    orderNumber;
    accountName;
    orderDate;
    shippingNumber;
    discountValue;
    paymentId;
    loginNumber;
    orderStatus;
    couponCode;

    fixedWidth = "width:15rem;";

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ error, data }) {
        if (data) {
            this.caseRecord = data;
            this.loadOrderLineItems(data.fields.OrderId__c.value);
        } else if (error) {
            console.error('Error loading case record', error);
        }
    }

    loadOrderLineItems(orderId) {
        debugger;
        getOrderLineItems({ orderId: orderId })
            .then(result => {
                this.orderLineItems = result;
                this.orderValue = result[0].Order.ParentOrder__r.Paid_Amount__c;
                this.accountName = result[0].Order.ParentOrder__r.Shipping_Name__c;
                this.orderNumber = result[0].Order.ParentOrder__r.Name;
                this.orderDate = result[0].Order.ParentOrder__r.EffectiveDate;
                this.shippingNumber = result[0].Order.ParentOrder__r.Delivery_Mobile_Number__c;
                this.discountValue = result[0].Order.ParentOrder__r.Coupon_Discount__c;
                this.paymentId = result[0].Order.ParentOrder__r.Payment_Id__c;
                this.loginNumber = result[0].Order.Account.Phone;
                this.orderStatus = result[0].Order.ParentOrder__r.Payment_Status__c;
                this.couponCode = result[0].Order.ParentOrder__r.Coupon_Code__c;
                this.shippingaddress1 = result[0].Order.ParentOrder__r.ShippingStreet +',';
                this.shippingaddress2 = result[0].Order.ParentOrder__r.ShippingCity + ',';
                this.shippingaddress3 =  result[0].Order.ParentOrder__r.ShippingState + ',';
                this.shippingaddress4 = result[0].Order.ParentOrder__r.ShippingCountry + ',';
                this.shippingpostalcode = result[0].Order.ParentOrder__r.ShippingPostalCode;
            })
            .catch(error => {
                console.error('Error loading order line items', error);
            });
    }

    fixedWidth = "width:15rem;";
 
    //FOR HANDLING THE HORIZONTAL SCROLL OF TABLE MANUALLY
    tableOuterDivScrolled(event) {
        this._tableViewInnerDiv = this.template.querySelector(".tableViewInnerDiv");
        if (this._tableViewInnerDiv) {
            if (!this._tableViewInnerDivOffsetWidth || this._tableViewInnerDivOffsetWidth === 0) {
                this._tableViewInnerDivOffsetWidth = this._tableViewInnerDiv.offsetWidth;
            }
            this._tableViewInnerDiv.style = 'width:' + (event.currentTarget.scrollLeft + this._tableViewInnerDivOffsetWidth) + "px;" + this.tableBodyStyle;
        }
        this.tableScrolled(event);
    }
 
    tableScrolled(event) {
        if (this.enableInfiniteScrolling) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('showmorerecords', {
                    bubbles: true
                }));
            }
        }
        if (this.enableBatchLoading) {
            if ((event.target.scrollTop + event.target.offsetHeight) >= event.target.scrollHeight) {
                this.dispatchEvent(new CustomEvent('shownextbatch', {
                    bubbles: true
                }));
            }
        }
    }
 
    //#region ***************** RESIZABLE COLUMNS *************************************/
    handlemouseup(e) {
        this._tableThColumn = undefined;
        this._tableThInnerDiv = undefined;
        this._pageX = undefined;
        this._tableThWidth = undefined;
    }
 
    handlemousedown(e) {
        if (!this._initWidths) {
            this._initWidths = [];
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            tableThs.forEach(th => {
                this._initWidths.push(th.style.width);
            });
        }
 
        this._tableThColumn = e.target.parentElement;
        this._tableThInnerDiv = e.target.parentElement;
        while (this._tableThColumn.tagName !== "TH") {
            this._tableThColumn = this._tableThColumn.parentNode;
        }
        while (!this._tableThInnerDiv.className.includes("slds-cell-fixed")) {
            this._tableThInnerDiv = this._tableThInnerDiv.parentNode;
        }
        console.log("handlemousedown this._tableThColumn.tagName => ", this._tableThColumn.tagName);
        this._pageX = e.pageX;
 
        this._padding = this.paddingDiff(this._tableThColumn);
 
        this._tableThWidth = this._tableThColumn.offsetWidth - this._padding;
        console.log("handlemousedown this._tableThColumn.tagName => ", this._tableThColumn.tagName);
    }
 
    handlemousemove(e) {
        console.log("mousemove this._tableThColumn => ", this._tableThColumn);
        if (this._tableThColumn && this._tableThColumn.tagName === "TH") {
            this._diffX = e.pageX - this._pageX;
 
            this.template.querySelector("table").style.width = (this.template.querySelector("table") - (this._diffX)) + 'px';
 
            this._tableThColumn.style.width = (this._tableThWidth + this._diffX) + 'px';
            this._tableThInnerDiv.style.width = this._tableThColumn.style.width;
 
            let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
            let tableBodyRows = this.template.querySelectorAll("table tbody tr");
            let tableBodyTds = this.template.querySelectorAll("table tbody .dv-dynamic-width");
            tableBodyRows.forEach(row => {
                let rowTds = row.querySelectorAll(".dv-dynamic-width");
                rowTds.forEach((td, ind) => {
                    rowTds[ind].style.width = tableThs[ind].style.width;
                });
            });
        }
    }
 
    handledblclickresizable() {
        let tableThs = this.template.querySelectorAll("table thead .dv-dynamic-width");
        let tableBodyRows = this.template.querySelectorAll("table tbody tr");
        tableThs.forEach((th, ind) => {
            th.style.width = this._initWidths[ind];
            th.querySelector(".slds-cell-fixed").style.width = this._initWidths[ind];
        });
        tableBodyRows.forEach(row => {
            let rowTds = row.querySelectorAll(".dv-dynamic-width");
            rowTds.forEach((td, ind) => {
                rowTds[ind].style.width = this._initWidths[ind];
            });
        });
    }
 
    paddingDiff(col) {
 
        if (this.getStyleVal(col, 'box-sizing') === 'border-box') {
            return 0;
        }
 
        this._padLeft = this.getStyleVal(col, 'padding-left');
        this._padRight = this.getStyleVal(col, 'padding-right');
        return (parseInt(this._padLeft, 10) + parseInt(this._padRight, 10));
 
    }
 
    getStyleVal(elm, css) {
        return (window.getComputedStyle(elm, null).getPropertyValue(css))
    }
 
}