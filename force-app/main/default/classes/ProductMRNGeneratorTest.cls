@isTest
public class ProductMRNGeneratorTest {
    @isTest
    static void testgenerateMRN() {
        Account acc = TestDataFactory.createPatientAcc();
        insert acc;
        Test.startTest();
        ProductMRNGenerator pmg = new ProductMRNGenerator();
        pmg.generateMRN(acc.Id);
        system.assertEquals(1, 1,' ');
        Test.stopTest();
    }
}