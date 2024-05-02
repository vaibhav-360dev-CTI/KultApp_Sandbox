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
            Map<String, Map<String, WS_OrderCreation.OrderDetails>> subOrderBySubOrderNameBYOrderName = new Map<String, Map<String,WS_OrderCreation.OrderDetails>>();
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
                            System.debug('ws_orderInput.data==> ' + ws_orderInput.data);
                            phone_numberSet.add(ws_orderInput.data.customer_details.phone_number);
                            mapOfPhoneNumberByRecDetails.put(ws_orderInput.data.customer_details.phone_number,ws_orderInput.data.customer_details);
                            mapOrderDetailsByOrderId.put(ws_orderInput.data.order_id, ws_orderInput.data.order_details);
                            for(WS_OrderCreation.OrderDetails orderRecords1: ws_orderInput.data.order_details){
                                for(WS_OrderCreation.ItemDetails itemRec : orderRecords1.item_details){
                                    subOrderNameBysubOrderItemName.put(ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id + '-' + itemRec.sku, ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id);
                                    subOrderItemBySubOrderItemName.put(ws_orderInput.data.order_id + '-' + orderRecords1.sub_order_id + '-' + itemRec.sku, itemRec);
                                    System.debug('ws_orderInput.data.order_id==> ' + ws_orderInput.data.order_id);
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
                        if(!subOrderBySubOrderNameBYOrderName.containsKey(mapKey)){
                            subOrderBySubOrderNameBYOrderName.put(mapKey, tempMap);
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
                                accRec.Name = mapOfPhoneNumberByRecDetails.get(mapKey).name;
                                accRec.Email__c = mapOfPhoneNumberByRecDetails.get(mapKey).email;
                                accRec.Phone = mapOfPhoneNumberByRecDetails.get(mapKey).phone_number;
                                if(existingRecIdSet.contains(mapKey)){
                                    accRec.Id = mapOfPhoneNoByAccId.get(mapKey);
                                }

                                accountListTobeUpsert.add(accRec);
                            }
                        System.debug('accountListTobeUpsert==> ' + accountListTobeUpsert);

                        Database.UpsertResult[] upsertResults = Database.upsert(accountListTobeUpsert,Account.Id, true);
                        Map<Id,WS_OrderCreation.Data> mapOfAccountIdByOrderList = new Map<Id,WS_OrderCreation.Data>();
                        for(Integer i = 0; i < upsertResults.size(); i++) {
                            Database.UpsertResult result = upsertResults[i];
                            Account upsertedAccount = accountListTobeUpsert[i];
                            
                            if(result.isSuccess()) {
                                System.debug('Account upserted successfully with ID: ' + result.getId());
                                // Access phone and email fields
                                System.debug('Phone: ' + upsertedAccount.Phone);
                                System.debug('Email: ' + upsertedAccount.Email__c);

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
                                System.debug('orderIdSet==> ' + orderIdSet);
                            }

                            if(!orderIdSet.isEmpty()){
                                List<Order> existingOrderList = new List<Order>();
                                Set<String> existingOrderIdSet = new Set<String>();
                                Map<String,Id> mapofOrderNameByOrderId = new Map<String,Id>();
                                existingOrderList = [SELECT Id,Name From Order WHERE Name in: orderIdSet];
                                System.debug('existingOrderList==> ' + existingOrderList);
                                if(!existingOrderList.isEmpty()){
                                    for(Order ord : existingOrderList){
                                        existingOrderIdSet.add(ord.Name);
                                        mapofOrderNameByOrderId.put(ord.Name,ord.id);
                                    }
                                    System.debug('existingOrderIdSet==> ' + existingOrderIdSet);
                                }

                                for(Id mapKey : mapOfAccountIdByOrderList.keySet()){
                                    Order ord = new Order();
                                    ord.Name = mapOfAccountIdByOrderList.get(mapKey).order_id;
                                    System.debug('mapOfAccountIdByOrderList.get(mapKey).order_id==> ' + mapOfAccountIdByOrderList.get(mapKey).order_id);
                                    ord.AccountId = mapKey;
                                    ord.EffectiveDate = mapOfAccountIdByOrderList.get(mapKey).order_date != null ? Date.ValueOf(mapOfAccountIdByOrderList.get(mapKey).order_date) : System.today();
                                    ord.Payment_Id__c = mapOfAccountIdByOrderList.get(mapKey).payment_id != null ? mapOfAccountIdByOrderList.get(mapKey).payment_id : '';
                                    ord.Payment_Status__c = mapOfAccountIdByOrderList.get(mapKey).payment_status != null ? mapOfAccountIdByOrderList.get(mapKey).payment_status : '';
                                    ord.Payment_Type__c = mapOfAccountIdByOrderList.get(mapKey).payment_type != null ? mapOfAccountIdByOrderList.get(mapKey).payment_type : '';
                                    ord.Paid_Amount__c = mapOfAccountIdByOrderList.get(mapKey).amount != null ? mapOfAccountIdByOrderList.get(mapKey).amount : 0;
                                    ord.Coupon_Code__c = mapOfAccountIdByOrderList.get(mapKey).coupon_code != null ? mapOfAccountIdByOrderList.get(mapKey).coupon_code : '';
                                    ord.Coupon_Discount__c = mapOfAccountIdByOrderList.get(mapKey).coupon_discount != null ? Decimal.valueOf(mapOfAccountIdByOrderList.get(mapKey).coupon_discount) : 0;
                                    ord.Coupon__c = mapOfAccountIdByOrderList.get(mapKey).is_coupon_redeemed;
                                    ord.Status = mapOfAccountIdByOrderList.get(mapKey).order_status;
                                    ord.BillingStreet = mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.street != null ? mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address.street : '';
                                    System.debug('mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address==> ' + mapOfAccountIdByOrderList.get(mapKey).address_details.billing_address);
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
                         Map<Id,List<WS_OrderCreation.OrderDetails>> mapOfOrderListByOrderId = new Map<Id,List<WS_OrderCreation.OrderDetails>>();
                         Map<String,List<WS_OrderCreation.OrderDetails>> mapOfOrderListByOrderName = new Map<String,List<WS_OrderCreation.OrderDetails>>();
                         Map<Id, Map<String, WS_OrderCreation.OrderDetails>> subOrderDetBySubOrderNameByOrderId = new Map<Id, Map<String, WS_OrderCreation.OrderDetails>>();
                         Map<String, String> orderRecIdByOrderName = new Map<String,String>();
                         Set<Id> setOfOrderIds = new Set<Id>();
                            for(Integer i = 0; i < orderUpsertResult.size(); i++) {
                            Database.UpsertResult result = orderUpsertResult[i];
                            Order upsertedOrder = OrderListTobeUpsert[i];
                            ResponseBody res = new ResponseBody();
                            res.status = 'Success';
                            res.message = 'Orders Successfully Upserted';
                            res.orderId = upsertedOrder.Id;
                            respBodyList.add(res);
                                        
                            if(result.isSuccess()) {
                                System.debug('Order upserted successfully with ID: ' + result.getId());
                                // Access phone and email fields
                                System.debug('Order Id: ' + upsertedOrder.Name);
                                mapOfOrderListByOrderId.put(result.getId(),mapOrderDetailsByOrderId.get(upsertedOrder.Name));
                                mapOfOrderListByOrderName.put(upsertedOrder.Name,mapOrderDetailsByOrderId.get(upsertedOrder.Name));
                                orderRecIdByOrderName.put(upsertedOrder.Name, result.getId());
                                setOfOrderIds.add(result.getId());
                                accIdByOrderName.put(upsertedOrder.Name, upsertedOrder.AccountId);
                            } else {
                                for(Database.Error error : result.getErrors()) {
                                    System.debug('Error message: ' + error.getMessage());
                                }
                            }
                            }

                            Map<Id, Map<String,Id>> subOrderIdBySubOrderNameByOrderId = new Map<Id, Map<String,Id>>();
                                Set<Id> orderIds = new Set<Id>();
                                List<Order> subOrderListToBeUpserted = new List<Order>();
                                List<Order> existingSubOrders = [SELECt Id, Sub_Order_Id__c,Name FROM Order WHERE ParentOrder__c IN: setOfOrderIds AND Name IN: subOrderDetailsBySubOrderId.keySet()];
                                Map<String, String> subOrderRecIdByName = new Map<String, String>();
                                Set<Id> existingSubOrderIds = new Set<Id>();
                                Map<String, Map<String, Id>> subOrderIdByNameByOrderName = new Map<String, Map<String,Id>>();
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
                                System.debug('Order upserted successfully with ID: ' + result.getId());
                                // Access phone and email fields
                                System.debug('SubOrder Id: ' + upsertedSubOrder.Name);
                                setOfSubOrderIds.add(result.getId());
                                subOrderIdBySubOrderName.put(upsertedSubOrder.Name, result.getId());
                            } else {
                                for(Database.Error error : result.getErrors()) {
                                    System.debug('Error message: ' + error.getMessage());
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
                return null;
            }
        }

            global class ResponseBody {
                public String status;
                public String message;
                public String orderId;
            }
        }

            //////////////////OrderAPICodeEnd///////////////////////
            
//             List<Account> accountsToUpdate = new List<Account>();
//             List<Account> accountsToInsert = new List<Account>();
//             List<Order> ordersToInsert = new List<Order>();
//             List<List<OrderItem>> orderItemsToInsert = new List<List<OrderItem>>();
            
//             Map<String, Account> existingAccountsByEmail = new Map<String, Account>();
//             Map<String, Account> existingAccountsByPhone = new Map<String, Account>();
//             Map<String, Account> existingAccountsByMobileNumber = new Map<String, Account>();
//             Set<String> existingOrderIds = new Set<String>();
//             Set<String> existingSubOrderIds = new Set<String>();

//             Map<Id, Order> ordersById = new Map<Id, Order>([SELECT Id, Name FROM Order WHERE Name IN :getOrderIds(orderRecords)]);
//             Map<String, Order> ordersByName = new Map<String, Order>();
            
//             for(Order existingOrder : [SELECT Id, Name FROM Order WHERE Name IN :getOrderIds(orderRecords)]) {
//                 existingOrderIds.add(existingOrder.Name);
//             }

//             // Map<Id, Order> subOrdersById = new Map<Id, Order>([SELECT Id, Name, Sub_Order_Id__c FROM Order WHERE ParentOrder__r.Name IN: existingOrderIds]);
//             // Map<String, Order> subOrdersBySuborderId = new Map<String, Order>();
//             // for(Id subOrderId : subOrderIds.keySet()){
//             //     if(!subOrdersBySuborderId.containsKey(subOrdersById.get(subOrderId).Sub_Order_Id__c)){

//             //     }
//             // }

//             for(Id orderId : ordersById.keySet()){
//                 if(!ordersByName.containsKey(ordersById.get(orderId).Name)){
//                     ordersByName.put(ordersById.get(orderId).Name, ordersById.get(orderId));
//                 }
//             }
            
//             if(!orderRecords.isEmpty()) {
//                 for(WS_OrderCreation orderData : orderRecords) {
//                     if(existingOrderIds.contains(orderData.data.order_id)) {
//                         Order order = updateOrder(orderData.data, ordersByName.get(orderData.data.order_id).Id);
//                             // if(!(orderData.data.order_details).isEmpty()){

//                             //     List<Order> subOrders = updateSubOrders(orderData.data.order_details, order.Id, account.Id, newContract.Id, order.EffectiveDate);
//                             // }
//                         // res.status = 'Aborted';
//                         // res.message = 'Order Already Exists';
//                         // res.orderId = null;
//                         // respBodyList.add(res);
//                         res.status = 'Success';
//                             res.message = 'Order Successfully Updated';
//                             res.orderId = order.Id;
//                             respBodyList.add(res);
//                         return respBodyList;
//                     }
//                     if(String.isNotBlank(orderData.data.customer_details.email)) {
//                         existingAccountsByEmail.put(orderData.data.customer_details.email.toLowerCase(), null);
//                     }
//                     if(String.isNotBlank(orderData.data.customer_details.phone_number)) {
//                         existingAccountsByPhone.put(orderData.data.customer_details.phone_number, null);
//                     }
//                     // if(String.isNotBlank(orderData.data.customer_details.mobile_number)) {
//                     //     existingAccountsByMobileNumber.put(orderData.data.customer_details.mobile_number, null);
//                     // }
//                 }
                
//                 List<Account> accList = [SELECT Id, Email__c, Phone, Mobile_Phone__c, BillingStreet, ShippingStreet FROM Account WHERE Email__c IN :existingAccountsByEmail.keySet() OR Phone IN :existingAccountsByPhone.keySet() OR Mobile_Phone__c IN :existingAccountsByPhone.keySet()];
//                 for(Account existingAccount : accList) {
//                     if(String.isNotBlank(existingAccount.Email__c)) {
//                         existingAccountsByEmail.put(existingAccount.Email__c.toLowerCase(), existingAccount);
//                     }
//                     if(String.isNotBlank(existingAccount.Phone)) {
//                         existingAccountsByPhone.put(existingAccount.Phone, existingAccount);
//                     }
//                     if(String.isNotBlank(existingAccount.Mobile_Phone__c)) {
//                         existingAccountsByPhone.put(existingAccount.Mobile_Phone__c, existingAccount);
//                     }
//                 }
                
//                 for(WS_OrderCreation orderData : orderRecords) {
//                     Account account;
//                     if(String.isNotBlank(orderData.data.customer_details.email)) {
//                         account = existingAccountsByEmail.get(orderData.data.customer_details.email.toLowerCase());
//                     }
//                     if(account == null && String.isNotBlank(orderData.data.customer_details.phone_number)) {
//                         account = existingAccountsByPhone.get(orderData.data.customer_details.phone_number);
//                     }
//                     // if(account == null && String.isNotBlank(orderData.data.customer_details.mobile_number)) {
//                     //     account = existingAccountsByMobileNumber.get(orderData.data.customer_details.mobile_number);
//                     // }
                    
//                     if(account != null) {
//                         updateAccount(account, orderData.data.customer_details, orderData.data); 
//                     } else {
//                         account = createAccount(orderData.data.customer_details, orderData.data);
//                         if(account != null) {
//                             if(account.Id != null) {
//                                 accountsToUpdate.add(account);
//                             } else {
//                                 accountsToInsert.add(account);
//                             }
//                         }
//                     }
                    
//                     if(account != null) {
//                         List<Contract> existingContract = [SELECT Id FROM Contract WHERE AccountId = :account.Id LIMIT 1];
//                         if(existingContract.Size()==0) {
//                             Contract newContract = createContract(orderData.data, account);
//                             if(newContract != null) {
//                                 // Handle any further logic if needed
//                             }
                            
//                             Order order = createOrder(orderData.data, account.Id, newContract.Id);
//                             if(!(orderData.data.order_details).isEmpty()){

//                                 List<Order> subOrders = createSubOrders(orderData.data.order_details, order.Id, account.Id, newContract.Id, order.EffectiveDate);
//                             }
//                             System.debug('order==>' + order);
//                             res.status = 'Success';
//                             res.message = 'Order Successfully Created';
//                             res.orderId = order.Id;
//                             respBodyList.add(res);
//                             if(order != null) {
//                                 ordersToInsert.add(order);
//                                 // Create order items and associate with the order
//                                 // if(orderData.data.order_details != null && !orderData.data.order_details.isEmpty()) {
//                                 //     for(WS_OrderCreation.OrderDetails orderDetails : orderData.data.order_details) {
//                                 //         List<OrderItem> orderItems = createOrderItem(orderDetails, order.Id);
//                                 //         if(!orderItems.isEmpty()) {
//                                 //             orderItemsToInsert.add(orderItems);
//                                 //         }
//                                 //     }
//                                 // }
//                             }
//                         }else{
//                             Order order = createOrder(orderData.data, account.Id, existingContract[0].Id);
//                             if(!(orderData.data.order_details).isEmpty()){
//                                 System.debug('Test');
//                                 List<Order> subOrders = createSubOrders(orderData.data.order_details, order.Id, account.Id, existingContract[0].Id, order.EffectiveDate);
//                             }
//                             System.debug('order==>' + order);
//                             res.status = 'Success';
//                             res.message = 'Order Successfully Created';
//                             res.orderId = order.Id;
//                             respBodyList.add(res);
//                             if(order != null) {
//                                 ordersToInsert.add(order);
//                                 // Create order items and associate with the order
//                                 // if(orderData.data.order_details != null && !orderData.data.order_details.isEmpty()) {
//                                 //     for(WS_OrderCreation.OrderDetails orderDetails : orderData.data.order_details) {
//                                 //         List<OrderItem> orderItems = createOrderItem(orderDetails, order.Id);
//                                 //         if(!orderItems.isEmpty()) {
//                                 //             orderItemsToInsert.add(orderItems);
//                                 //         }
//                                 //     }
//                                 // }
//                             }
//                         } 
//                     }
                    
//                     // Bulk update existing accounts
//                     if(!accountsToUpdate.isEmpty()) {
//                         update accountsToUpdate;
//                     }
//                     // Bulk insert new accounts
//                     if(!accountsToInsert.isEmpty()) {
//                         insert accountsToInsert;
//                     }
//                     // Bulk insert orders
//                     if(!ordersToInsert.isEmpty()) {
//                         //insert ordersToInsert;
//                     }
//                     // Bulk insert order items
//                     /*if(!orderItemsToInsert.isEmpty()) {
// insert orderItemsToInsert;
// }*/
//                 }
//             }
//             return respBodyList;
//         }
//         } catch(Exception e) {
//             system.debug('Error Message==>'+e.getMessage() + ' at line==> ' + e.getLineNumber());
//             return null;
//         }
        
//     }
    
//     public static Account updateAccount(Account account, WS_OrderCreation.CustomerDetails customerDetails, WS_OrderCreation.Data orderData) {
//         // Update account fields
//         account.Name = customerDetails.name;
//         account.Phone = customerDetails.phone_number;
//         //account.Mobile_Phone__c = customerDetails.mobile_number;
//         account.Email__c = customerDetails.email;
//         if(account.BillingStreet == null){
//             //account.BillingStreet = orderData.address_details.shipping_address.house_number + ' ' + orderData.address_details.shipping_address.street; 
//             account.BillingStreet = orderData.address_details.billing_address.complete_address != null ? orderData.address_details.billing_address.complete_address : ''; 
//             account.BillingPostalCode = orderData.address_details.billing_address.pin_code != null ? orderData.address_details.billing_address.pin_code : '';
//         }
//         if(account.ShippingStreet == null){
//             //account.ShippingStreet = orderData.address_details.delivery_address.house_number;
//             account.ShippingStreet = orderData.address_details.shipping_address.complete_address != null ? orderData.address_details.shipping_address.complete_address : '';
//             //account.ShippingState = orderData.address_details.delivery_address.state;
//             account.ShippingPostalCode = orderData.address_details.shipping_address.pin_code != null ? orderData.address_details.shipping_address.pin_code : '';   
//         }
//         //account.Delivery_Mobile_Number__c = orderData.address_details.delivery_address.mobile_number;
        
//         Account_Address__c deliveryAddress = findOrCreateDeliveryAddress(orderData.address_details, account );
//         Account_Address__c shippingAddress = findOrCreateShippingAddress(orderData.address_details, account );
//         update account;
//         System.debug('updated Account==. ' + account);
//         return account;
//     }
    
//     public static Account createAccount(WS_OrderCreation.CustomerDetails customerDetails, WS_OrderCreation.Data orderData) {
//         // Create new account
//         Account newAccount = new Account();
//         newAccount.Name = customerDetails.name != null ? customerDetails.name : 'Unknown Name';
//         newAccount.Phone = customerDetails.phone_number != null ? customerDetails.phone_number : '';
//         //newAccount.Mobile_Phone__c = customerDetails.mobile_number;
//         newAccount.Email__c = customerDetails.email != null ? customerDetails.email : '';
//         //newAccount.BillingStreet = orderData.address_details.shipping_address.house_number + ' ' + orderData.address_details.shipping_address.street;
//         newAccount.BillingStreet = orderData.address_details.billing_address.complete_address != null ? orderData.address_details.billing_address.complete_address : '';
//         newAccount.BillingPostalCode = orderData.address_details.billing_address.pin_code != null ? orderData.address_details.billing_address.pin_code : '';
//         newAccount.ShippingStreet = orderData.address_details.shipping_address.house_number != null ? orderData.address_details.shipping_address.house_number : '';
//         //newAccount.ShippingState = orderData.address_details.shipping_address.state;
//         newAccount.ShippingPostalCode = orderData.address_details.shipping_address.pin_code != null ? orderData.address_details.shipping_address.pin_code : '';
//         //newAccount.Delivery_Mobile_Number__c = orderData.address_details.shipping_address.mobile_number;
//         insert newAccount;
//         System.debug('created Account==. ' + newAccount);
//         Account_Address__c deliveryAddress = findOrCreateDeliveryAddress(orderData.address_details, newAccount );
//         Account_Address__c shippingAddress = findOrCreateShippingAddress(orderData.address_details, newAccount );
//         return newAccount;
//     }
    
//     public static Order createOrder(WS_OrderCreation.Data orderData, Id accountId, Id ContractId) {
//         // Create new order
//         Order newOrder = new Order();
//         newOrder.Name = orderData.order_id != null ? orderData.order_id : '';
//         newOrder.Pricebook2Id = '01sIR000002f36lYAA';
//         newOrder.AccountId = accountId;
//         newOrder.EffectiveDate = orderData.order_date != null ? Date.ValueOf(orderData.order_date) : System.today();
//         newOrder.Payment_Id__c = orderData.payment_id != null ? orderData.payment_id : '';
//         newOrder.Payment_Status__c = orderData.payment_status != null ? orderData.payment_status : '';
//         newOrder.Payment_Type__c = orderData.payment_type != null ? orderData.payment_type : '';
//         newOrder.Amount_from_OMS__c = orderData.amount != null ? orderData.amount : 0;
//         newOrder.Coupon_Code__c = orderData.coupon_code != null ? orderData.coupon_code : '';
//         newOrder.Coupon_Discount__c = orderData.coupon_discount != null ? Decimal.valueOf(orderData.coupon_discount) : 0;
//         newOrder.Coupon__c = orderData.is_coupon_redeemed;
//         newOrder.ContractId = ContractId;
//         newOrder.Status = orderData.order_status;
//         //newOrder.BillingStreet = orderData.address_details.shipping_address.house_number + ' ' + orderData.address_details.shipping_address.street;
//         newOrder.BillingStreet = orderData.address_details.billing_address.complete_address != null ? orderData.address_details.billing_address.complete_address : '';
//         newOrder.BillingPostalCode = orderData.address_details.billing_address.pin_code != null ? orderData.address_details.billing_address.pin_code : '';
//         newOrder.ShippingStreet = orderData.address_details.shipping_address.complete_address != null ? orderData.address_details.shipping_address.complete_address : '';
//         //newOrder.ShippingState = orderData.address_details.shipping_address.state;
//         newOrder.ShippingPostalCode = orderData.address_details.shipping_address.pin_code != null ? orderData.address_details.shipping_address.pin_code : '';
//         newOrder.Delivery_Mobile_Number__c = orderData.address_details.shipping_address.phone_number != null ? orderData.address_details.shipping_address.phone_number : '';
//         newOrder.ContractId = ContractId;
//         insert newOrder;
//         System.debug('created Order==> ' + newOrder);
//         return newOrder;
//     }

//     public static Order updateOrder(WS_OrderCreation.Data orderData, String originalOrderId) {
//         // Create new order
//         Order newOrder = new Order();
//         newOrder.Name = orderData.order_id != null ? orderData.order_id : '';
//         newOrder.EffectiveDate = orderData.order_date != null ? Date.ValueOf(orderData.order_date) : System.today();
//         newOrder.Payment_Id__c = orderData.payment_id != null ? orderData.payment_id : '';
//         newOrder.Payment_Status__c = orderData.payment_status != null ? orderData.payment_status : '';
//         newOrder.Payment_Type__c = orderData.payment_type != null ? orderData.payment_type : '';
//         newOrder.Amount_from_OMS__c = orderData.amount != null ? orderData.amount : 0;
//         newOrder.Coupon_Code__c = orderData.coupon_code != null ? orderData.coupon_code : '';
//         newOrder.Coupon_Discount__c = orderData.coupon_discount != null ? Decimal.valueOf(orderData.coupon_discount) : 0;
//         newOrder.Coupon__c = orderData.is_coupon_redeemed;
//         newOrder.Id = originalOrderId;
//         newOrder.Status = orderData.order_status;
//         //newOrder.BillingStreet = orderData.address_details.shipping_address.house_number + ' ' + orderData.address_details.shipping_address.street;
//         newOrder.BillingStreet = orderData.address_details.billing_address.complete_address != null ? orderData.address_details.billing_address.complete_address : '';
//         newOrder.BillingPostalCode = orderData.address_details.billing_address.pin_code != null ? orderData.address_details.billing_address.pin_code : '';
//         newOrder.ShippingStreet = orderData.address_details.shipping_address.complete_address != null ? orderData.address_details.shipping_address.complete_address : '';
//         //newOrder.ShippingState = orderData.address_details.shipping_address.state;
//         newOrder.ShippingPostalCode = orderData.address_details.shipping_address.pin_code != null ? orderData.address_details.shipping_address.pin_code : '';
//         newOrder.Delivery_Mobile_Number__c = orderData.address_details.shipping_address.phone_number != null ? orderData.address_details.shipping_address.phone_number : '';
//         update newOrder;
//         System.debug('updated Order==> ' + newOrder);
//         return newOrder;
//     }

//     public static List<Order> createSubOrders(List<WS_OrderCreation.OrderDetails> orderDetails, Id orderId, Id accId, Id ContractId, Date orderDate){
//         try{
//             List<Order> subOrdersToAdd = new List<Order>();
//             for(WS_OrderCreation.OrderDetails orderRec : orderDetails){
//                 Order subOrderRec = new Order();
//                 subOrderRec.Sub_Order_Id__c = orderRec.sub_order_id != null ? orderRec.sub_order_id : '';
//                 subOrderRec.Seller_Name__c = orderRec.sub_order_seller_name != null ? orderRec.sub_order_seller_name : '';
//                 subOrderRec.AWB_Number__c = orderRec.awb_number != null ? orderRec.awb_number : ''; 
//                 subOrderRec.EffectiveDate = orderDate;
//                 subOrderRec.ContractId = ContractId;
//                 subOrderRec.Courier__c = orderRec.courier != null ? orderRec.courier : '';
//                 subOrderRec.Pricebook2Id = '01sIR000002f36lYAA';
//                 if(orderRec.expected_delivery_date != null){
//                     subOrderRec.Expected_Delivery_Date__c = Date.ValueOf(orderRec.expected_delivery_date);
//                 }
//                 subOrderRec.Status = orderRec.Sub_order_status != null ? orderRec.Sub_order_status : '';
//                 subOrderRec.Tracking_Link__c = orderRec.tracking_link != null ? orderRec.tracking_link : '';
//                 subOrderRec.AccountId = accId;
//                 subOrderRec.ParentOrder__c = orderId;
//                 insert subOrderRec;
//                 List<OrderItem> orderItems = createOrderItem(orderRec, subOrderRec.Id);
//                 subOrdersToAdd.add(subOrderRec);
//             }
//             return subOrdersToAdd;
//             // if(!subOrdersToAdd.isEmpty()){
//             //     insert subOrdersToAdd;
//             // }
//         }catch(exception e){
//             System.debug('Error Message ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
//             return null;
//         }
//     }
    
//     public static List<OrderItem> createOrderItem(WS_OrderCreation.OrderDetails orderDetails, Id orderId) {
//         // Create new order item
//         List<OrderItem> oliListToAdd = new List<OrderItem>();
//         for(WS_OrderCreation.ItemDetails itemDetail : orderDetails.item_details){
//             OrderItem newOrderItem = new OrderItem();
//             newOrderItem.Brand__c = itemDetail.brand != null ? itemDetail.brand : '';
//             newOrderItem.UnitPrice = itemDetail.mrp != null ? Decimal.valueOf(itemDetail.mrp) : 0;
//             newOrderItem.OrderId = orderId;
//             newOrderItem.Selling_Price__c = itemDetail.selling_price != null ? itemDetail.selling_price : 0;
//             newOrderItem.Quantity = itemDetail.quantity != null ? itemDetail.quantity : 0;
//             if(itemDetail.refunded_price != '' && itemDetail.refunded_price != null)
//                 newOrderItem.Refunded_Price__c = Decimal.valueOf(itemDetail.refunded_price);
//             newOrderItem.SKU__c = itemDetail.sku != null ? itemDetail.sku : '';
//             newOrderItem.Total_Selling_Price__c = newOrderItem.Selling_Price__c * newOrderItem.Quantity;
//             newOrderItem.Status__c = itemDetail.status != null ? itemDetail.status : '';
//             newOrderItem.Product_Name__c = itemDetail.variant_name != null ? itemDetail.variant_name : '';
//             newOrderItem.PricebookEntryId = '01uF3000005qUMkIAM';
//             newOrderItem.Product2Id = '01tF3000006czvcIAA';
//             oliListToAdd.add(newOrderItem);
//         }
//         insert oliListToAdd;
//         System.debug('inserted OLIs==. ' + oliListToAdd);
//         return oliListToAdd;
//     }
    
//     public static Contract createContract(WS_OrderCreation.Data orderData, Account account) {
//         // Create new contract
        
//         Contract newContract = new Contract();
//         newContract.AccountId = account.Id;
//         System.debug('newContract.AccountId==> ' + newContract.AccountId);
//         newContract.StartDate = orderData.order_date != null ? Date.ValueOf(orderData.order_date) : System.Today();
//         newContract.ContractTerm = 12;
//         // Set other contract fields accordingly
//         insert newContract;
//         System.debug('created Contract==> ' + newContract);
//         return newContract;
//     }
    
//     public static Set<String> getOrderIds(List<WS_OrderCreation> orderRecords) {
//         Set<String> orderIds = new Set<String>();
//         for(WS_OrderCreation orderData : orderRecords) {
//             orderIds.add(orderData.data.order_id);
//         }
//         return orderIds;
//     }
    
//     public static Account_Address__c findOrCreateDeliveryAddress(WS_OrderCreation.AddressDetails addressDetails, Account accRec){
//         try{
//             List<Account_Address__c> deliveryAddressList = [SELECT Id, OwnerId, Name, Address__Street__s, Address__City__s, Address__PostalCode__s, Address__StateCode__s, Address__CountryCode__s, 
//                                                             Address__Latitude__s, Address__Longitude__s, Address__GeocodeAccuracy__s, Address__c, Address_Type__c, Account__c, Mobile_Phone__c, Street__c, City__c, State__c, 
//                                                             Country__c, Postal_Code__c FROM Account_Address__c WHERE Street__c =: addressDetails.billing_address.complete_address 
//                                                            AND Postal_Code__c=: addressDetails.billing_address.pin_code /*AND State__c =: addressDetails.billing_address.state */
//                                                            AND Account__c =: accRec.Id AND Mobile_Phone__c=: addressDetails.billing_address.phone_number LIMIT 1];
//             if(deliveryAddressList.isEmpty()){
//                 Account_Address__c newDeliveryAddressRec = new Account_Address__c();
//              	newDeliveryAddressRec.Street__c = addressDetails.billing_address.complete_address != null ? addressDetails.billing_address.complete_address : '' ;
//                     //newDeliveryAddressRec.State__c = addressDetails.billing_address.state ;
//                     newDeliveryAddressRec.Postal_Code__c = addressDetails.billing_address.pin_code != null ? addressDetails.billing_address.pin_code : '';
//                 newDeliveryAddressRec.Mobile_Phone__c = addressDetails.billing_address.phone_number != null ? addressDetails.billing_address.phone_number : '';
//                 newDeliveryAddressRec.Account__c = accRec.Id;
//                 newDeliveryAddressRec.Address_Type__c = 'Billing';
//                 insert newDeliveryAddressRec;
//                 System.debug('created newDeliveryAddressRec==> ' + newDeliveryAddressRec);
//                 return newDeliveryAddressRec;
//             }else{
//                 System.debug('existing deliveryAddressList[0]==> ' + deliveryAddressList[0]);
//                 return deliveryAddressList[0];
//             }
            
//         }catch(exception e){
//             system.debug('Error Message==>'+e.getMessage() + ' at line==> ' + e.getLineNumber());
//             return null;
//         }
//     }
    
//     public static Account_Address__c findOrCreateShippingAddress(WS_OrderCreation.AddressDetails addressDetails, Account accRec){
//         try{
            
//             //String shippingStreet = addressDetails.shipping_address.house_number + ' ' + addressDetails.shipping_address.street;
//             String shippingStreet = addressDetails.shipping_address.complete_address;
            
//             List<Account_Address__c> shippingAddressList = [SELECT Id, OwnerId, Name, Address__Street__s, Address__City__s, Address__PostalCode__s, Address__StateCode__s, Address__CountryCode__s, 
//                                                             Address__Latitude__s, Address__Longitude__s, Address__GeocodeAccuracy__s, Address__c, Address_Type__c, Account__c, Mobile_Phone__c, Street__c, City__c, State__c, 
//                                                             Country__c, Postal_Code__c FROM Account_Address__c WHERE Street__c =: shippingStreet
//                                                            AND Postal_Code__c=: addressDetails.shipping_address.pin_code AND Mobile_Phone__c=: addressDetails.shipping_address.phone_number AND Account__c =: accRec.Id LIMIT 1];
            
//             if(shippingAddressList.isEmpty()){
//                 Account_Address__c newAddressRec = new Account_Address__c();
//              	//newAddressRec.Street__c = addressDetails.shipping_address.house_number + ' ' + addressDetails.shipping_address.street ;
//                  newAddressRec.Street__c = addressDetails.shipping_address.complete_address != null ? addressDetails.shipping_address.complete_address : '';
//                     newAddressRec.Postal_Code__c = addressDetails.shipping_address.pin_code != null ? addressDetails.shipping_address.pin_code : '';
//                     newAddressRec.Mobile_Phone__c = addressDetails.shipping_address.phone_number != null ? addressDetails.shipping_address.phone_number : '';
//                 newAddressRec.Account__c = accRec.Id;
//                 newAddressRec.Address_Type__c = 'Shipping';
//                 insert newAddressRec;
//                 System.debug('created newAddressRec==> ' + newAddressRec);
//                 return newAddressRec;
//             }else{
//                 System.debug('existing shippingAddressList[0]==> ' + shippingAddressList[0]);
//                 return shippingAddressList[0];
//             }
//         }catch(exception e){
//             system.debug('Error Message==>'+e.getMessage() + ' at line==> ' + e.getLineNumber());
//             return null;
//         }
//     }