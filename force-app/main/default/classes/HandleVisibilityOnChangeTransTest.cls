@isTest
public class HandleVisibilityOnChangeTransTest {
    @isTest
    public static void method(){
        //  code removal for LX3-10737
        system.assertEquals(1,1,' ');
    }
}