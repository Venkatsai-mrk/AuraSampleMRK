public class CheckRecursive {
    public static boolean run = true;
    public static boolean runOnce(){
        try{
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return run;
    }
    //
    
    
   
}