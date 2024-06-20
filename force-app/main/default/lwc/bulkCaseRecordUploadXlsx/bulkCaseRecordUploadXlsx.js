/**
 * @author [Dinesh Baddawar]
 * @email dinesh.b@utilitarianLab.com
 * @create date 2024-05-09 19:53:56
 * @modify date 2024-05-09 19:54:25
 * @desc [LWC Component Upload Excel File and Creating Record]
 */

import { LightningElement, api } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import excelFileReader from "@salesforce/resourceUrl/ExcelReaderPlugin";
let XLS = {};
import insertBulkCaseXlsxFiel from '@salesforce/apex/BulkCaseUploadController.insertBulkCaseXlsxFiel';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BulkCaseUploadURL from '@salesforce/label/c.BulkCaseUploadURL';

export default class BulkCaseRecordUploadXlsx extends LightningElement {
     error;
     data;
     jsonData = [];
     showTable = false;
     showUploadFile = true;
     @api docTempName;
     @api refundType;
     @api showDownload;
     BulkCaseUploadURL = BulkCaseUploadURL;
     strAcceptedFormats = [".xls", ".xlsx"];
     strUploadFileName;
     objExcelToJSON;
     convertedDate;
     stringifyconvertedDate;
     pindcodeShowError = false;
     showCaseRefund = false;

     connectedCallback() {
          debugger;
          this.docTempName = this.docTempName;
          Promise.all([loadScript(this, excelFileReader)])
               .then(() => {
                    XLS = XLSX;
               })
               .catch((error) => {
                    console.log("An error occurred while processing the file");
               });
     }

     @api
     handleFileUpload(event) {
          debugger;
          console.log(event);
          this.handleUploadFinished(event);
     }
     handleUploadFinished(event) {
          debugger;
          const strUploadedFile = event.detail.files;
          if (strUploadedFile.length && strUploadedFile != "") {
               this.strUploadFileName = strUploadedFile[0].name;
               var extension = this.strUploadFileName.split('.').pop();
               this.handleProcessExcelFile(strUploadedFile[0]);
          }
     }

     handleProcessExcelFile(file) {
          debugger;
          let objFileReader = new FileReader();
          objFileReader.onload = (event) => {
               let objFiledata = event.target.result;
               let objFileWorkbook = XLS.read(objFiledata, {
                    type: "binary"
               });
               this.objExcelToJSON = XLS.utils.sheet_to_row_object_array(objFileWorkbook.Sheets["Sheet1"]);
               if (this.objExcelToJSON.length === 0) {
                    var SheetFileName = objFileWorkbook.SheetNames;
                    this.objExcelToJSON = XLS.utils.sheet_to_row_object_array(objFileWorkbook.Sheets[SheetFileName]);
               }
               if (this.objExcelToJSON.length > 0) {
                    Object.keys(this.objExcelToJSON).forEach((key) => {
                         const replacedKey = key.trim().toUpperCase().replace(/ss+/g, "_");
                         if (key !== replacedKey) {
                              this.objExcelToJSON[replacedKey] = this.objExcelToJSON[key];
                              delete this.objExcelToJSON[key];
                         }
                    });
                    debugger;
                    console.log('objExcelToJSON' + this.objExcelToJSON);
                    let data = JSON.parse(JSON.stringify(this.objExcelToJSON));
                    let objList = [];
                    let index = 0;
                    var orderNumbers = [];
                    for (var i = 0; i < data.length; i++) {
                         index += 1;

                         // this.convertedDate = new Date((data[i]["Date Of Order"] - 25569) * 86400 * 1000);
                         // this.stringifyconvertedDate = JSON.stringify(this.convertedDate);

                         // const year = this.stringifyconvertedDate.slice(1, 5);
                         // const month = this.stringifyconvertedDate.slice(6, 8);
                         // const day = this.stringifyconvertedDate.slice(9, 11);

                         // // Create the desired format
                         // const formattedDate = `${day}-${month}-${year}`;

                         if(!orderNumbers.includes(data[i]["Order No"]) && !orderNumbers.includes(data[i]["Order Id"])){
                              var obj = {
                                   "orderno": data[i]["Order No"],
                                   // "dateoforder": formattedDate,
                                   "shippingmobileno": data[i]["Shipping Mobile No"],
                                   "reason": data[i]["Reason"],
                                   "item": data[i]["Item"],
                                   "oosquantity": data[i]["OOS Quantity"],
                                   "oosskucode": data[i]["OOS SKU Code"],
                                   "remarks": data[i]["Remarks"],
                                   "currentpincode": data[i]["Current PIN Code"],
                                   "cityname": data[i]["City Name"],
                                   "awbnumber": data[i]["AWB Number"],
                                   "courierpartner": data[i]["Courier Partner"], // 
                                   "orderstatus": data[i]["Order Status"],
                                   "couponcode": data[i]["Coupon Code"],
                                   "easyecomorderstatus": data[i]["Easyecom Order Status"],
                                   "email": data[i]["Email"],
                                   "isfullrefund": data[i]["Is Full Refund"],
                                   "name": data[i]["Name"],
                                   "orderid": data[i]["Order Id"],
                                   "phoneno": data[i]["Phone No"],
                                   "razorpaypaymentid": data[i]["Razorpay Payment ID"],
                                   "refundamount": data[i]["Refund Amount"],
                                   "sku1cancelledquantity": data[i]["SKU 1 Cancelled Quantity"],
                                   "sku1id": data[i]["SKU 1 ID"],
                                   "sku1orderquantity": data[i]["SKU 1 Order Quantity"],
                                   "sku2cancelledquantity": data[i]["SKU 2 Cancelled Quantity"],
                                   "sku2id": data[i]["SKU 2 ID"],
                                   "sku2orderquantity": data[i]["SKU 2 Order Quantity"],
                                   "sno": index,
                                   "callType": data[i]["Call Type"],
                                   "subject": data[i]["Subject"],
                                   "phoneNumber": data[i]["Phone Number"]
                              };
                              objList.push(obj);
                              if(data[i]["Order No"] != undefined){
                                   orderNumbers.push(data[i]["Order No"]);
                              }else if(data[i]["Order Id"] != undefined){
                                   orderNumbers.push(data[i]["Order Id"]);
                              }
                         }
                    }
                    console.log('data == ' + objList);
                    this.jsonData = objList;
                    this.showTable = true;
                    this.showUploadFile = false;
                    // this.callInsertAccountRecords();
               }
          };

          objFileReader.onerror = function (error) {
               this.dispatchEvent(
                    new ShowToastEvent({
                         title: "Error while reading the file",
                         message: error.message,
                         variant: "error"
                    })
               );
          };
          objFileReader.readAsBinaryString(file);
     }

     closeAction() {
          debugger;
          window.location.href = this.BulkCaseUploadURL;
     }

     HandleImportRecord() {
          debugger;
          var pincodelistSize = [];
          var mobilelistsize = [];
          for (var i = 0; i < this.jsonData.length; i++) {
               if (this.jsonData[i].currentpincode != undefined) {
                    if (this.jsonData[i].currentpincode.toString().length > 6 || this.jsonData[i].currentpincode.toString().length < 6) {
                         pincodelistSize.push(this.jsonData[i]);
                    }
               }
               
               if (this.jsonData[i].shippingmobileno != undefined) {
                    if (this.jsonData[i].shippingmobileno.toString().length > 10 || this.jsonData[i].shippingmobileno.toString().length < 10) {
                         mobilelistsize.push(this.jsonData[i]);
                    }
               }
          }
          if (pincodelistSize.length == 0 && mobilelistsize.length == 0) {
               insertBulkCaseXlsxFiel({ jsonString: JSON.stringify(this.jsonData), docTempName: this.docTempName , refundType:this.refundType, showDownload:this.showDownload})
                    .then(result => {
                         if (result) {
                              this.showToast();
                         } else {
                              alert('Error');
                         }
                    })
                    .catch(error => {
                         this.error = error;
                    })
          }else{
               this.showPinCodeErrorToast();
          }
     }

     showToast() {
          const event = new ShowToastEvent({
               title: 'SUCCESS',
               message: 'Record Created Successfully !',
               variant: 'success',
               mode: 'dismissable'
          });
          this.dispatchEvent(event);
          setTimeout(() => {
               window.location.href = this.BulkCaseUploadURL;
          }, 2000);
     }

     showPinCodeErrorToast() {
          const event = new ShowToastEvent({
               title: 'Check Pincode / Mobile',
               message: 'Please check Pincode length or Mobile Length !',
               variant: 'warning',
               mode: 'dismissable'
          });
          this.dispatchEvent(event);
          return;
     }

}