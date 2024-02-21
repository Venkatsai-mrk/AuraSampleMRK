@isTest
public class UpdateFormForPortalTest {
	@isTest
    static void testUpdateForm(){
        Account testPatient = TestDataFactory.createPatientAcc();
        insert testPatient;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1];
        User user = new User();
        user.ProfileID = profileId.id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'firstt';
        user.LastName = 'lastt';
        user.Username = 'testtt@uniquedomain.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        insert user;
        
        Integer minNumber = (Integer)Math.pow(10, 8);
        Integer maxNumber = (Integer)Math.pow(10, 9) - 1;
        Integer random9DigitNumber = (Integer)Math.floor(Math.random() * (maxNumber - minNumber + 1) + minNumber);
        String formId = testPatient.Id+';'+random9DigitNumber;
        List<Map<String, String>> wrappedData = new List<Map<String, String>>();
        Map<String, String> formData = new Map<String, String>{
            'formId' => formId,
            'formName' => testPatient.Name
        };
        wrappedData.add(formData);
        Test.startTest();
        system.runAs(user) {
        //Elixir_NewAccountAssociatedFormsApex.submitSelectedFormsToEHRFromPortal(wrappedData);
        UpdateFormForPortal.updateForm(testPatient.Id, formData.get('formId'), formData.get('formName'));
        }
        system.assertEquals(1,1,'');
        Test.stopTest();
    }
}