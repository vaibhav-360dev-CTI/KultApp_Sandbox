@RestResource(urlMapping='/OrderUpdation')
global class WS_OrderUpdateV1 {
    @Httppost
    global static List<ResponseBody> updateOrders(){
        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;
        List<ResponseBody> respBodyList = new List<ResponseBody>();
        try{
            List<WS_OrderUpdate> orderRecords = (List<WS_OrderUpdate>) JSON.deserialize(req.requestBody.toString(), List<WS_OrderUpdate>.class);
            Set<String> order_idSet = new Set<String>();
            Map<String, WS_OrderUpdate> orderDetailsByOrderId = new Map<String, WS_OrderUpdate>();
            Map<String,Order> orderRecByName = new Map<String,Order>();
            Map<String,WS_OrderUpdate.Order_details> subOrderDetailsBySubOrderId = new Map<String,WS_OrderUpdate.Order_details>();
            Map<String, String> orderRecIdByOrderName = new Map<String,String>();
            Set<Id> setOfOrderIds = new Set<Id>();
            Map<String, String> accIdByOrderName = new Map<String,String>();
            Map<String, String> subOrderIdBySubOrderName = new Map<String,String>();
            Map<String, OrderItem> orderItemIdByOrderItemName = new Map<String,OrderItem>();
            Map<String, WS_OrderUpdate.Item_details> subOrderItemBySubOrderItemName = new Map<String, WS_OrderUpdate.Item_details>();
            Map<String, String> subOrderNameBysubOrderItemName = new Map<String,String>();
            
            List<Order> ordersToUpsert = new List<Order>();
            List<Order> subOrderListToBeUpserted = new List<Order>();
            
            if(!orderRecords.isEmpty()){
                for(WS_OrderUpdate ordRec : orderRecords){
                    if(ordRec.order_id != null){
                        orderDetailsByOrderId.put(ordRec.order_id, ordRec);
                        order_idSet.add(ordRec.order_id);
                        for(WS_OrderUpdate.Order_details subOrderRec : ordRec.order_details){
                            subOrderDetailsBySubOrderId.put(ordRec.order_id + '-' + subOrderRec.sub_order_id, subOrderRec);
                            for(WS_OrderUpdate.Item_details itemRec : subOrderRec.item_details){
                                subOrderItemBySubOrderItemName.put(ordRec.order_id + '-' + subOrderRec.sub_order_id + '-' + itemRec.sku, itemRec);
                                subOrderNameBysubOrderItemName.put(ordRec.order_id + '-' + subOrderRec.sub_order_id + '-' + itemRec.sku, ordRec.order_id + '-' + subOrderRec.sub_order_id);
                            }
                        }
                    }
                }
                
                if(!order_idSet.isEmpty()){
                    List<Order> existingOrderList = [SELECT Id, Name, AccountId FROM ORDER WHERE Name IN: order_idSet];
                    if(!existingOrderList.isEmpty()){
                        for(Order ordRec : existingOrderList){
                            orderRecByName.put(ordRec.Name, ordRec);
                        }
                    }
                }
                
                for(String mapKey : orderDetailsByOrderId.keySet()){
                    Order ordRec = new Order();
                    ordRec.Coupon__c = orderDetailsByOrderId.get(mapKey).is_coupon_redeemed != true ? 'No' : 'Yes';
                    ordRec.Name = orderDetailsByOrderId.get(mapKey).order_id != null ? orderDetailsByOrderId.get(mapKey).order_id : 'Unknown';
                    if(orderRecByName.containsKey(mapKey)){
                        ordRec.Id = orderRecByName.get(mapKey).Id;
                        ordRec.AccountId = orderRecByName.get(mapKey).AccountId;
                    }
                    ordersToUpsert.add(ordRec);
                }
                Database.UpsertResult[] upsertResults = Database.upsert(ordersToUpsert,Order.Id, true);
                for(Integer i = 0; i < upsertResults.size(); i++) {
                    Database.UpsertResult result = upsertResults[i];
                    Order upsertedOrder = ordersToUpsert[i];
                    
                    if(result.isSuccess()) {
						orderRecIdByOrderName.put(upsertedOrder.Name, result.getId());
						setOfOrderIds.add(result.getId()); 
                        accIdByOrderName.put(upsertedOrder.Name, upsertedOrder.AccountId);
                    } else {
                        for(Database.Error error : result.getErrors()) {
                            System.debug('Error message: ' + error.getMessage());
                        }
                    }
                }
                List<Order> existingSubOrders = [SELECt Id, Sub_Order_Id__c,Name, AccountId FROM Order WHERE ParentOrder__c IN: setOfOrderIds AND Name IN: subOrderDetailsBySubOrderId.keySet()];
                System.debug('existingSubOrders: ' + existingSubOrders);
                Map<String, Order> subOrderRecByName = new Map<String, Order>();
                if(!existingSubOrders.isEmpty()){
                    for(Order ordRec : existingSubOrders){
                        subOrderRecByName.put(ordRec.Name, ordRec);
                    }
                }
                if(!subOrderDetailsBySubOrderId.isEmpty()){
                    for(String mapKey : subOrderDetailsBySubOrderId.keySet()){
                        Order SubOrdRec = new Order();
                        SubOrdRec.Name = mapKey;
                        SubOrdRec.AWB_Number__c = subOrderDetailsBySubOrderId.get(mapKey).awb_number != null ? subOrderDetailsBySubOrderId.get(mapKey).awb_number : ''; 
                        SubOrdRec.EffectiveDate = System.today();
                        SubOrdRec.Courier__c = subOrderDetailsBySubOrderId.get(mapKey).courier != null ? subOrderDetailsBySubOrderId.get(mapKey).courier : '';
                        SubOrdRec.Pricebook2Id = '01sIR000002f36lYAA';
                        if(subOrderDetailsBySubOrderId.get(mapKey).expected_delivery_date != null){
                            SubOrdRec.Expected_Delivery_Date__c = Date.ValueOf(subOrderDetailsBySubOrderId.get(mapKey).expected_delivery_date);
                        }
                        SubOrdRec.Status = subOrderDetailsBySubOrderId.get(mapKey).sub_order_status != null ? subOrderDetailsBySubOrderId.get(mapKey).sub_order_status : '';
                        SubOrdRec.Tracking_Link__c = subOrderDetailsBySubOrderId.get(mapKey).tracking_link != null ? subOrderDetailsBySubOrderId.get(mapKey).tracking_link : '';
                        // assign more fields
                        if(mapKey.contains('-')){
                            List<String> orderIdAndSubOrderId = mapKey.split('-');
                            if(orderRecIdByOrderName.containsKey(orderIdAndSubOrderId[0])){
                                SubOrdRec.ParentOrder__c = orderRecIdByOrderName.get(orderIdAndSubOrderId[0]);
                                subOrdRec.AccountId = accIdByOrderName.get(orderIdAndSubOrderId[0]);
                            }
                        }
                        if(subOrderRecByName.containsKey(mapKey)){
                            SubOrdRec.Id = subOrderRecByName.get(mapKey).Id;
                        }
                        subOrderListToBeUpserted.add(SubOrdRec);
                    }
                    System.debug('subOrderListToBeUpserted: ' + subOrderListToBeUpserted);
                    
                    Database.UpsertResult[] subOrderUpsertResult = Database.upsert(subOrderListToBeUpserted,Order.Id, false);
                    Set<Id> setOfSubOrderIds = new Set<Id>();
                    for(Integer i = 0; i < subOrderUpsertResult.size(); i++) {
                        Database.UpsertResult result = subOrderUpsertResult[i];
                        Order upsertedSubOrder = subOrderListToBeUpserted[i];
                        
                        if(result.isSuccess()) {
                            setOfSubOrderIds.add(result.getId());
                            subOrderIdBySubOrderName.put(upsertedSubOrder.Name, result.getId());
                            List<String> subOrderAndOrderIds = new List<String>();
                                subOrderAndOrderIds = upsertedSubOrder.Name.split('-');
                                String orderId = subOrderAndOrderIds[0];
                                String subOrderId = subOrderAndOrderIds[1];
								ResponseBody res = new ResponseBody();
                            res.status = 'Success';
                            res.message = 'Orders Successfully Updated';
                            res.order_id = orderId;
                               res.sub_order_id = subOrderId;
                            res.new_status = upsertedSubOrder.Status;
                            respBodyList.add(res);
                        } else {
                            for(Database.Error error : result.getErrors()) {
                                System.debug('Error message: ' + error.getMessage());
                                ResponseBody res = new ResponseBody();
                                res.status = 'Error';
                            res.message = 'Error Updating Order: ' + error.getMessage();
                            res.order_id = null;
                               res.sub_order_id = null;
                            res.new_status = upsertedSubOrder.Status;
                            respBodyList.add(res);
                            }
                            RestContext.response.statusCode = 400;
                            return respBodyList;
                        }
                        System.debug('setOfSubOrderIds==>' + setOfSubOrderIds);
                    }
                    
                    
                    List<OrderItem> existingOrderItemList = [SELECT Id, Name__c, SKU__c, OrderId FROM OrderItem WHERE OrderId IN: setOfSubOrderIds];
                    System.debug('existingOrderItemList==>' + existingOrderItemList);
                    List<OrderItem> orderItemToUpsert = new List<OrderItem>();
                    if(!existingOrderItemList.isEmpty()){
                        for(OrderItem ordItemRec : existingOrderItemList){
                            orderItemIdByOrderItemName.put(ordItemRec.Name__c, ordItemRec);
                        }
                    }
                    System.debug('orderItemIdByOrderItemName==>' + orderItemIdByOrderItemName);
                    if(!subOrderItemBySubOrderItemName.isEmpty()){
                        for(String mapKey : subOrderItemBySubOrderItemName.keySet()){
                            OrderItem ordItemRec = new OrderItem();
                            if(orderItemIdByOrderItemName.containsKey(mapKey)){
                                ordItemRec = orderItemIdByOrderItemName.get(mapKey);
                            }
                            System.debug('Order Item Record==> ' + ordItemRec);
                            ordItemRec.Name__c = mapKey;
                            ordItemRec.SKU__c = subOrderItemBySubOrderItemName.get(mapKey).sku != null ? subOrderItemBySubOrderItemName.get(mapKey).sku : '';
                            ordItemRec.Status__c = subOrderItemBySubOrderItemName.get(mapKey).status != null ? subOrderItemBySubOrderItemName.get(mapKey).status : '';
                            orderItemToUpsert.add(ordItemRec);
                        }
                        Database.UpsertResult[] subOrderItemUpsertResult = Database.upsert(orderItemToUpsert,OrderItem.Id, false);
                        for(Integer i = 0; i < subOrderItemUpsertResult.size(); i++) {
                            Database.UpsertResult result = subOrderItemUpsertResult[i];
                            OrderItem upsertedSubOrderItem = orderItemToUpsert[i];
                            
                            if(result.isSuccess()) {
                                
                            } else {
                                for(Database.Error error : result.getErrors()) {
                                    System.debug('Error message: ' + error.getMessage());
                                    ResponseBody res = new ResponseBody();
                            res.status = 'Error';
                            res.message = 'Failed to update status. ' + error.getMessage();
                            respBodyList.add(res);
                                }
                                RestContext.response.statusCode = 400;
                                return respBodyList;
                            }
                        }
                    }
                }
                return respBodyList;
            }
            return respBodyList;
        }catch(exception e){
            ResponseBody res = new ResponseBody();
            res.status = 'Error';
            res.message = e.getMessage() + ' at Line number ' + e.getLineNumber();
            //res.orderId = upsertedOrder.Id;
            respBodyList.add(res);
            RestContext.response.statusCode = 400;
            return respBodyList;
        }
    }
    
    global class ResponseBody {
        public String status;
        public String message;
        public String order_id;
        public String sub_order_id;
        public String new_status;
    }
}