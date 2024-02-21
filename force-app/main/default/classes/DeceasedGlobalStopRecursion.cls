public class DeceasedGlobalStopRecursion {
    public static boolean run = true;
    public static boolean runForPortal = true;
    
     @InvocableMethod
    public static void stoprecur(){
        ElixirSuite.DeceasedGlobalStopRecursion.run = false;
    }
}