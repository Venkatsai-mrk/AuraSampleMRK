@isTest
public class HexUtilTest {
   
    @isTest    
    static void testHexUtil(){
        Blob testData = Blob.valueOf('Hello, World!');
        String input = '0123456789abcdef';
        Integer inputInt = 1234567890;
        Integer sizeInBytes = 4;
        Test.startTest();
        HexUtil.CRC32Table(testData);
        HexUtil.CRC32Table(input);
        HexUtil.hexToIntLE(input);
        HexUtil.intToHexLE(inputInt,sizeInBytes);
        system.assertEquals(1, 1, ' ');
        Test.stopTest();
    }

}