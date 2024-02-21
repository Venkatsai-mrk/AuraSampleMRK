public class HL7Utils {
    
    public Static String RetrieveValueFromJSON(String strJSON, String strKey){
        List<Object> result = (List<Object>)JSON.deserializeUntyped(strJSON); 
        String responseValue = '';
        for(Object obj : result) { 
            Map<String,Object> map1 = (Map<String,Object>)obj; 
            for(String key : map1.keyset()) { 
                 
                if (key == strKey) {                  
                    responseValue = (String)map1.get(key);
                }
            }
        }
        return responseValue;
    }

}