global class TimelineSortWrapper  implements Comparable {
	public Master_Object__c oppy;
    public TimelineSortWrapper(Master_Object__c op) {
        oppy = op;
    }
    
    global Integer compareTo(Object compareTo) {      
        TimelineSortWrapper compareToOppy = (TimelineSortWrapper)compareTo;
         Integer returnValue = 0;
        try{
        if (oppy.Sort_Order__c > compareToOppy.oppy.Sort_Order__c) {          
            returnValue = 1;
        } else if (oppy.Sort_Order__c < compareToOppy.oppy.Sort_Order__c) {            
            returnValue = -1;
        } 
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return returnValue;       
    }
}