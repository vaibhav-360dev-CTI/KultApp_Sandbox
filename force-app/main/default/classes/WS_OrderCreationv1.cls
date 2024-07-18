@RestResource(urlMapping='/OrderCreation')
global class WS_OrderCreationv1 {
    @HttpPost
    global static List<ResponseBody> doPost() {

        DateTime processingStartTime = System.now();
        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;
        Blob body = req.requestBody;
        String requestString = body.toString();
        String responseBody;
        Id integrationLogId;
        integrationLogId = HttpUtility.getInstance().createServiceLogger(null, requestString, null, '/OrderCreation', 'POST', null, processingStartTime, System.now(), null,'SERVICE');

        List<ResponseBody> respBodyList = new List<ResponseBody>();
        try {
            List<WS_OrderCreation> orderRecords = (List<WS_OrderCreation>) JSON.deserialize(req.requestBody.toString(), List<WS_OrderCreation>.class);
            Set<String> phone_numberSet = new Set<String>();
            Map<String,WS_OrderCreation.CustomerDetails> mapOfPhoneNumberByRecDetails = new Map<String,WS_OrderCreation.CustomerDetails>();//Phone number by customer details
            Map<String,List<WS_OrderCreation.Data>> mapOfPhoneNumberByOrderDetails = new Map<String,List<WS_OrderCreation.Data>>();
            Map<String,List<WS_OrderCreation.OrderDetails>> mapOrderDetailsByOrderId = new Map<String,List<WS_OrderCreation.OrderDetails>>();
            Map<String, Id> mapOfContractIdByAccPhone = new Map<String, Id>();
            Map<String, WS_OrderCreation.OrderDetails> subOrderDetailsBySubOrderId = new Map<String, WS_OrderCreation.OrderDetails>();
            Map<String, WS_OrderCreation.ItemDetails> subOrderItemBySubOrderItemName = new Map<String, WS_OrderCreation.ItemDetails>();
            Map<String, String> subOrderNameBysubOrderItemName = new Map<String,String>();
            Map<String, String> subOrderIdBySubOrderName = new Map<String,String>();
            Map<String, String> orderItemIdByOrderItemName = new Map<String,String>();
            Map<String, String> accIdByOrderName = new Map<String,String>();

            List<Account> accountListTobeUpsert = new List<Account>();
            Map<String,Integer> itemQuantityBySKU = new Map<String,Integer>();

            List<Product2> prodToTagList = [SELECT Id, Name FROM Product2 WHERE Name = 'Order Product' LIMIT 1];
            Product2 prodToTag = new Product2();
            if(!prodToTagList.isEmpty()){
                prodToTag = prodToTagList[0];
            }
            List<PriceBook2> priceBookToTagList = [SELECT Id, Name FROM PriceBook2 WHERE Name ='Standard Price Book' LIMIT 1];
            PriceBook2 priceBookToTag = new PriceBook2();
            if(!priceBookToTagList.isEmpty()){
                priceBookToTag = priceBookToTagList[0];
            }

            List<PricebookEntry> pbeToTagList = [SELECT Id, Name, PriceBook2Id FROM PriceBookEntry WHERE Product2Id =: prodToTag.Id AND PriceBook2Id =: priceBookToTag.Id LIMIT 1];
            PriceBookEntry pbeToTag = new PriceBookEntry();
            if(!pbeToTagList.isEmpty()){
                pbeToTag = pbeToTagList[0];
            }



            ///////////////////Order APICode Start//////////////////
                If(!orderRecords.isEmpty()){
                    for(WS_OrderCreation ws_orderInput : orderRecords){
                        if(ws_orderInput.data.customer_details != null && ws_orderInput.data.customer_details.uuid != null){
                            if(mapOfPhoneNumberByOrderDetails.containsKey(ws_orderInput.data.customer_details.uuid)){
                                mapOfPhoneNumberByOrderDetails.get(ws_orderInput.data.customer_details.uuid).add(ws_orderInput.data);
                            }else{
                                mapOfPhoneNumberByOrderDetails.put(ws_orderInput.data.customer_details.uuid, new List<WS_OrderCreation.Data>{ws_orderInput.data});
                            }
                            //mapOfPhoneNumberByOrderDetails.put(ws_orderInput.data.customer_details.phone_number,ws_orderInput.data);
                            phone_numberSet.add(ws_orderInput.data.customer_details.uuid);
                            mapOfPhoneNumberByRecDetails.put(ws_orderInput.data.customer_details.uuid,ws_orderInput.data.customer_details);
                            mapOrderDetailsByOrderId.put(ws_orderInput.data.order_id, ws_orderInput.data.order_details);
                            for(WS_OrderCreation.OrderDetails orderRecords1: ws_orderInput.data.order_details){
                                for(WS_OrderCreation.ItemDetails itemRec : orderRecords1.item_details){
                                    // subOrderNameBysubOrderItemName.put(ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id + '-' + itemRec.sku + '-' + i, ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id);
                                    // subOrderItemBySubOrderItemName.put(ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id + '-' + itemRec.sku + '-' + i, itemRec);
                                    String name = ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id + '-' + itemRec.sku;
                                    if(itemQuantityBySKU.containsKey(name)){
                                        itemQuantityBySKU.put(name, itemQuantityBySKU.get(name)+1); 
                                    }else{
                                        itemQuantityBySKU.put(name, 1); 
                                    }
                                }
                                for(WS_OrderCreation.ItemDetails itemRec : orderRecords1.item_details){
                                    String name = ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id + '-' + itemRec.sku;
                                    integer i = itemQuantityBySKU.get(name);
                                    subOrderNameBysubOrderItemName.put(ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id + '-' + itemRec.sku + '-' + i, ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id);
                                    subOrderItemBySubOrderItemName.put(ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id + '-' + itemRec.sku + '-' + i, itemRec);
                                    itemQuantityBySKU.put(name, itemQuantityBySKU.get(name)-1); 
                                }
                            }
                        }else if(ws_orderInput.data.customer_details != null && ws_orderInput.data.customer_details.uuid == null){
                            ResponseBody res = new ResponseBody();
                                res.status = 'Error';
                                res.message = 'Order Creation Failed: Customer Data found without UUID';
                                //res.orderId = upsertedOrder.Id;
                                respBodyList.add(res);
                                RestContext.response.statusCode = 400;
                                integrationLogId = HttpUtility.getInstance().createServiceLogger(integrationLogId,requestString, res.toString(), '/OrderCreation', 'POST', 400, processingStartTime, System.now(), null, 'SERVICE');
                                return respBodyList;
                        }

                    }
                    System.debug('mapOfPhoneNumberByRecDetails==> ' + mapOfPhoneNumberByRecDetails);
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
                        Map<String,String> mapOfAccNameByUUID = new Map<String,String>();
                        existingAccountList = [SELECT Id,Email__c,Phone, UUID__c, Name From Account WHERE UUID__c in: phone_numberSet AND Is_Deleted__c = false];
                        Set<String> existingRecIdSet = new Set<String>();
                        If(!existingAccountList.isEmpty()){
                            for(Account acc : existingAccountList){
                                    existingRecIdSet.add(acc.UUID__c);
                                    mapOfPhoneNoByAccId.put(acc.UUID__c,acc.Id);
                                    mapOfAccNameByUUID.put(acc.UUID__C, acc.Name);
                            }
                        }
                        System.debug('mapOfPhoneNoByAccId==> ' + mapOfPhoneNoByAccId);
                            for(String mapKey : mapOfPhoneNumberByRecDetails.keySet()){
                                Account accRec = new Account();
                                if(mapOfPhoneNumberByRecDetails.get(mapKey).name != null){
                                    accRec.Name = mapOfPhoneNumberByRecDetails.get(mapKey).name;
                                }else{
                                    accRec.Name = mapOfAccNameByUUID.get(mapKey) != null ? mapOfAccNameByUUID.get(mapKey) : 'New - ' + mapOfPhoneNumberByRecDetails.get(mapKey).phone_number;
                                }
                                if(mapOfPhoneNumberByRecDetails.get(mapKey).email != null){
                                    accRec.Email__c = mapOfPhoneNumberByRecDetails.get(mapKey).email;
                                }
                                if(mapOfPhoneNumberByRecDetails.get(mapKey).uuid != null){
                                    accRec.UUID__c = mapOfPhoneNumberByRecDetails.get(mapKey).uuid;
                                }
                                accRec.Phone = mapOfPhoneNumberByRecDetails.get(mapKey).phone_number;
                                if(existingRecIdSet.contains(mapKey)){
                                    accRec.Id = mapOfPhoneNoByAccId.get(mapKey);
                                    System.debug('mapOfPhoneNoByAccId.get(mapKey)==> ' + mapOfPhoneNoByAccId.get(mapKey));
                                }

                                accountListTobeUpsert.add(accRec);
                            }

                        Database.UpsertResult[] upsertResults = Database.upsert(accountListTobeUpsert,Account.Id, true);
                        Map<Id,List<WS_OrderCreation.Data>> mapOfAccountIdByOrderList = new Map<Id,List<WS_OrderCreation.Data>>();
                        for(Integer i = 0; i < upsertResults.size(); i++) {
                            Database.UpsertResult result = upsertResults[i];
                            Account upsertedAccount = accountListTobeUpsert[i];
                            if(result.isSuccess()) {
                                    for(WS_OrderCreation.Data dataRec : mapOfPhoneNumberByOrderDetails.get(upsertedAccount.UUID__c)){
                                        if(mapOfAccountIdByOrderList.containsKey(result.getId())){
                                            mapOfAccountIdByOrderList.get(result.getId()).add(dataRec);
                                        }else{
                                            mapOfAccountIdByOrderList.put(result.getId(), new List<WS_OrderCreation.Data>{dataRec});
                                        }
                                    }
                               // mapOfAccountIdByOrderList.put(result.getId(),mapOfPhoneNumberByOrderDetails.get(upsertedAccount.Phone));

                            } else {
                                for(Database.Error error : result.getErrors()) {
                                    ResponseBody res = new ResponseBody();
                                res.status = 'Error';
                                res.message = 'Order Creation Failed: ' + error.getMessage();
                                //res.orderId = upsertedOrder.Id;
                                respBodyList.add(res);

                                integrationLogId = HttpUtility.getInstance().createServiceLogger(integrationLogId,requestString, res.toString(), '/OrderCreation', 'POST', 400, processingStartTime, System.now(), null, 'SERVICE');

                                }
                                RestContext.response.statusCode = 400;
                                return respBodyList;
                            }
                        }

                        if(!mapOfAccountIdByOrderList.isEmpty()){
                            Set<String> orderIdSet = new Set<String>();
                            List<Order> OrderListTobeUpsert = new List<Order>(); 
                            for(Id mapKey : mapOfAccountIdByOrderList.keySet()){
                                for(WS_OrderCreation.Data dtaRec : mapOfAccountIdByOrderList.get(mapKey)){
                                    orderIdSet.add(dtaRec.order_id);
                                }
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
                                    for(WS_OrderCreation.Data ordRecords : mapOfAccountIdByOrderList.get(mapKey)){
                                        Order ord = new Order();
                                    ord.Name = ordRecords.order_id;
                                    ord.AccountId = mapKey;
                                    ord.EffectiveDate = ordRecords.order_date != null ? Date.ValueOf(ordRecords.order_date) : System.today();
                                    ord.Payment_Id__c = ordRecords.payment_id != null ? ordRecords.payment_id : '';
                                    ord.Payment_Status__c = ordRecords.payment_status != null ? ordRecords.payment_status : '';
                                    ord.Payment_Type__c = ordRecords.payment_type != null ? ordRecords.payment_type : '';
                                    ord.Paid_Amount__c = ordRecords.amount != null ? ordRecords.amount : 0;
                                    ord.Coupon_Code__c = ordRecords.coupon_code != null ? ordRecords.coupon_code : '';
                                    ord.Coupon_Discount__c = ordRecords.coupon_discount != null ? Decimal.valueOf(ordRecords.coupon_discount) : 0;
                                    ord.Coupon__c = ordRecords.is_coupon_redeemed != true ? 'No' : 'Yes';
                                    ord.Status = ordRecords.order_status != null ? ordRecords.order_status : 'Success';
                                    ord.BillingStreet = ordRecords.address_details.billing_address.street != null ? ordRecords.address_details.billing_address.street.left(255) : '';
                                    ord.BillingPostalCode = ordRecords.address_details.billing_address.pin_code != null ? ordRecords.address_details.billing_address.pin_code : '';
                                    ord.BillingState = ordRecords.address_details.billing_address.state != null ? ordRecords.address_details.billing_address.state : '';
                                    ord.BillingCity = ordRecords.address_details.billing_address.city != null ? ordRecords.address_details.billing_address.city : '';
                                    ord.BillingCountry = ordRecords.address_details.billing_address.country_code != null ? ordRecords.address_details.billing_address.country_code : '';
                                    ord.Billing_Name__c = ordRecords.address_details.billing_address.name != null ? ordRecords.address_details.billing_address.name : '';
                                    ord.ShippingStreet = ordRecords.address_details.shipping_address.street != null ? ordRecords.address_details.shipping_address.street.left(255) : '';
                                    ord.ShippingPostalCode = ordRecords.address_details.shipping_address.pin_code != null ? ordRecords.address_details.shipping_address.pin_code : '';
                                    ord.ShippingState = ordRecords.address_details.shipping_address.state != null ? ordRecords.address_details.shipping_address.state : '';
                                    ord.ShippingCity = ordRecords.address_details.shipping_address.city != null ? ordRecords.address_details.shipping_address.city : '';
                                    ord.ShippingCountry = ordRecords.address_details.shipping_address.country_code != null ? ordRecords.address_details.shipping_address.country_code : '';
                                    ord.Shipping_Name__c = ordRecords.address_details.shipping_address.name != null ? ordRecords.address_details.shipping_address.name : '';
                                    ord.Delivery_Mobile_Number__c = ordRecords.address_details.shipping_address.phone_number != null ? ordRecords.address_details.shipping_address.phone_number : '';
                                    ord.ContractId = null;
                                    if(existingOrderIdSet.contains(ordRecords.order_id)){
                                        ord.Id = mapofOrderNameByOrderId.get(ordRecords.order_id);
                                    }
                                    OrderListTobeUpsert.add(ord);
                                    }
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

                                integrationLogId = HttpUtility.getInstance().createServiceLogger(integrationLogId,requestString, res.toString(), '/OrderCreation', 'POST', 200, processingStartTime, System.now(), null, 'SERVICE');

                            } else {
                                for(Database.Error error : result.getErrors()) {
                                    System.debug('Error message: ' + error.getMessage());
                                    ResponseBody res = new ResponseBody();
                                res.status = 'Error';
                                res.message = 'Orders Creation Failed: ' + error.getMessage();
                                res.orderId = upsertedOrder.Id;
                                respBodyList.add(res);

                                integrationLogId = HttpUtility.getInstance().createServiceLogger(integrationLogId,requestString, res.toString(), '/OrderCreation', 'POST', 400, processingStartTime, System.now(), null, 'SERVICE');
                                }
                                RestContext.response.statusCode = 400;

                                return respBodyList;
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
                                        SubOrdRec.Sub_Order_Id__c = subOrderDetailsBySubOrderId.get(mapKey).sub_order_id != null ? subOrderDetailsBySubOrderId.get(mapKey).sub_order_id : '';
                                        SubOrdRec.Pricebook2Id = priceBookToTag.Id;
                                        SubOrdRec.Is_Sub_Order__c = true;
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

                                integrationLogId = HttpUtility.getInstance().createServiceLogger(integrationLogId,requestString, res.toString(), '/OrderCreation', 'POST', 400, processingStartTime, System.now(), null, 'SERVICE');

                                }
                                RestContext.response.statusCode = 400;
                                return respBodyList;
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
                                System.debug('mapKey=> ' + mapKey);
                                OrderItem ordItemRec = new OrderItem();
                                ordItemRec.Name__c = mapKey;
                                ordItemRec.PricebookEntryId = pbeToTag.Id;
                                ordItemRec.Product2Id = prodToTag.Id;
                                ordItemRec.Brand__c = subOrderItemBySubOrderItemName.get(mapKey).brand != null ? subOrderItemBySubOrderItemName.get(mapKey).brand : '';
                                ordItemRec.UnitPrice = subOrderItemBySubOrderItemName.get(mapKey).mrp != null ? Decimal.valueOf(subOrderItemBySubOrderItemName.get(mapKey).mrp) : 0;
                                ordItemRec.Selling_Price__c = subOrderItemBySubOrderItemName.get(mapKey).selling_price != null ? subOrderItemBySubOrderItemName.get(mapKey).selling_price : 0;
                                //ordItemRec.Quantity = subOrderItemBySubOrderItemName.get(mapKey).quantity != null ? subOrderItemBySubOrderItemName.get(mapKey).quantity : 0;
                                //ordItemRec.Quantity = itemQuantityBySKU.get(mapKey) != null ? itemQuantityBySKU.get(mapKey) : 1;
                                ordItemRec.Quantity = 1;
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

                                integrationLogId = HttpUtility.getInstance().createServiceLogger(integrationLogId,requestString, res.toString(), '/OrderCreation', 'POST', 400, processingStartTime, System.now(), null, 'SERVICE');

                                }
                                RestContext.response.statusCode = 400;
                                return respBodyList;
                            }
                        }
                                }
                            }

                    }
                }
            }
        return respBodyList;
                }
                ResponseBody res = new ResponseBody();
                res.status = 'Error';
                res.message = 'Unknown error occurred.';
                //res.orderId = upsertedOrder.Id;
                respBodyList.add(res);

                integrationLogId = HttpUtility.getInstance().createServiceLogger(integrationLogId,requestString, res.toString(), '/OrderCreation', 'POST', 400, processingStartTime, System.now(), null, 'SERVICE');
                
                return respBodyList;

            }catch(exception e){
                System.debug('Error Message==>' + e.getMessage() + ' at Line Number==> ' + e.getLineNumber());
                ResponseBody res = new ResponseBody();
                            res.status = 'Error';
                            res.message = e.getMessage() + ' at Line ' + e.getLineNumber();
                            //res.orderId = upsertedOrder.Id;
                            respBodyList.add(res);
                            RestContext.response.statusCode = 400;

                            integrationLogId = HttpUtility.getInstance().createServiceLogger(integrationLogId,requestString, res.toString(), '/OrderCreation', 'POST', 400, processingStartTime, System.now(), null, 'SERVICE');

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