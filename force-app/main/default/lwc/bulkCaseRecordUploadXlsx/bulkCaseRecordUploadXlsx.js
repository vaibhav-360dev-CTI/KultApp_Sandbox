import { LightningElement,api } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import excelFileReader from "@salesforce/resourceUrl/ExcelReaderPlugin";
let XLS = {};
import insertBulkCaseXlsxFiel from '@salesforce/apex/BulkCaseUploadController.insertBulkCaseXlsxFiel';
export default class BulkCaseRecordUploadXlsx extends LightningElement {
     error;
     data;
     jsonData = [];
     showTable= false;
     showUploadFile = true;
     @api docTempName;
   
    strAcceptedFormats = [".xls", ".xlsx"];
    strUploadFileName; 
     objExcelToJSON; 
     
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
              this.objExcelToJSON = XLS.utils.sheet_to_row_object_array(
                  objFileWorkbook.Sheets["Sheet1"]
              );
              if (this.objExcelToJSON.length === 0) {
                  this.strUploadFileName = "";
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: "Error",
                          message: "Kindly upload the file with data",
                          variant: "error"
                      })
                  );
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
                  console.log('objExcelToJSON'+this.objExcelToJSON);
                   let data = JSON.parse(JSON.stringify(this.objExcelToJSON));
                   let objList = [];
                   let index= 0;
                   for(var i=0;i<data.length;i++){
                       index +=1;
                          var obj = {
                         "orderno" : data[i]["Order No"],
                         "dateoforder" :data[i]["Date Of Order"],
                         "shippingmobileno" : data[i]["Shipping Mobile No"],
                         "reason": data[i]["Reason"],
                         "item": data[i]["Item"],
                         "oosquantity": data[i]["OOS Quantity"],
                         "oosskucode": data[i]["OOS SKU Code"],
                         "remarks" : data[i]["Remarks"],
                         "sno" : index
                        };
                       objList.push(obj);
                    }
                   console.log('data == '+objList);   
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
          window.location.href = 'https://kultapp--kultapp.sandbox.lightning.force.com/lightning/n/Bulk_Case_Upload';
     }

     HandleImportRecord() {
          debugger;
          insertBulkCaseXlsxFiel({ jsonString: JSON.stringify(this.objExcelToJSON) })
               .then(result => {
                    if (result) {
                    
               }
               })
               .catch(error => {
                    this.error = error;
          })
     }
     
}