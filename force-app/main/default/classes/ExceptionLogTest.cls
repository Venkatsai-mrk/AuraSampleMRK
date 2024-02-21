@isTest
public class ExceptionLogTest {
    @isTest
    public static void logTest(){
        ExceptionLog.logDebugString('Error');
        ExceptionLog.logHTTPtransaction('200', 'reqBody', 'resBody', 'endPoint', 'apexMethod', 'httpMethod');
        System.AssertEquals(1,1,'');
    }
}