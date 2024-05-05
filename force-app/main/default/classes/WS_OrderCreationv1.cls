@RestResource(urlMapping='/OrderCreation')
global class WS_OrderCreationv1 {
    
    @HttpPost
    global static List<ResponseBody> doPost() {
        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;
        List<ResponseBody> respBodyList = new List<ResponseBody>();
        try {
            
            List<WS_OrderCreation> orderRecords = (List<WS_OrderCreation>) JSON.deserialize(req.requestBody.toString(), List<WS_OrderCreation>.class);
            Set<String> phone_numberSet = new Set<String>();

            Map<String,WS_OrderCreation.CustomerDetails> mapOfPhoneNumberByRecDetails = new Map<String,WS_OrderCreation.CustomerDetails>();//Phone number by customer details
            Map<String,WS_OrderCreation.Data> mapOfPhoneNumberByOrderDetails = new Map<String,WS_OrderCreation.Data>();
            Map<String,List<WS_OrderCreation.OrderDetails>> mapOrderDetailsByOrderId = new Map<String,List<WS_OrderCreation.OrderDetails>>();
            Map<String, Id> mapOfContractIdByAccPhone = new Map<String, Id>();
            Map<String, WS_OrderCreation.OrderDetails> subOrderDetailsBySubOrderId = new Map<String, WS_OrderCreation.OrderDetails>();
            Map<String, WS_OrderCreation.ItemDetails> oliDetailsBySubOrderId = new Map<String, WS_OrderCreation.ItemDetails>();
            Map<String, WS_OrderCreation.ItemDetails> subOrderItemBySubOrderItemName = new Map<String, WS_OrderCreation.ItemDetails>();
            Map<String, String> subOrderNameBysubOrderItemName = new Map<String,String>();
            Map<String, String> subOrderIdBySubOrderName = new Map<String,String>();
            Map<String, String> orderItemIdByOrderItemName = new Map<String,String>();
            Map<String, String> accIdByOrderName = new Map<String,String>();

            List<Account> accountListTobeUpsert = new List<Account>();


            ///////////////////Order APICode Start//////////////////
                If(!orderRecords.isEmpty()){
                    for(WS_OrderCreation ws_orderInput : orderRecords){

                        if(ws_orderInput.data.customer_details != null && ws_orderInput.data.customer_details.phone_number != null){
                            mapOfPhoneNumberByOrderDetails.put(ws_orderInput.data.customer_details.phone_number,ws_orderInput.data);
                            phone_numberSet.add(ws_orderInput.data.customer_details.phone_number);
                            mapOfPhoneNumberByRecDetails.put(ws_orderInput.data.customer_details.phone_number,ws_orderInput.data.customer_details);
                            mapOrderDetailsByOrderId.put(ws_orderInput.data.order_id, ws_orderInput.data.order_details);
                            for(WS_OrderCreation.OrderDetails orderRecords1: ws_orderInput.data.order_details){
                                for(WS_OrderCreation.ItemDetails itemRec : orderRecords1.item_details){
                                    subOrderNameBysubOrderItemName.put(ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id + '-' + itemRec.sku, ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id);
                                    subOrderItemBySubOrderItemName.put(ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id + '-' + itemRec.sku, itemRec);
                                }
                            }
                        }
                    }

                    for(String mapKey : mapOrderDetailsByOrderId.keySet()){
                        Map<String, WS_OrderCreation.OrderDetails> tempMap = new Map<String, WS_OrderCreation.OrderDetails>();
                        for(WS_OrderCreation.OrderDetails listrec : mapOrderDetailsByOrderId.get(mapKey)){
                            if(!tempMap.containsKey(listRec.sub_order_id)){
                                tempMap.put(listRec.sub_order_id, listRec);
                                subOrderDetailsBySubOrderId.put(mapKey + '-' + listRec.sub_order_id, listRec);
                            }
                        }
                    }

                    if(!phone_numberSet.isEmpty()){
                        List<Account> existingAccountList = new List<Account>();
                        Set<String> accountTobeCreate = new Set<String>();
                        Map<String,Id> mapOfPhoneNoByAccId = new Map<String,Id>();
                        existingAccountList = [SELECT Id,Email__c,Phone From Account WHERE Phone in: phone_numberSet];
                        Set<String> existingRecIdSet = new Set<String>();
                        If(!existingAccountList.isEmpty()){
                            for(Account acc : existingAccountList){
                                    existingRecIdSet.add(acc.Phone);
                                    mapOfPhoneNoByAccId.put(acc.Phone,acc.Id);
                            }
                        }
                            for(String mapKey : mapOfPhoneNumberByRecDetails.keySet()){
                                Account accRec = new Account();
                                accRec.Name = mapOfPhoneNumberByRecDetails.get(mapKey).name != null ? mapOfPhoneNumberByRecDetails.get(mapKey).name : 'Unknown';
                                accRec.Email__c = mapOfPhoneNumberByRecDetails.get(mapKey).email;
                                accRec.Phone = mapOfPhoneNumberByRecDetails.get(mapKey).phone_number;
                                if(existingRecIdSet.contains(mapKey)){
                                    accRec.Id = mapOfPhoneNoByAccId.get(mapKey);
                                }

                                accountListTobeUpsert.add(accRec);
                            }

                        Database.UpsertResult[] upsertResults = Database.upsert(accountListTobeUpsert,Account.Id, true);
                        Map<Id,WS_OrderCreation.Data> mapOfAccountIdByOrderList = new Map<Id,WS_OrderCreation.Data>();
                        for(Integer i = 0; i < upsertResults.size(); i++) {
                            Database.UpsertResult result = upsertResults[i];
                            Account upsertedAccount = accountListTobeUpsert[i];
                            
                            if(result.isSuccess()) {
                                mapOfAccountIdByOrderList.put(result.getId(),mapOfPhoneNumberByOrderDetails.get(upsertedAccount.Phone));

                            } else {
                                for(Database.Error error : result.getErrors()) {
                                    System.debug('Error message: ' + error.getMessage());
                                }
                            }
                        }

                        if(!mapOfAccountIdByOrderList.isEmpty()){
                            Set<String> orderIdSet = new Set<String>();
                            List<Order> OrderListTobeUpsert = new List<Order>(); 
                            for(Id mapKey : mapOfAccountIdByOrderList.keySet()){
                                orderIdSet.add(mapOfAccountIdByOrderList.get(mapKey).order_id);
                            }

                            if(!orderIdSet.isEmpty()){
                                List<Order> existingOrderList = new List<Order>();
                                Set<String> existingOrderIdSet = new Set<String>();
                                Map<String,Id> mapofOrderNameByOrderId = new Map<String,Id>();
                                existingOrderList = [SELECT Id,Name From Order WHERE Name in: orderIdSet];
                                if(!existingOrderList.isEmpty()){
                                    for(Order ord : existingOrderList){
                                        existingOrderIdSet.add(ord.Name);
                                        mapofOrderNameByOrderId.put(ord.Name,ord.id);
                                    }
                                }

                                for(Id mapKey : mapOfAccountIdByOrderList.keySet()){
                                    Order ord = new Order();
                                    ord.Name = mapOfAccountIdByOrderList.get(mapKey).order_id;
                                    ord.AccountId = mapKey;
                                    ord.EffectiveDate = mapOfAccountIdByOrderList.get(mapKey).order_date != null ? Date.ValueOf(mapOfAccountIdByOrderList.get(mapKey).order_date) : System.today();
                                    ord.Payment_Id__c = mapOfAccountIdByOrderList.get(mapKey).payment_id != null ? mapOfAccountIdByOrderList.get(mapKey).payment_id : '';
                                    ord.Payment_Status__c = mapOfAccountIdByOrderList.get(mapKey).payment_status != null ? mapOfAccountIdByOrderList.get(mapKey).payment_status : '';
                                    ord.Payment_Type__c = mapOfAccountIdByOrderList.get(mapKey).payment_type != null ? mapOfAccountIdByOrderList.get(mapKey).payment_type : '';
                                    ord.Paid_Amount__c = mapOfAccountIdByOrderList.get(mapKey).amount != null ? mapOfAccountIdByOrderList.get(mapKey).amount : 0;
                                    ord.Coupon_Code__c = mapOfAccountIdByOrderList.get(mapKey).coupon_code != null ? mapOfAccountIdByOrderList.get(mapKey).coupon_code : '';
                                    ord.Coupon_Discount__c = mapOfAccountIdByOrderList.get(mapKey).coupon_discount != null ? Decimal.valueOf(mapOfAccountIdByOrderList.get(mapKey).coupon_discount) : 0;
                                    ord.Coupon__c = mapOfAccountIdByOrderList.get(mapKey).is_coupon_redeemed != true ? 'No' : 'Yes';
                                    ord.Status = mapOfAccountIdByOrderList.get(mapKey).order_status != null ? mapOfAccountIdByOrderList.get(mapKey).order_status : '';
                                    ord.BillingStreet = mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.street != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.street : '';
                                    ord.BillingPostalCode = mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.pin_code != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.pin_code : '';
                                    ord.BillingState = mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.state != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.state : '';
                                    ord.BillingCity = mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.city != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.city : '';
                                    ord.BillingCountry = mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.country_code != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.country_code : '';
                                    ord.ShippingStreet = mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.street != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.street : '';
                                    ord.ShippingPostalCode = mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.pin_code != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.pin_code : '';
                                    ord.ShippingState = mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.state != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.state : '';
                                    ord.ShippingCity = mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.city != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.city : '';
                                    ord.ShippingCountry = mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.country_code != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.country_code : '';
                                    ord.Delivery_Mobile_Number__c = mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.phone_number != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.shipping_address.phone_number : '';
                                    ord.ContractId = null;
                                    if(existingOrderIdSet.contains(mapOfAccountIdByOrderList.get(mapKey).order_id)){
                                        ord.Id = mapofOrderNameByOrderId.get(mapOfAccountIdByOrderList.get(mapKey).order_id);
                                    }
                                    OrderListTobeUpsert.add(ord);
                                }

                                Database.UpsertResult[] orderUpsertResult = Database.upsert(OrderListTobeUpsert,Order.Id, false);
                         Map<Id, Map<String, WS_OrderCreation.OrderDetails>> subOrderDetBySubOrderNameByOrderId = new Map<Id, Map<String, WS_OrderCreation.OrderDetails>>();
                         Map<String, String> orderRecIdByOrderName = new Map<String,String>();
                         Set<Id> setOfOrderIds = new Set<Id>();
                            for(Integer i = 0; i < orderUpsertResult.size(); i++) {
                            Database.UpsertResult result = orderUpsertResult[i];
                            Order upsertedOrder = OrderListTobeUpsert[i];                                        
                            if(result.isSuccess()) {
                                // Access phone and email fields
                                orderRecIdByOrderName.put(upsertedOrder.Name, result.getId());
                                setOfOrderIds.add(result.getId());
                                accIdByOrderName.put(upsertedOrder.Name, upsertedOrder.AccountId);
                                ResponseBody res = new ResponseBody();
                                res.status = 'Success';
                                res.message = 'Orders Successfully Upserted';
                                res.orderId = upsertedOrder.Id;
                                respBodyList.add(res);
                            } else {
                                for(Database.Error error : result.getErrors()) {
                                    System.debug('Error message: ' + error.getMessage());
                                    ResponseBody res = new ResponseBody();
                                res.status = 'Error';
                                res.message = 'Orders Creation Failed: ' + error.getMessage();
                                res.orderId = upsertedOrder.Id;
                                respBodyList.add(res);
                                }
                            }
                            }

                            Map<Id, Map<String,Id>> subOrderIdBySubOrderNameByOrderId = new Map<Id, Map<String,Id>>();
                                Set<Id> orderIds = new Set<Id>();
                                List<Order> subOrderListToBeUpserted = new List<Order>();
                                List<Order> existingSubOrders = [SELECt Id, Sub_Order_Id__c,Name FROM Order WHERE ParentOrder__c IN: setOfOrderIds AND Name IN: subOrderDetailsBySubOrderId.keySet()];
                                Map<String, String> subOrderRecIdByName = new Map<String, String>();
                                if(!existingSubOrders.isEmpty()){
                                    for(Order ordRec : existingSubOrders){
                                        subOrderRecIdByName.put(ordRec.Name, ordRec.Id);
                                    }
                                }
                                if(!subOrderDetailsBySubOrderId.isEmpty()){
                                    for(String mapKey : subOrderDetailsBySubOrderId.keySet()){
                                        Order SubOrdRec = new Order();
                                        SubOrdRec.Name = mapKey;
                                        SubOrdRec.Seller_Name__c = subOrderDetailsBySubOrderId.get(mapKey).sub_order_seller_name != null ? subOrderDetailsBySubOrderId.get(mapKey).sub_order_seller_name : '';
                                        SubOrdRec.AWB_Number__c = subOrderDetailsBySubOrderId.get(mapKey).awb_number != null ? subOrderDetailsBySubOrderId.get(mapKey).awb_number : ''; 
                                        SubOrdRec.EffectiveDate = System.today();
                                        SubOrdRec.Courier__c = subOrderDetailsBySubOrderId.get(mapKey).courier != null ? subOrderDetailsBySubOrderId.get(mapKey).courier : '';
                                        SubOrdRec.Pricebook2Id = '01sIR000002f36lYAA';
                                        if(subOrderDetailsBySubOrderId.get(mapKey).expected_delivery_date != null){
                                            SubOrdRec.Expected_Delivery_Date__c = Date.ValueOf(subOrderDetailsBySubOrderId.get(mapKey).expected_delivery_date);
                                        }
                                        SubOrdRec.Status = subOrderDetailsBySubOrderId.get(mapKey).Sub_order_status != null ? subOrderDetailsBySubOrderId.get(mapKey).Sub_order_status : '';
                                        SubOrdRec.Tracking_Link__c = subOrderDetailsBySubOrderId.get(mapKey).tracking_link != null ? subOrderDetailsBySubOrderId.get(mapKey).tracking_link : '';
                                        // assign more fields
                                        if(mapKey.contains('-')){
                                            List<String> orderIdAndSubOrderId = mapKey.split('-');
                                            if(orderRecIdByOrderName.containsKey(orderIdAndSubOrderId[0])){
                                                SubOrdRec.ParentOrder__c = orderRecIdByOrderName.get(orderIdAndSubOrderId[0]);
                                                subOrdRec.AccountId = accIdByOrderName.get(orderIdAndSubOrderId[0]);
                                            }
                                        }
                                        if(subOrderRecIdByName.containsKey(mapKey)){
                                            SubOrdRec.Id = subOrderRecIdByName.get(mapKey);
                                        }
                                        subOrderListToBeUpserted.add(SubOrdRec);
                                    }

                        Database.UpsertResult[] subOrderUpsertResult = Database.upsert(subOrderListToBeUpserted,Order.Id, false);
                         Set<Id> setOfSubOrderIds = new Set<Id>();
                            for(Integer i = 0; i < subOrderUpsertResult.size(); i++) {
                            Database.UpsertResult result = subOrderUpsertResult[i];
                            Order upsertedSubOrder = subOrderListToBeUpserted[i];
                            
                            if(result.isSuccess()) {
                                setOfSubOrderIds.add(result.getId());
                                subOrderIdBySubOrderName.put(upsertedSubOrder.Name, result.getId());
                            } else {
                                for(Database.Error error : result.getErrors()) {
                                    System.debug('Error message: ' + error.getMessage());
                                    ResponseBody res = new ResponseBody();
                                res.status = 'Error';
                                res.message = 'Sub Order Creation Failed: ' + error.getMessage();
                                //res.orderId = upsertedOrder.Id;
                                respBodyList.add(res);
                                }
                            }
                        }

                                    
                        List<OrderItem> existingOrderItemList = [SELECT Id, Name__c, SKU__c FROM OrderItem WHERE OrderId IN: setOfSubOrderIds];
                        List<OrderItem> orderItemToUpsert = new List<OrderItem>();
                        if(!existingOrderItemList.isEmpty()){
                            for(OrderItem ordItemRec : existingOrderItemList){
                                orderItemIdByOrderItemName.put(ordItemRec.Name__c, ordItemRec.Id);
                            }
                        }
                        if(!subOrderItemBySubOrderItemName.isEmpty()){
                            for(String mapKey : subOrderItemBySubOrderItemName.keySet()){
                                OrderItem ordItemRec = new OrderItem();
                                ordItemRec.Name__c = mapKey;
                                ordItemRec.PricebookEntryId = '01uF3000005qUMkIAM';
                                ordItemRec.Product2Id = '01tF3000006czvcIAA';
                                ordItemRec.Brand__c = subOrderItemBySubOrderItemName.get(mapKey).brand != null ? subOrderItemBySubOrderItemName.get(mapKey).brand : '';
                                ordItemRec.UnitPrice = subOrderItemBySubOrderItemName.get(mapKey).mrp != null ? Decimal.valueOf(subOrderItemBySubOrderItemName.get(mapKey).mrp) : 0;
                                ordItemRec.Selling_Price__c = subOrderItemBySubOrderItemName.get(mapKey).selling_price != null ? subOrderItemBySubOrderItemName.get(mapKey).selling_price : 0;
                                ordItemRec.Quantity = subOrderItemBySubOrderItemName.get(mapKey).quantity != null ? subOrderItemBySubOrderItemName.get(mapKey).quantity : 0;
                                if(subOrderItemBySubOrderItemName.get(mapKey).refunded_price != '' && subOrderItemBySubOrderItemName.get(mapKey).refunded_price != null)
                                ordItemRec.Refunded_Price__c = Decimal.valueOf(subOrderItemBySubOrderItemName.get(mapKey).refunded_price);
                                ordItemRec.SKU__c = subOrderItemBySubOrderItemName.get(mapKey).sku != null ? subOrderItemBySubOrderItemName.get(mapKey).sku : '';
                                ordItemRec.Total_Selling_Price__c = ordItemRec.Selling_Price__c * ordItemRec.Quantity;
                                ordItemRec.Status__c = subOrderItemBySubOrderItemName.get(mapKey).status != null ? subOrderItemBySubOrderItemName.get(mapKey).status : '';
                                ordItemRec.Product_Name__c = subOrderItemBySubOrderItemName.get(mapKey).variant_name != null ? subOrderItemBySubOrderItemName.get(mapKey).variant_name : '';
                                if(subOrderNameBysubOrderItemName.containsKey(mapKey) && subOrderIdBySubOrderName.containsKey(subOrderNameBysubOrderItemName.get(mapKey))){
                                    ordItemRec.OrderId = subOrderIdBySubOrderName.get(subOrderNameBysubOrderItemName.get(mapKey));
                                }
                                if(orderItemIdByOrderItemName.containsKey(mapKey)){
                                    ordItemRec.Id = orderItemIdByOrderItemName.get(mapKey);
                                }
                                orderItemToUpsert.add(ordItemRec);
                            }
                            Database.UpsertResult[] subOrderItemUpsertResult = Database.upsert(orderItemToUpsert,OrderItem.Id, false);
                            for(Integer i = 0; i < subOrderItemUpsertResult.size(); i++) {
                            Database.UpsertResult result = subOrderItemUpsertResult[i];
                            OrderItem upsertedSubOrder = orderItemToUpsert[i];
                            
                            if(result.isSuccess()) {
                                System.debug('Order upserted successfully with ID: ' + result.getId());
                                // Access phone and email fields
                                System.debug('SubOrder Id: ' + upsertedSubOrder.Name__c);
                            } else {
                                for(Database.Error error : result.getErrors()) {
                                    System.debug('Error message: ' + error.getMessage());
                                    ResponseBody res = new ResponseBody();
                                res.status = 'Error';
                                res.message = 'Order Items Failed: ' + error.getMessage();
                                //res.orderId = upsertedOrder.Id;
                                respBodyList.add(res);
                                }
                            }
                        }
                                }
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
                            res.message = e.getMessage();
                            //res.orderId = upsertedOrder.Id;
                            respBodyList.add(res);
                return respBodyList;
            }
        }

            global class ResponseBody {
                public String status;
                public String message;
                public String orderId;
            }
        }

            //////////////////OrderAPICodeEnd///////////////////////