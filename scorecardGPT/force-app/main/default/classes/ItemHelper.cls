public without sharing class ItemHelper
{
     public static Map<Id, Product2> syncItemProducts(Set<Id> itemIds)
     {
          Map<Id, Product2> itemProductsMap = new Map<Id, Product2> ();

          List<OrderApi__Item__c> items = [SELECT Id, Name, OrderApi__Price__c, OrderApi__Display_Name__c,
                                           OrderApi__Is_Active__c, OrderApi__Description__c, OrderApi__SKU__c,
                                           OrderApi__UPC__c
                                           FROM OrderApi__Item__c
                                           WHERE Id IN :itemIds];

          Map<Id, OrderApi__Item__c> itemMap = new Map<Id, OrderApi__Item__c> ();
          for (OrderApi__Item__c item : items)
          {
               itemMap.put(item.Id, item);
          }

          List<Product2> products = [SELECT Id, Name, Item__c, IsActive, ProductCode,
                                     Description, StockKeepingUnit
                                     FROM Product2
                                     WHERE Item__c IN :itemIds];

          for (Product2 product : products)
          {
               itemProductsMap.put(product.Item__c, product);
          }

          List<Product2> prodsForUpsert = new List<Product2> ();
          Product2 product;
          for (OrderApi__Item__c item : items)
          {
               product = itemProductsMap.get(item.Id);
               if (product == null)
               {
                    product = new Product2();
                    product.Item__c = item.Id;
               }

			   product.Name = item.Name;
               //product.Name = item.OrderApi__Display_Name__c;
               product.IsActive = item.OrderApi__Is_Active__c;
               product.ProductCode = item.OrderApi__UPC__c;

			   product.Description = '';
			   if(String.isNotBlank(item.OrderApi__Description__c)){
				   if(item.OrderApi__Description__c.length() > 4000) product.Description = item.OrderApi__Description__c.substring(0, 3990) + '..';
				   else product.Description = item.OrderApi__Description__c;
			   }

			   product.StockKeepingUnit = '';
			   if(String.isNotBlank(item.OrderApi__SKU__c)){
			       if(item.OrderApi__SKU__c.length() > 180) product.StockKeepingUnit = item.OrderApi__SKU__c.substring(0, 179);
				   else product.StockKeepingUnit = item.OrderApi__SKU__c;
			   }

               prodsForUpsert.add(product);
          }

          if (prodsForUpsert.size() > 0)
          {
               itemProductsMap.clear();
               upsert prodsForUpsert;

               List<Id> productIds = new List<Id> ();
               for (Product2 productEntry : prodsForUpsert)
               {
                    itemProductsMap.put(productEntry.Item__c, productEntry);
                    productIds.add(productEntry.Id);
               }

               string defaultPricebookId = Label.Default_Pricebook_Id;
               if (string.isNotBlank(defaultPricebookId))
               {
                    List<PricebookEntry> pbes = [SELECT Id, Pricebook2Id, Product2Id, IsActive
                                                 FROM PricebookEntry
                                                 WHERE(Pricebook2Id = :defaultPricebookId)
                                                 AND(Product2Id IN :productIds)];

                    Map<Id, PricebookEntry> priceEntryMap = new Map<Id, PricebookEntry> ();
                    for (PricebookEntry pbe : pbes)
                    {
                         priceEntryMap.put(pbe.Product2Id, pbe);
                    }

                    List<PricebookEntry> pbeForInsert = new List<PricebookEntry> ();
                    List<PricebookEntry> pbeForUpdate = new List<PricebookEntry> ();
                    PricebookEntry pbe;
                    OrderApi__Item__c item;
					boolean isNew = true;
                    for (Product2 prod : prodsForUpsert)
                    {
                         item = itemMap.get(prod.Item__c);
                         pbe = priceEntryMap.get(prod.Id);
						 isNew = false;
                         if (pbe == null)
                         {
                              pbe = new PricebookEntry();
                              pbe.Product2Id = product.Id;
	                          pbe.Pricebook2Id = defaultPricebookId;

							  isNew = true;
                         }

						 pbe.UnitPrice = item.OrderApi__Price__c;
						 pbe.IsActive = prod.IsActive;

						 if(isNew) pbeForInsert.add(pbe);
						 else pbeForUpdate.add(pbe);
                    }

                    if (pbeForInsert.size() > 0) insert pbeForInsert;
                    if (pbeForUpdate.size() > 0) update pbeForUpdate;
               }

          }

          return itemProductsMap;
     }
}