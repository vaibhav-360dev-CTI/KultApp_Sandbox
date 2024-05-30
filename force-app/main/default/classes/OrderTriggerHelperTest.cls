@isTest(seeAllData= true)
public class OrderTriggerHelperTest {
    @isTest
    static void setup() {
        List<OrderItem> orderItems = new List<OrderItem>();
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone ='12345678'
        );
        insert testAccount;
        
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'Tesrtt';
        objProduct.Description = 'Tesrt';
        Insert objProduct;
        
        PriceBook2 pb2Standard = [Select Id from Pricebook2 where isStandard=true limit 1];
        
        PricebookEntry objPBEntry = new PricebookEntry();
        objPBEntry.Pricebook2Id =pb2Standard.id;
        objPBEntry.Product2Id = objProduct.id;
        objPBEntry.UnitPrice = 100;  
        objPBEntry.IsActive = true;
        Insert objPBEntry;
        
        Order testOrder = new Order(Name='234452',AccountId = testAccount.Id, Status = 'Draft',EffectiveDate=system.today(),Pricebook2Id = pb2Standard.Id,Total_Amount__c=100);
        insert testOrder;
        
        Order testOrder1 = new Order(Name='234452',AccountId = testAccount.Id, Status = 'Draft',EffectiveDate=system.today(),Pricebook2Id = pb2Standard.Id,ParentOrder__c = testOrder.Id,Total_Amount__c=100);
        insert testOrder1;
        
        OrderItem orderItem1 = new OrderItem(
            OrderId = testOrder1.Id,
            Quantity = 1,
            UnitPrice = 100,
            SKU__c='Test',
            PricebookEntryId = objPBEntry.Id
        );
        insert orderItem1;
        orderItems.add(orderItem1);
        OrderItem orderItem2 = new OrderItem(
            OrderId = testOrder1.Id,
            Quantity = 2,
            UnitPrice = 150,
            SKU__c='Test',
            PricebookEntryId = objPBEntry.Id
        );
        
        insert orderItem2;
        orderItems.add(orderItem2);
        
        Test.startTest();
        OrderTriggerHelper.UpdateOrderLineItemOnOrder(orderItems);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateOrderLineItemOnOrder() {
        List<OrderItem> orderItems = [SELECT Id, OrderId, TotalPrice FROM OrderItem];
        
        Test.startTest();
        OrderTriggerHelper.UpdateOrderLineItemOnOrder(orderItems);
        Test.stopTest();
        
    }
}