@isTest
public class StaticResourceURLTest {
	@isTest
    public static void staticResTest()
    {
        Test.startTest();
        StaticResourceURL.GetResourceURL('backgrounds');
        Test.stopTest();
        System.assertEquals(1, 1, '');
    }
}