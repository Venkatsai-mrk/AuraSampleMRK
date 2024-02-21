public with sharing class ContractedPriceTriggerHelper {
    public static void contractedPriceDuplicateCombo(List <ElixirSuite__Contracted_Price__c> listActual){
        Set<String>objPayerSet = new Set<String>();
        Set<String>objProcedureSet = new Set<String>();
        for(ElixirSuite__Contracted_Price__c objActual : listActual){
            objPayerSet.add(objActual.ElixirSuite__Payer__c);
            objProcedureSet.add(objActual.ElixirSuite__Procedure__c);
        }
        List<ElixirSuite__Contracted_Price__c> listFetch = [Select ElixirSuite__Payer__c ,ElixirSuite__Provider__c,ElixirSuite__Procedure__c,ElixirSuite__Pricing_Effective_End_Date__c,ElixirSuite__Pricing_Effective_Start_Date__c from ElixirSuite__Contracted_Price__c
                                                            where ElixirSuite__Payer__c IN : objPayerSet AND ElixirSuite__Procedure__c IN : objProcedureSet WITH SECURITY_ENFORCED];
        for (ElixirSuite__Contracted_Price__c existingPrice : listFetch) {
            for (ElixirSuite__Contracted_Price__c objActual : listActual) {
                // Check if the start date is within the range of an existing record
                if (objActual.ElixirSuite__Payer__c == existingPrice.ElixirSuite__Payer__c && objActual.ElixirSuite__Provider__c == existingPrice.ElixirSuite__Provider__c 
                    && objActual.ElixirSuite__Procedure__c == existingPrice.ElixirSuite__Procedure__c
                    && ((objActual.ElixirSuite__Pricing_Effective_Start_Date__c >= existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                        && objActual.ElixirSuite__Pricing_Effective_Start_Date__c <= existingPrice.ElixirSuite__Pricing_Effective_End_Date__c) || 
                    objActual.ElixirSuite__Pricing_Effective_End_Date__c >= existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                    && objActual.ElixirSuite__Pricing_Effective_End_Date__c <= existingPrice.ElixirSuite__Pricing_Effective_End_Date__c )) {
                        objActual.addError('There are existing contracted prices for this date range.');
                    }
                if (objActual.ElixirSuite__Payer__c == existingPrice.ElixirSuite__Payer__c && objActual.ElixirSuite__Provider__c == existingPrice.ElixirSuite__Provider__c
                    && objActual.ElixirSuite__Procedure__c == existingPrice.ElixirSuite__Procedure__c
                    && ((existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c >= objActual.ElixirSuite__Pricing_Effective_Start_Date__c
                        && existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c <= objActual.ElixirSuite__Pricing_Effective_End_Date__c) || 
                    existingPrice.ElixirSuite__Pricing_Effective_End_Date__c >= objActual.ElixirSuite__Pricing_Effective_Start_Date__c
                    && existingPrice.ElixirSuite__Pricing_Effective_End_Date__c <= objActual.ElixirSuite__Pricing_Effective_End_Date__c )) {
                        objActual.addError('There are existing contracted prices for this date range.');
                    }
            }
        }
    }
    public static void contractedPriceDuplicateComboUpdate(List <ElixirSuite__Contracted_Price__c> listActual){
        Set<String>objPayerSet = new Set<String>();
        Set<String>objProcedureSet = new Set<String>();
        for(ElixirSuite__Contracted_Price__c objActual : listActual){
            objPayerSet.add(objActual.ElixirSuite__Payer__c);
            objProcedureSet.add(objActual.ElixirSuite__Procedure__c);
        }
        List<ElixirSuite__Contracted_Price__c> listFetch = [Select ElixirSuite__Payer__c ,ElixirSuite__Provider__c,ElixirSuite__Procedure__c,ElixirSuite__Pricing_Effective_End_Date__c,ElixirSuite__Pricing_Effective_Start_Date__c from ElixirSuite__Contracted_Price__c
                                                            where ElixirSuite__Payer__c IN : objPayerSet AND ElixirSuite__Procedure__c IN : objProcedureSet WITH SECURITY_ENFORCED];
        for (ElixirSuite__Contracted_Price__c existingPrice : listFetch) {
            for (ElixirSuite__Contracted_Price__c objActual : listActual) {
                // Check if the start date is within the range of an existing record
                
                if (objActual.Id != existingPrice.Id && objActual.ElixirSuite__Payer__c == existingPrice.ElixirSuite__Payer__c && objActual.ElixirSuite__Provider__c == existingPrice.ElixirSuite__Provider__c
                    && objActual.ElixirSuite__Procedure__c == existingPrice.ElixirSuite__Procedure__c
                   // && (objActual.ElixirSuite__Pricing_Effective_Start_Date__c != existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                    //    || objActual.ElixirSuite__Pricing_Effective_End_Date__c != existingPrice.ElixirSuite__Pricing_Effective_End_Date__c)
                    && (objActual.ElixirSuite__Pricing_Effective_Start_Date__c >= existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                        && objActual.ElixirSuite__Pricing_Effective_Start_Date__c <= existingPrice.ElixirSuite__Pricing_Effective_End_Date__c
                        || objActual.ElixirSuite__Pricing_Effective_End_Date__c >= existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                        && objActual.ElixirSuite__Pricing_Effective_End_Date__c <= existingPrice.ElixirSuite__Pricing_Effective_End_Date__c)) {
                            objActual.addError('There are existing contracted prices for this date range.');
                        }
                if (objActual.Id != existingPrice.Id && objActual.ElixirSuite__Payer__c == existingPrice.ElixirSuite__Payer__c && objActual.ElixirSuite__Provider__c == existingPrice.ElixirSuite__Provider__c
                    && objActual.ElixirSuite__Procedure__c == existingPrice.ElixirSuite__Procedure__c
                   // && (objActual.ElixirSuite__Pricing_Effective_Start_Date__c != existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c
                    //    || objActual.ElixirSuite__Pricing_Effective_End_Date__c != existingPrice.ElixirSuite__Pricing_Effective_End_Date__c)
                    && (existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c >= objActual.ElixirSuite__Pricing_Effective_Start_Date__c
                        && existingPrice.ElixirSuite__Pricing_Effective_Start_Date__c <= objActual.ElixirSuite__Pricing_Effective_End_Date__c
                        || existingPrice.ElixirSuite__Pricing_Effective_End_Date__c >= objActual.ElixirSuite__Pricing_Effective_Start_Date__c
                        && existingPrice.ElixirSuite__Pricing_Effective_End_Date__c <= objActual.ElixirSuite__Pricing_Effective_End_Date__c)) {
                            objActual.addError('There are existing contracted prices for this date range.');
                        }
            }
        }
    }
}