public with sharing class ActualPriceTriggerHelper {
    public static void actualPriceDuplicateCombo(List <ElixirSuite__Actual_Price__c> listActual){
        Set<String>objProviderSet = new Set<String>();
        Set<String>objProcedureSet = new Set<String>();
        for(ElixirSuite__Actual_Price__c objActual : listActual){
            objProviderSet.add(objActual.ElixirSuite__Provider__c);
            objProcedureSet.add(objActual.ElixirSuite__Procedure__c);
        }
        List<ElixirSuite__Actual_Price__c> listFetch = [Select ElixirSuite__Provider__c ,ElixirSuite__Procedure__c,ElixirSuite__Pricing_Effective_End_Date__c,ElixirSuite__Pricing_Effective_Start_Date__c 
                                                        from ElixirSuite__Actual_Price__c 
                                                        where ElixirSuite__Provider__c IN : objProviderSet AND ElixirSuite__Procedure__c IN : objProcedureSet WITH SECURITY_ENFORCED ];
        
        for (ElixirSuite__Actual_Price__c existingPrice : listFetch) {
            for (ElixirSuite__Actual_Price__c objActual : listActual) {
                // Check if the start date is within the range of an existing record
                if (objActual.ElixirSuite__Provider__c == existingPrice.ElixirSuite__Provider__c
                    && objActual.ElixirSuite__Procedure__c == existingPrice.ElixirSuite__Procedure__c
                    && (objActual.ElixirSuite__Pricing_Effective_Start_Date__c >= existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                        && objActual.ElixirSuite__Pricing_Effective_Start_Date__c <= existingPrice.ElixirSuite__Pricing_Effective_End_Date__c) || 
                    objActual.ElixirSuite__Pricing_Effective_End_Date__c >= existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                    && objActual.ElixirSuite__Pricing_Effective_End_Date__c <= existingPrice.ElixirSuite__Pricing_Effective_End_Date__c ) 
                {
                    objActual.addError('There are existing actual prices for this date range.');
                }
                // Check if the end date is within the range of an existing record
                if (objActual.ElixirSuite__Provider__c == existingPrice.ElixirSuite__Provider__c
                    && objActual.ElixirSuite__Procedure__c == existingPrice.ElixirSuite__Procedure__c
                    && (existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c >= objActual.ElixirSuite__Pricing_Effective_Start_Date__c
                        && existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c <= objActual.ElixirSuite__Pricing_Effective_End_Date__c) || 
                    existingPrice.ElixirSuite__Pricing_Effective_End_Date__c >= objActual.ElixirSuite__Pricing_Effective_Start_Date__c
                    && existingPrice.ElixirSuite__Pricing_Effective_End_Date__c <= objActual.ElixirSuite__Pricing_Effective_End_Date__c ) 
                {
                    objActual.addError('There are existing actual prices for this date range.');
                }
            }
        }
    }
    public static void actualPriceDuplicateComboUpdate(List <ElixirSuite__Actual_Price__c> listActual){
        Set<String>objProviderSet = new Set<String>();
        Set<String>objProcedureSet = new Set<String>();
        for(ElixirSuite__Actual_Price__c objActual : listActual){
            objProviderSet.add(objActual.ElixirSuite__Provider__c);
            objProcedureSet.add(objActual.ElixirSuite__Procedure__c);
        }
        List<ElixirSuite__Actual_Price__c> listFetch = [Select ElixirSuite__Provider__c ,ElixirSuite__Procedure__c,ElixirSuite__Pricing_Effective_End_Date__c,ElixirSuite__Pricing_Effective_Start_Date__c from ElixirSuite__Actual_Price__c 
                                                        where ElixirSuite__Provider__c IN : objProviderSet AND ElixirSuite__Procedure__c IN : objProcedureSet WITH SECURITY_ENFORCED];
        for (ElixirSuite__Actual_Price__c existingPrice : listFetch) {
            for (ElixirSuite__Actual_Price__c objActual : listActual) {
                // Check if the start date is within the range of an existing record
                
                if (objActual.Id != existingPrice.Id && objActual.ElixirSuite__Provider__c == existingPrice.ElixirSuite__Provider__c
                    && objActual.ElixirSuite__Procedure__c == existingPrice.ElixirSuite__Procedure__c
                  //  && (objActual.ElixirSuite__Pricing_Effective_Start_Date__c != existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                    //    || objActual.ElixirSuite__Pricing_Effective_End_Date__c != existingPrice.ElixirSuite__Pricing_Effective_End_Date__c)
                    && (objActual.ElixirSuite__Pricing_Effective_Start_Date__c >= existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                        && objActual.ElixirSuite__Pricing_Effective_Start_Date__c <= existingPrice.ElixirSuite__Pricing_Effective_End_Date__c
                        || objActual.ElixirSuite__Pricing_Effective_End_Date__c >= existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                        && objActual.ElixirSuite__Pricing_Effective_End_Date__c <= existingPrice.ElixirSuite__Pricing_Effective_End_Date__c)) {
                            objActual.addError('There are existing actual prices for this date range.');
                        }
                if (objActual.Id != existingPrice.Id && objActual.ElixirSuite__Provider__c == existingPrice.ElixirSuite__Provider__c
                    && objActual.ElixirSuite__Procedure__c == existingPrice.ElixirSuite__Procedure__c
                  //  && (objActual.ElixirSuite__Pricing_Effective_Start_Date__c != existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                    //    || objActual.ElixirSuite__Pricing_Effective_End_Date__c != existingPrice.ElixirSuite__Pricing_Effective_End_Date__c)
                    && (existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c >= objActual.ElixirSuite__Pricing_Effective_Start_Date__c
                        && existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c <= objActual.ElixirSuite__Pricing_Effective_End_Date__c
                        || existingPrice.ElixirSuite__Pricing_Effective_End_Date__c >= objActual.ElixirSuite__Pricing_Effective_Start_Date__c
                        && existingPrice.ElixirSuite__Pricing_Effective_End_Date__c <= objActual.ElixirSuite__Pricing_Effective_End_Date__c)) {
                            objActual.addError('There are existing actual prices for this date range.');
                        }
            }
        }
    }
}