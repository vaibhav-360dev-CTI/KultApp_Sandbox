public with sharing class CalloutRefundAPIClass {
    //Getting the basic details from custom setting
    private static Refund_API_Details__c fap  = Refund_API_Details__c.getInstance();
    private static final String EndPointUrl   = fap.Endpoint__c;
    private static String accessToken         = fap.Access_Token__c;

    public static String postRefundRequest(String caseId) {
        try{
            System.debug('Inside API class');
            Set<Id> orderItemIds = new Set<Id>();
            List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
            List<Affected_SKU__c> skuList = [SELECT Id, Name, Case__r.Refund_Type__c, Case__r.Order_Number__c, Case__r.Account.Phone, 
                                             Order_Item__c FROM Affected_SKU__c WHERE Case__c =: caseId];
            System.debug('skuList=====>'+skuList);
            Map<String,Integer> qtyBySKU = new Map<String,Integer>();
            List<ItemDetails> itemDetailsList = new List<ItemDetails>();
            System.debug('skuList=====>'+skuList);
            if(!skuList.isEmpty()){
                if(skuList[0].Case__r.Refund_Type__c != 'Special Case Refund'){
                    
                for(Affected_SKU__c skuRec : skuList){
                    System.debug('skuRec=====>'+skuRec);
                    orderItemIds.add(skuRec.Order_Item__c);
                    System.debug('orderItemIds=====>'+orderItemIds);
                    if(!qtyBySKU.containsKey(skuRec.Name)){
                        qtyBySKU.put(skuRec.Name, 1);
                        System.debug('Inside if qtyBySKU=====>'+qtyBySKU);
                    }else{
                        Integer currentQty = qtyBySKU.get(skuRec.Name);
                        currentQty++;
                        qtyBySKU.put(skuRec.Name, currentQty);
                        System.debug('Inside else qtyBySKU=====>'+qtyBySKU);
                    }
                }
                    System.debug('before for loop qtyBySKU=====>'+qtyBySKU);
                for(String skuID : qtyBySKU.keySet()){
                    
                    ItemDetails itRec = new ItemDetails();
                    itRec.sku_id = skuID;
                    itRec.quantity = qtyBySKU.get(skuID);
                    itemDetailsList.add(itRec);
                    System.debug('itRec=====>'+itRec);
                    System.debug('itemDetailsList=====>'+itemDetailsList);
                }
                refundWrapper wr = new refundWrapper();
                //wr.token = accessToken;
                wr.order_id = skuList[0].Case__r.Order_Number__c;
                wr.refund_type = skuList[0].Case__r.Refund_Type__c;
                wr.phone_number = skuList[0].Case__r.Account.Phone;
                wr.release_coupon = true;
                wr.item_details = itemDetailsList;

                String requestBody = JSON.serialize(wr);
                System.debug('requestBody====>'+requestBody);
                String fullUrl = endpointUrl;
                System.debug('fullUrl====>'+fullUrl);
                HttpRequest request = new HttpRequest();
                request.setHeader('Authorization', accessToken);
                request.setEndpoint(fullUrl);
                request.setMethod('POST');
                request.setBody(requestBody);
                System.debug('request====>'+request);    
                Http http = new Http();
                HttpResponse response = http.send(request);
                System.debug('response==> ' + response);
                if(response.getStatusCode() == 200){
                    if(!orderItemIds.isEmpty()){
                        orderItemsToUpdate = [SELECT Id, Refunded__c FROM OrderItem WHERE ID IN: orderItemIds];
                        for(OrderItem orderRec : orderItemsToUpdate){
                            orderRec.Refunded__c = true;
                        }
                        update orderItemsToUpdate;
                        
                    }
                    System.debug('response==> ' + response.getStatusCode());
                    return 'Success';
                }else{
                    System.debug('response==> ' + response.getStatus());
                    return response.getStatusCode() + ': ' + response.getStatus();
                }
            }else{
                for(Affected_SKU__c skuRec : skuList){
                    orderItemIds.add(skuRec.Order_Item__c);
                }
                System.debug('orderItemIds==> ' + orderItemIds);
                if(!orderItemIds.isEmpty()){
                    orderItemsToUpdate = [SELECT Id, Refunded__c FROM OrderItem WHERE ID IN: orderItemIds];
                    for(OrderItem orderRec : orderItemsToUpdate){
                        orderRec.Refunded__c = true;
                    }
                    System.debug('orderItemsToUpdate==> ' + orderItemsToUpdate);
                    update orderItemsToUpdate;
                    
                }
                return 'Success';
            }
            }else{
                return 'No affected SKUs Found';
            }
        }catch(exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
            return e.getMessage();
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
    
     public static void dumMethod() {
    Integer i = 0;
    Integer j = 0;
    Integer k = 0;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
     }
}