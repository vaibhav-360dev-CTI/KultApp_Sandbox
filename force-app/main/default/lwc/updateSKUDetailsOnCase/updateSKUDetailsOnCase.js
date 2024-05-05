import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getOrderIfItHasLineItems from '@salesforce/apex/CaseHelperControllers.getOrderIfItHasLineItems';
import getOrderItems from '@salesforce/apex/CaseHelperControllers.getOrderItems';
import updateSKUdetailsAndCreateRecordOfSKU from '@salesforce/apex/CaseHelperControllers.updateSKUdetailsAndCreateRecordOfSKU';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';


export default class UpdateSKUDetailsOnCase extends LightningElement {

    selectedSalesUserId;
    inpName;
    selectedOrd;
    @track orderHasItemAvailable = false;
    @track AllOrderItems = [];
    @track OrderList = [];
    @track selectedOrderId = [];
    selectedRows = [];
    selecteRowsMap = [{}];
    @track show1stPage = true;
    @track show2ndPage = false;
    data;
    error;
    OrderNumberForAffectedQuantity;
    @track CaseOrderAndOrderLineItem = [];
    @track orderNameOrNumberAvailable = false;
    @track orderDate;
    @track orderNumberOrName;
    @track orderchangedateDates = false;
    @track PaidAmountofOrder;
    @track PaidAmount = false;
    ordersId;
    @api recordId;

    @track allKeys = '';
    @track message;
    @track error;
    @track recordTypeId = '';


    allSelected(event) {
        debugger;
        let selectedRows = this.template.querySelectorAll('lightning-input');
        
        for(let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i].type === 'checkbox') {
                selectedRows[i].checked = event.target.checked;
            }
        }
    
        if (this.AllOrderItems && this.AllOrderItems.length > 0) {
            if (event.target.checked) {
                
                for (let i = 0; i < this.AllOrderItems.length; i++) {
                    this.AllOrderItems[i].Affected_Quantity__c = this.AllOrderItems[i].totalQuantity;
                    this.AllOrderItems[i].disabled = false;
                    this.selectedRows.push(this.AllOrderItems[i].Id);
                }
                this.orderHasItemAvailable = true;
                
            } else {
                
                for (let i = 0; i < this.AllOrderItems.length; i++) {
                    this.AllOrderItems[i].Affected_Quantity__c = null;
                    this.AllOrderItems[i].disabled = true;
                    this.selectedRows = [];
                }
                this.orderHasItemAvailable = true; 
            }
        } 
    }
    

    

    connectedCallback() {

        var url = window.location.href.toString();
        const queryParams = url.split("&");
        const recordIdParam = queryParams.find(param => param.includes("recordId"));

        if (recordIdParam) {
            const recordIdKeyValue = recordIdParam.split("=");
            if (recordIdKeyValue.length === 2) {
                const recordId = recordIdKeyValue[1];
                this.recordId = recordId;
            } else {
                console.error("Invalid recordId parameter format");
            }
        } else {
            console.error("recordId parameter not found in the URL");
        }
        this.doSearch();
        //this.callAllOrderItems1();
    }

    callAllOrderItems() {
        debugger;
        this.AllOrderItems = [];
        getOrderItems({ OrdId: this.selectedRecordIdFromParent })
            .then(result => {
                result.forEach(item => {
                    this.AllOrderItems.push({
                        productName: item.Product2.Name,
                        Id: item.Id,
                        Affected_Quantity__c: item.Affected_Quantity__c,
                        totalQuantity: item.Quantity,
                        Selling_Price__c: item.Selling_Price__c,
                        UnitPrice: item.UnitPrice,
                        totalprice: item.Total_Selling_Price__c,
                        skudetail: item.SKU__c,
                        brand : item.Brand__c,
                        disabled: true
                    });
                });
                this.error = undefined;
                this.orderHasItemAvailable = true;
            })
            .catch(error => {
                this.error = error;
                this.AllOrderItems = undefined;
            });
    }
    callAllOrderItems1() {
        debugger;
        this.AllOrderItems = [];
        getOrderItems({ OrdId: this.OrderNumberForAffectedQuantity })
            .then(result => {
                result.forEach(item => {
                    this.AllOrderItems.push({
                        productName: item.Product2.Name,
                        Id: item.Id,
                        Affected_Quantity__c: item.Affected_Quantity__c,
                        totalQuantity: item.Quantity,
                        Selling_Price__c: item.Selling_Price__c,
                        UnitPrice: item.UnitPrice,
                        totalprice: item.Total_Selling_Price__c,
                        skudetail: item.SKU__c,
                        brand : item.Brand__c,
                        disabled: true
                    });
                });
                this.error = undefined;
                this.orderHasItemAvailable = true;
            })
            .catch(error => {
                this.error = error;
                this.AllOrderItems = undefined;
            });
    }


    doSearch() {
        debugger;
        getOrderIfItHasLineItems({
            recId: this.recordId
        }).then(result => {
            this.CaseOrderAndOrderLineItem = result;

            if (this.CaseOrderAndOrderLineItem && this.CaseOrderAndOrderLineItem.length > 0) {

                // Order is available
                this.OrderNumberForAffectedQuantity = this.CaseOrderAndOrderLineItem[0].OrderId;

                
            if(this.CaseOrderAndOrderLineItem[0].Order.ParentOrder__c != null){
                if (this.CaseOrderAndOrderLineItem[0].Order.ParentOrder__r.Name != null) {
                    this.orderNumberOrName = this.CaseOrderAndOrderLineItem[0].Order.ParentOrder__r.Name;
                    this.orderNameOrNumberAvailable = true;
                } else {
                    this.orderNumberOrName = this.CaseOrderAndOrderLineItem[0].Order.ParentOrder__r.OrderNumber;
                    this.orderNameOrNumberAvailable = true;
                }
                if (this.CaseOrderAndOrderLineItem[0].Order.ParentOrder__r.CreatedDate != null) {
                    this.orderDate = this.CaseOrderAndOrderLineItem[0].Order.ParentOrder__r.CreatedDate;
                    this.orderchangedateDates = true;
                }

                if (this.CaseOrderAndOrderLineItem[0].Order.ParentOrder__r.Paid_Amount__c != null) {
                    this.PaidAmountofOrder = this.CaseOrderAndOrderLineItem[0].Order.ParentOrder__r.Paid_Amount__c;
                    this.PaidAmount = true;
                }

                if (this.CaseOrderAndOrderLineItem[0].OrderId != null) {
                    this.ordersId = this.CaseOrderAndOrderLineItem[0].OrderId;
                }
            }else{
                if (this.CaseOrderAndOrderLineItem[0].Order.Name != null) {
                    this.orderNumberOrName = this.CaseOrderAndOrderLineItem[0].Order.Name;
                    this.orderNameOrNumberAvailable = true;
                } else {
                    this.orderNumberOrName = this.CaseOrderAndOrderLineItem[0].Order.OrderNumber;
                    this.orderNameOrNumberAvailable = true;
                }
                if (this.CaseOrderAndOrderLineItem[0].Order.CreatedDate != null) {
                    this.orderDate = this.CaseOrderAndOrderLineItem[0].Order.CreatedDate;
                    this.orderchangedateDates = true;
                }

                if (this.CaseOrderAndOrderLineItem[0].Order.Paid_Amount__c != null) {
                    this.PaidAmountofOrder = this.CaseOrderAndOrderLineItem[0].Order.Paid_Amount__c;
                    this.PaidAmount = true;
                }

                if (this.CaseOrderAndOrderLineItem[0].OrderId != null) {
                  
            }
        }

                this.CaseOrderAndOrderLineItem.forEach(item => {
                    this.AllOrderItems.push({
                        productName: item.Product2.Name,
                        Id: item.Id,
                        Affected_Quantity__c: item.Affected_Quantity__c,
                        totalQuantity: item.Quantity,
                        Selling_Price__c: item.Selling_Price__c,
                        UnitPrice: item.UnitPrice,
                        totalprice: item.Total_Selling_Price__c,
                        skudetail: item.SKU__c,
                        brand : item.Brand__c,
                        disabled: true
                    });
                });

                this.error = undefined;

                //this.AllOrderItems = [];

                // getOrderItems({
                //     OrdId: this.ordersId
                // }).then(result => {
                //     result.forEach(item => {
                //         this.AllOrderItems.push({
                //             productName: item.Product2.Name,
                //             Id: item.Id,
                //             Affected_Quantity__c: item.Affected_Quantity__c,
                //             totalQuantity: item.Quantity,
                //             Selling_Price__c: item.Selling_Price__c,
                //             UnitPrice: item.UnitPrice,
                //             totalprice: item.Total_Selling_Price__c,
                //             skudetail: item.SKU__c,
                //             Brand : item.Brand__c,
                //             disabled: true
                //         });
                //     });

                //     this.error = undefined;


                // }).catch(error => {
                //     this.error = error;
                //     this.AllOrderItems = undefined;
                // });
                if (this.ordersId != null) {
                    this.orderHasItemAvailable = true;
                }

            } else {
                // Order not found logic
                this.show2ndPage = true;
                this.show1stPage = false;
                this.error = 'Order not found'; // You can set an error message here
            }
        }).catch(error => {
            this.error = error;
            this.Case = undefined;
        });


    }


    displayInfo = {
        primaryField: 'Name'
    };

    closeAction() {
        debugger;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    deselectRow(rowId) {
        const checkbox = this.template.querySelector(`[data-id="${rowId}"]`);
        if (checkbox) {
            checkbox.checked = false;
            this.handlesChange({ target: checkbox });
        }
    }

    handleEnter(event) {
        debugger;
        const keyPressed = event.key;

        // Concatenate the new key with the existing keys
        this.allKeys += keyPressed;

        if (this.allKeys) {
            this.filter = {
                criteria: [{
                    fieldPath: 'Name',
                    operator: 'eq',
                    value: this.allKeys,
                }],
            };
        }

    }

    hanldeProgressValueChange(event) {
        debugger;
        this.selectedRecordIdFromParent = event.detail;
        this.callAllOrderItems();
        // this.getRecordDetails();
    }

    handlesChange(event) {
        debugger;
        this.inpName = event.target.name;

        this.selectedSalesUserId = event.currentTarget.dataset.index;
        let selectedLineItemId = event.currentTarget.dataset.id; // Assuming this gives you the ID of the selected item

        if (event.target.type === 'checkbox') {
            if (event.target.checked) {
                this.selectedRows.push(selectedLineItemId); // Add to selectedRows if checked
                this.AllOrderItems[this.selectedSalesUserId].disabled = false;
                //this.selecteRowsMap.push({'Id':selectedLineItemId, 'Quantity': 0});
            } else {
                const index = this.selectedRows.indexOf(selectedLineItemId);
                if (index !== -1) {
                    this.selectedRows.splice(index, 1); // Remove from selectedRows if unchecked
                    this.AllOrderItems[this.selectedSalesUserId].disabled = true;
                }
            }
        }

        console.log('selectedRows==> ' + JSON.stringify(this.selectedRows));

        if (this.inpName == 'selectedOrder') {
            this.selectedOrd = event.detail.recordId;


        }

    }

    handelaffectedChange(event) {
        debugger;
        var index = event.currentTarget.dataset.index;
        if (this.AllOrderItems[index].totalQuantity < parseInt(event.target.value)) {
            alert('Affected Quantity Cannot be Greater than Order Quantity');
            return;
        } else {
            this.AllOrderItems[index].Affected_Quantity__c = parseInt(event.target.value);
        }
        // if(this.selecteRowsMap.has(this.AllOrderItems[index].Id)){
        //     this.selecteRowsMap.set(this.AllOrderItems[index].Id, this.AllOrderItems[index].Affected_Quantity__c);
        // }
    }

    handleClick() {
        debugger;
        var listToSend = [];
        for (var i in this.AllOrderItems) {
            if (!this.AllOrderItems[i].disabled) {
                listToSend.push({
                    Id: this.AllOrderItems[i].Id,
                    Affected_Quantity__c: this.AllOrderItems[i].Affected_Quantity__c
                });
            }
        }
        updateSKUdetailsAndCreateRecordOfSKU({
            recId: this.recordId,
            ordId: this.selectedRecordIdFromParent,
            ordLinItmList: this.selectedRows,
            oliList: listToSend
        })
            .then(result => {
                if (result) {
                    this.data = result;
                    const event = new ShowToastEvent({
                        title: 'Case Updated SuccessFully ',
                        variant: 'success',
                        message: 'The case has been created successfully.'
                    });
                    this.dispatchEvent(event);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(new RefreshEvent());
                }
            })
            .catch(error => {
                this.error = error;
                console.log('error == >' + error);
            });
    }
}