@IsTest
public class ItemHelperTest  
{
	private static integer currentNumber = 1;
	public static integer getNextNumber()
	{
		currentNumber++;
		return currentNumber;
	}

	public static void insertItems()
	{
		Test.startTest();

		List<PricebookEntry> pbes = [SELECT Id FROM PricebookEntry];
		delete pbes;

		List<OrderApi__Item_Class__c> classes = new List<OrderApi__Item_Class__c>();
		OrderApi__Item_Class__c clas = new OrderApi__Item_Class__c();
		clas.Name = 'OLC-CLS';
		classes.add(clas);

		OrderApi__Item_Class__c clas2 = new OrderApi__Item_Class__c();
		clas2.Name = 'OLC-CLS2';

		classes.add(clas2);

		insert classes;

		List<OrderApi__Item__c> items = new List<OrderApi__Item__c>();
		OrderApi__Item__c item = new OrderApi__Item__c();
		item.OrderApi__Item_Class__c = classes[0].Id;
		item.Name = 'ITEM - 001';
		item.OrderApi__Cost__c = 25 - (.15);
		item.OrderApi__Description__c = 'DESCRIPTION 001';
		item.OrderApi__Display_Name__c = 'DISPLAY 001';
		item.OrderApi__eStore_Description__c = 'STORE DESC 001';
		item.OrderApi__Cost__c = 50 - (.15);
		item.OrderApi__Price__c = (50 - (.15)) * getNextNumber();
		items.add(item);

		OrderApi__Item__c item2 = new OrderApi__Item__c();
		item2.OrderApi__Item_Class__c = classes[1].Id;
		item2.Name = 'ITEM - 002';
		item2.OrderApi__Cost__c = 25 - (.15);
		item2.OrderApi__Description__c = 'DESCRIPTION 002';
		item2.OrderApi__Display_Name__c = 'DISPLAY 002';
		item2.OrderApi__eStore_Description__c = 'STORE DESC 002';
		item2.OrderApi__Cost__c = 50 - (.18);
		item2.OrderApi__Price__c = (50 - (.18)) * getNextNumber();
		items.add(item2);
		insert items;

		item2.OrderApi__Price__c = (50 - (.18)) * getNextNumber();
		update item2;

		Test.stopTest();
	}


	public static testmethod void willInsertProducts()
	{
		insertItems();

		List<OrderApi__Item__c> items = [ SELECT Id, Name FROM OrderApi__Item__c ];
		List<Product2> products = [ SELECT Id, Name, Item__c FROM Product2 WHERE Item__c != NULL ];

		Map<Id, Product2> prodMap = new Map<Id, Product2>();
		for(Product2 product : products)
		{
			prodMap.put(product.Item__c, product);	
		}


		for(OrderApi__Item__c item : items)
		{
			Product2 prod = prodMap.get(item.Id);
			System.assert(prod != null, 'Each item created should have a corresponding product.');
		}

	}
}