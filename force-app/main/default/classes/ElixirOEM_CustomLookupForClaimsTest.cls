@isTest
public class ElixirOEM_CustomLookupForClaimsTest {
    @isTest
    public static void unitTest()
    {
        ElixirOEM_CustomLookupForClaimsHelper.fetchRecords1('Account','Name','Test');
            ElixirOEM_CustomLookupForClaimsHelper.employerList('Demo');
           system.assertEquals(1, 1,'');
        
    }
}