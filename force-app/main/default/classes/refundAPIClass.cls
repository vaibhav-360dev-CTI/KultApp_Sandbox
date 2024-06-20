public with sharing class refundAPIClass {
    //Getting the basic details from custom setting
    private static Refund_API_Details__c fap  = Refund_API_Details__c.getInstance();
    private static final String EndPointUrl   = fap.Endpoint__c;
    private static String accessToken         = fap.Access_Token__c;

    public static void postRefundRequest(String caseId) {
        try{
            List<Affected_SKU__c> skuList = [SELECT Id, Name, Case__r.Refund_Type__c, Case__r.Order_Number__c, Case__r.Account.Phone FROM Affected_SKU__c WHERE Case__c =: caseId];
            Map<String,Integer> qtyBySKU = new Map<String,Integer>();
            List<ItemDetails> itemDetailsList = new List<ItemDetails>();
            if(!skuList.isEmpty()){
                if(skuList[0].Case__r.Refund_Type__c != 'Special Case Refund'){
                for(Affected_SKU__c skuRec : skuList){
                    if(!qtyBySKU.containsKey(skuRec.Name)){
                        qtyBySKU.put(skuRec.Name, 1);
                    }else{
                        Integer currentQty = qtyBySKU.get(skuRec.Name);
                        currentQty++;
                        qtyBySKU.put(skuRec.Name, currentQty);
                    }
                }
                for(String skuID : qtyBySKU.keySet()){
                    ItemDetails itRec = new ItemDetails();
                    itRec.sku_id = skuID;
                    itRec.quantity = qtyBySKU.get(skuID);
                    itemDetailsList.add(itRec);
                }
                refundWrapper wr = new refundWrapper();
                //wr.token = accessToken;
                wr.order_id = skuList[0].Case__r.Order_Number__c;
                wr.refund_type = skuList[0].Case__r.Refund_Type__c;
                wr.phone_number = skuList[0].Case__r.Account.Phone;
                wr.release_coupon = true;
                wr.item_details = itemDetailsList;

                String requestBody = JSON.serialize(wr);
                String fullUrl = endpointUrl;
                HttpRequest request = new HttpRequest();
                request.setHeader('Authorization', accessToken);
                request.setEndpoint(fullUrl);
                request.setMethod('POST');
                request.setBody(requestBody);
                Http http = new Http();
                HttpResponse response = http.send(request);
                system.debug('response==>'+response);
            }
            }
        }catch(exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
        }
    }

    private class refundWrapper{
       // private String token;
        private String order_id;
        private String refund_type;
        private String phone_number;
        private boolean release_coupon;
        private List<ItemDetails> item_details; 
    }

    private class ItemDetails{
        private string sku_id;
        private integer quantity;
    }
}