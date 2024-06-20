({
    convertArrayToCSV : function(component,metaDataRecord){
        debugger;
        var csvStringResult, counter, keys, columnDivider, lineDivider; 
        columnDivider = ',';
        lineDivider =  '\n';
        var tempName =  component.get("v.docTempName"); 
        if(tempName == 'OutOfStock'){
            keys = ['Order No','Reason','OOS Quantity','OOS SKU Code','Remarks'];
        }
        if(tempName == 'PinCodeService'){
             keys = ['Order No','Reason','Current PIN Code'];
        }
        if(tempName == 'DeliveryIssue'){
             keys = ['Order No','Reason','Current PIN Code','City Name'];
        }
         if(tempName == 'LostInTransit'){
             keys = ['Order No','Reason','Courier Partner'];
        }
         if(tempName == 'DeleayInDelivery'){
             keys = ['Order No','Reason','Courier Partner'];
        }
        if(tempName == 'RToOrders'){
             keys = ['Order No','Reason','Order Status'];
        }
        if(tempName == 'CSoutbound'){
            keys = ['Phone Number','Call Type'];
       }

        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider; 
        return csvStringResult;        
    },
    
})