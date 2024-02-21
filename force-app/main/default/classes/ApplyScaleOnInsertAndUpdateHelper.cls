public class ApplyScaleOnInsertAndUpdateHelper {
    public static void applyScale(List<ElixirSuite__Test_Result_Detail__c> records) {
        for (ElixirSuite__Test_Result_Detail__c record : records) {
             if (record.ElixirSuite__Result_Value__c != null) {
                Decimal resultValueDecimal = Decimal.valueOf(record.ElixirSuite__Result_Value__c);
                 system.debug('resultValueDecimal'+ resultValueDecimal);
                record.ElixirSuite__Result_Value__c = String.valueOf(resultValueDecimal.setScale(2));
                
            }
            if (record.ElixirSuite__Observation_Value_Numeric__c != null) {
                //Decimal resultValueDecimal = Decimal.valueOf(record.ElixirSuite__Result_Value__c);
                
                record.ElixirSuite__Observation_Value_Numeric__c = record.ElixirSuite__Observation_Value_Numeric__c.setScale(2);
                 
            }
            
        }
    }
}