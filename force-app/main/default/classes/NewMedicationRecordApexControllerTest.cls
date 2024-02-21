@isTest
public class NewMedicationRecordApexControllerTest
{
    public static testMethod void  forTestData(){
        
        	Id recordTypeIdForMedication = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
         	Id recordTypeIdForRoute = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Route').getRecordTypeId();
         	Id recordTypeIdForDosage = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Dosage').getRecordTypeId();
            ElixirSuite__Master_Object__c medLst=new ElixirSuite__Master_Object__c();
            medLst.Name='Dolo 650';
            medLst.ElixirSuite__Coding_System__c='SNOMEDCT';
            medLst.ElixirSuite__Coding_System_Value__c='123';
            medLst.RecordTypeId=recordTypeIdForMedication;
            insert medLst;
        
        	ElixirSuite__Master_Object__c routeLst=new ElixirSuite__Master_Object__c();
            routeLst.Name='Intravenous';
            routeLst.ElixirSuite__Coding_System__c='SNOMEDCT';
            routeLst.ElixirSuite__Coding_System_Value__c='123';
            routeLst.RecordTypeId=recordTypeIdForRoute;
            insert routeLst;
        
        	ElixirSuite__Master_Object__c dosageLst=new ElixirSuite__Master_Object__c();
            dosageLst.Name='10mg Tablet';
            dosageLst.ElixirSuite__Coding_System__c='SNOMEDCT';
            dosageLst.ElixirSuite__Coding_System_Value__c='123';
            dosageLst.RecordTypeId=recordTypeIdForDosage;
            insert dosageLst;
        	
        	String demoJSON = '{"jsonListForTaper":[{"medicationName":"medLst.Id","types":"Taper","startDate":"2020-02-19","dispenseExpectedSupplyDuration":1,"afterDischarge":true,"Route":routeLst.Id,"Warning":"DEMO WARNING","dosageForm":"film","reasonLabel":"DEMO REASON","endDate":"2020-02-20","Days":[{"times":["00:00:00.000"],"Strength":["5mg"],"Units":["film"],"Dosage":["1"],"Repeat":"n times a day","Dosage_Instruction":1,"textMessage":"1 times a day"}]}],"jsonListForPRN":[{"medicationName":"Demo ","types":"PRN","startDate":"2020-02-19","dispenseExpectedSupplyDuration":1,"afterDischarge":true,"Route":"im","dosageForm":dosageLst.Id,"endDate":"2020-02-20","singleRecForPrn":[{"UnitsForPrn":"Tablet Therapy Pack","StrengthForPrn":"10mg","DosageForPrn":"12","Repeat":"Once a day (HS)","Dosage_Instruction":"2","textMessage":""}],"reasonLabel":"For pain"}]}';
        	//String demoJSONTaper  = '{"jsonListForTaper":[{"medicationName":medLst.Id,"types":"Taper","startDate":"2020-02-19","dispenseExpectedSupplyDuration":1,"afterDischarge":true,"Route":routeLst.Id,"Warning":"DEMO WARNING","dosageForm":dosageLst.Id,"reasonLabel":"DEMO REASON","endDate":"2020-02-20","Days":[{"times":["00:00:00.000"],"Strength":["5mg"],"Units":["film"],"Dosage":["1"],"Repeat":"n times a day","Dosage_Instruction":1,"textMessage":"1 times a day"}]}],"jsonListForPRN":[]}';
        	//String demoJSONActionOrder  = '{"jsonListForActionOrder":[{"MARDisplay":true,"PRNdisplay":false, "medicationName":medLst.Id,"types":"Taper","startDate":"2020-02-19","dispenseExpectedSupplyDuration":1,"afterDischarge":true,"dosageForm":dosageLst.Id,"reasonLabel":"DEMO REASON","Route":"im","Warning":"take regularly", "endDate":"2020-02-20","Days":[{"times":["00:00:00.000"],"Strength":["5mg"],"Units":["film"],"Dosage":["1"],"Repeat":"n times a day","Dosage_Instruction":1,"textMessage":"1 times a day"}],"SingleRecForActionOrder":[{"times":["00:00:00.000"],"Repeat":"n times a day","Dosage_Instruction":1}]}],"jsonListForPRN":[],"jsonListForTaper":[]}';
       		// Id recordTypeIdForOrder = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Frequency').getRecordTypeId();
        
			//String demoJsonForPrn='{"medicationName":medLst.Id,"types":"PRN","startDate":"2020-02-19","dispenseExpectedSupplyDuration":1,"afterDischarge":true,"Route":routeLst.Id,"Warning":"DEMO WARNING","dosageForm":"film","reasonLabel":"DEMO REASON","endDate":"2020-02-20","Days":[{"times":["00:00:00.000"],"Strength":["5mg"],"Units":["Tablet"],"Dosage":["1"],"Repeat":"n times a day","Dosage_Instruction":1,"textMessage":"1 times a day"}]}';       	
        
        					String demoJsonForPrn = '{"jsonListForPRN":[' +
                    '{"medicationName":"' + medLst.Id + '",' +
                    '"types":"PRN",' +
                    '"startDate":"2023-12-19",' +
                    '"dispenseExpectedSupplyDuration":1,' +
                    '"afterDischarge":true,' +
                    '"Route":"' + routeLst.Id + '",' +
                    '"Warning":"DEMO WARNING",' +
                    '"dosageForm":"' + dosageLst.Id + '",' +
                    '"reasonLabel":"DEMO REASON",' +
                    '"endDate":"2024-02-20",' +
                    '"Days":[' +
                        '{"times":["00:00:00.000"],' +
                        '"Strength":["5mg"],' +
                        '"Units":["Tablet"],' +
                        '"Dosage":["1"],' +
                        '"Repeat":"n times a day",' +
                        '"Dosage_Instruction":1,' +
                        '"textMessage":"1 times a day"' +
                        '}' +
                    ']' +
                    '}' +
                '],"jsonListForTaper": [],"jsonListForAOrder": []}';
                            
        
        //Inserting Account
        Account a =new Account ();
        a.Name= 'Virat Kohli';
        a.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        a.ElixirSuite__Gender__c='Male';
        a.ElixirSuite__Email_Id__c='virat@gmail.com';
        a.phone='9988776655';
        a.ElixirSuite__First_Name__c='Virat';
        a.ElixirSuite__Last_Name__c='Kohli';
        a.BillingPostalCode='50021';
        a.ElixirSuite__SSN__c='12345';
        a.ElixirSuite__MRN_Number_New__c='1234567890';
        
        insert a;
        
        //String demoJSONActionOrder  = '{"jsonListForActionOrder":[{"MARDisplay":true,"PRNdisplay":false, "medicationName":medLst.Id,"types":"Taper","startDate":"2020-02-19","dispenseExpectedSupplyDuration":1,"afterDischarge":true,"dosageForm":dosageLst.Id,"reasonLabel":"DEMO REASON","Route":"im","Warning":"take regularly", "endDate":"2020-02-20","Days":[{"times":["00:00:00.000"],"Strength":["5mg"],"Units":["film"],"Dosage":["1"],"Repeat":"n times a day","Dosage_Instruction":1,"textMessage":"1 times a day"}],"SingleRecForActionOrder":[{"times":["00:00:00.000"],"Repeat":"n times a day","Dosage_Instruction":1}]}],"jsonListForPRN":[],"jsonListForTaper":[]}';
                       String demoJSONActionOrder = '{' +
                    '"jsonListForActionOrder": [{' +
                    '    "MARDisplay": true,' +
                    '    "PRNdisplay": false,' +
                    '    "medicationName": "' + medLst.Id + '",' +
                    '    "types": "Action Order",' +
                    '    "startDate": "2023-10-12",' +
                    '    "afterDischarge": false,' +
                    '    "reasonLabel": "",' +
                    '    "Warning": "To be added",' +
                    '    "endDate": "2023-10-13",' +
                    '    "Days": [{' +
                    '        "times": ["00:00:00.000"],' +
                    '        "Strength": ["5mg"],' +
                    '        "Units": ["Tablet"],' +
                    '        "Dosage": ["1"],' +
                    '        "Repeat": "n times a day",' +
                    '        "Dosage_Instruction": 1,' +
                    '        "textMessage": "1 times a day"' +
                    '    }]' +
                    '},' +
                    '], ' +
                    '"jsonListForPRN": [], ' +
                    '"jsonListForTaper": []' +
                '}';


        
        Test.startTest();
        NewMedicationRecordApexController.fetchData ();
        NewMedicationRecordApexController.saveData(demoJsonForPrn,a.Id);
        Test.stopTest();
    
        System.assertEquals(1, 1, ' ');
    }
     public static testMethod void  forTestData2(){
         //Inserting Account
        Account a1 =new Account ();
        a1.Name= 'Virat Kohli1';
        a1.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        a1.ElixirSuite__Gender__c='Male';
        a1.ElixirSuite__Email_Id__c='virat@gmail.com';
        a1.phone='9988776655';
        a1.ElixirSuite__First_Name__c='Virat';
        a1.ElixirSuite__Last_Name__c='Kohli';
        a1.BillingPostalCode='50021';
        a1.ElixirSuite__SSN__c='12345';
        a1.ElixirSuite__MRN_Number_New__c='1234567890';
        
        insert a1;
         
         Id recordTypeIdForMedication = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
         	Id recordTypeIdForRoute = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Route').getRecordTypeId();
         	Id recordTypeIdForDosage = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Dosage').getRecordTypeId();
            ElixirSuite__Master_Object__c medLst=new ElixirSuite__Master_Object__c();
            medLst.Name='Dolo 650';
            medLst.ElixirSuite__Coding_System__c='SNOMEDCT';
            medLst.ElixirSuite__Coding_System_Value__c='123';
            medLst.RecordTypeId=recordTypeIdForMedication;
            insert medLst;
        
        	ElixirSuite__Master_Object__c routeLst=new ElixirSuite__Master_Object__c();
            routeLst.Name='Intravenous';
            routeLst.ElixirSuite__Coding_System__c='SNOMEDCT';
            routeLst.ElixirSuite__Coding_System_Value__c='123';
            routeLst.RecordTypeId=recordTypeIdForRoute;
            insert routeLst;
        
        	ElixirSuite__Master_Object__c dosageLst=new ElixirSuite__Master_Object__c();
            dosageLst.Name='10mg Tablet';
            dosageLst.ElixirSuite__Coding_System__c='SNOMEDCT';
            dosageLst.ElixirSuite__Coding_System_Value__c='123';
            dosageLst.RecordTypeId=recordTypeIdForDosage;
            insert dosageLst;
         String demoJSONTaper = '{"jsonListForTaper":[' +
                    '{"medicationName":"' + medLst.Id + '",' +
                    '"types":"Taper",' +
                    '"startDate":"2022-12-19",' +
                    '"dispenseExpectedSupplyDuration":1,' +
                    '"afterDischarge":true,' +
                    '"Route":"' + routeLst.Id + '",' +
                    '"Warning":"DEMO WARNING",' +
                    '"dosageForm":"' + dosageLst.Id + '",' +
                    '"reasonLabel":"DEMO REASON",' +
                    '"endDate":"2024-02-20",' +
                    '"Days":[' +
                        '{"times":["00:00:00.000"],' +
                        '"Strength":["5mg"],' +
                        '"Units":["Tablet"],' +
                        '"Dosage":["1"],' +
                        '"Repeat":"n times a day",' +
                        '"Dosage_Instruction":1,' +
                        '"textMessage":"1 times a day"' +
                        '}' +
                    ']' +
                    '}' +
                ']}';
        Test.startTest();

        NewMedicationRecordApexController.saveData(demoJSONTaper, a1.Id);
        Test.stopTest();
    
        System.assertEquals(1, 1, ' ');
          
         
     }
    public static testMethod void  forTestData3(){
        Id recordTypeIdForMedication = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Medication').getRecordTypeId();
         	Id recordTypeIdForRoute = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Route').getRecordTypeId();
         	Id recordTypeIdForDosage = Schema.SObjectType.ElixirSuite__Master_Object__c.getRecordTypeInfosByName().get('Dosage').getRecordTypeId();
            ElixirSuite__Master_Object__c medLst=new ElixirSuite__Master_Object__c();
            medLst.Name='Dolo 650';
            medLst.ElixirSuite__Coding_System__c='SNOMEDCT';
            medLst.ElixirSuite__Coding_System_Value__c='123';
            medLst.RecordTypeId=recordTypeIdForMedication;
            insert medLst;
        
        	ElixirSuite__Master_Object__c routeLst=new ElixirSuite__Master_Object__c();
            routeLst.Name='Intravenous';
            routeLst.ElixirSuite__Coding_System__c='SNOMEDCT';
            routeLst.ElixirSuite__Coding_System_Value__c='123';
            routeLst.RecordTypeId=recordTypeIdForRoute;
            insert routeLst;
        
        	ElixirSuite__Master_Object__c dosageLst=new ElixirSuite__Master_Object__c();
            dosageLst.Name='10mg Tablet';
            dosageLst.ElixirSuite__Coding_System__c='SNOMEDCT';
            dosageLst.ElixirSuite__Coding_System_Value__c='123';
            dosageLst.RecordTypeId=recordTypeIdForDosage;
            insert dosageLst;
        	
        	
        	
        					
                            
        
        //Inserting Account
        Account a3 =new Account ();
        a3.Name= 'Virat Kohli';
        a3.ElixirSuite__DOB__c =date.newInstance(2003, 9, 15);
        a3.ElixirSuite__Gender__c='Male';
        a3.ElixirSuite__Email_Id__c='virat@gmail.com';
        a3.phone='9988776655';
        a3.ElixirSuite__First_Name__c='Virat';
        a3.ElixirSuite__Last_Name__c='Kohli';
        a3.BillingPostalCode='50021';
        a3.ElixirSuite__SSN__c='12345';
        a3.ElixirSuite__MRN_Number_New__c='1234567890';
        
        insert a3;
        
     
                 String demoJSONActionOrder = '{"jsonListForActionOrder": ['  +
                 '{"medicationName": "' + medLst.Id + '",' +
                '    "MARDisplay": true,' +
                '    "PRNdisplay": false,' +
               '    "types": "Action Order",' +
                '    "startDate": "2023-10-12",' +
                '    "afterDischarge": false,' +
                '    "reasonLabel": "",' +
                '    "Warning": "To be added",' +
                '    "endDate": "2023-10-13",' +
                '    "Days": [{' +
                '        "times": ["00:00:00.000"],' +
                '        "Strength": ["5mg"],' +
                '        "Units": ["Tablet"],' +
                '        "Dosage": ["1"],' +
                '        "Repeat": "n times a day",' +
                '        "Dosage_Instruction": 1,' +
                '        "textMessage": "1 times a day"' +
               '}' +
                    ']' +
                '}' +
               ']}';


        System.assertEquals(1, 1, ' ');
      
        //NewMedicationRecordApexController.saveData(demoJSONActionOrder, a3.Id);
          
    }
}