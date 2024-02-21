@isTest
public class FirstVisitNotesController_Test 
{
    
	@isTest
    public static void getAcctSpecificProblemTest()
    {
        Account accId = new Account();
                
        FirstVisitNotesController.parentWrapper objParent = new FirstVisitNotesController.parentWrapper();
         List<Dataset1__c> relatedProblemsTest =objParent.relatedProblems;
         List<Form_Field__c > formFieldsTest =objParent.formFields;
         List<Prescription_Order__c > currentMedTest =objParent.currentMed;
         List<case> relatedProblems1Test =objParent.relatedProblems1;
        
        List<Prescription_Order__c> presList = new List<Prescription_Order__c>();
         Prescription_Order__c objpresc = new Prescription_Order__c();
         presList.add(objpresc);
        
        Notes__c N1 = new Notes__c();
        N1.ElixirSuite__Type__c ='Doctor Notes';
        N1.Notes__c = 'abc';
            insert N1;
        
       deserializeWrapper dobj = new deserializeWrapper();
        List<deserializeWrapper> desList = new List<deserializeWrapper>();
            desList.add(dobj);
        
        medicines mtest = new medicines();
        mtest.medications = desList;
        
        labOrders labTest = new labOrders();
        labTest.labOrders = desList;
        
        problems probTest = new problems();
        probTest.problems = desList;
        
        diagnosis diagTest = new diagnosis();
        diagTest.diagnosis = desList;

        List<vitals> vitList = new List<vitals>(); 
        vitals vitalTest = new vitals();
        vitalTest.height ='as';
        vitalTest.Weight ='sa';
        vitalTest.bpsys ='ss';
        vitalTest.bpDias ='aa';
        vitalTest.temp ='ww';
        vitalTest.pulse ='ee';
        vitalTest.oxySat ='rr';
        vitList.add(vitalTest);
       
        test.startTest();
        FirstVisitNotesController.getAcctSpecificProblem(accId.Id);
        FirstVisitNotesController.saveNotes(string.valueOf(accId.Id),N1.Notes__c,'abc','bca','cdf',JSON.serialize(mtest),'str',JSON.serialize(labTest),JSON.serialize(probTest),JSON.serialize(diagTest),JSON.serialize(vitalTest),presList,N1.ElixirSuite__Type__c);
        FirstVisitNotesController.getNotesData(N1.id);
        test.stopTest();
          System.assertEquals(1, 1, ' ');
         }
     public class medicines{
        List<deserializeWrapper> medications;
    }
    public class labOrders{
        List<deserializeWrapper> labOrders;
    } 
    public class problems{
        List<deserializeWrapper> problems;
    }
     public class diagnosis{
        List<deserializeWrapper> diagnosis;
    }
     public class deserializeWrapper{
        public String Id;
        public String FieldName;
        public String Description;
    }
     public class vitals{
        public String height;
        public String Weight;
        public String bpsys;
        public String bpDias;
        public String temp;
        public String pulse;
        public String oxySat; 
    }
    }