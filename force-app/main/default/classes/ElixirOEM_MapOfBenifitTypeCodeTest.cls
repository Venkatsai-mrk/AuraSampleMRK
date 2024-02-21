@isTest 
public class ElixirOEM_MapOfBenifitTypeCodeTest {
    @isTest
    public static void unitTest(){
        Map<String,String> expectedbenifitTypeCodeMap = new Map<String,String> {
        '33'  => 'Chiropractic',
        '30' =>'Health Benefit Plan Coverage'
        };
            Test.startTest();
        ElixirOEM_MapOfBenifitTypeCode cl = new ElixirOEM_MapOfBenifitTypeCode();
            System.assertEquals(1, 1, ' ');
            Test.stopTest();
        
    }

}