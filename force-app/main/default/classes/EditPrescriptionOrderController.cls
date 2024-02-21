public with sharing class EditPrescriptionOrderController {
@AuraEnabled
    public static wrapData fetchMedications() {
        System.debug('inside medication');
        
        List<Prescription_Order__c> Medicationlst = [SELECT Id, Drug_Name__c,Reason__c,Reason_new__c, Type__c,Start_Date__c,MAR_Display__c,Justification__c,Notes__c,
                                                                             Number_of_Times_Days_Weeks__c,After_Discharge__c,Route__c,Route_New__c,
                                                                          (select id,Frequency_Unit__c,Repeat__c,Frequency_Value__c,  Start_Time_1__c,Dosage_Instruction__c  from Frequency__r)
                                                                            from Prescription_Order__c where Account__c = null and Id In (Select Prescription_Order__c from Frequency__c where Prescription_Order__c !=null) 
                                                                            WITH SECURITY_ENFORCED
                                                                            ORDER BY LastModifiedDate DESC];
        
        List<Prescription_Order__c> dataWithPrn = new List<Prescription_Order__c>();
        List<Prescription_Order__c> dataWithTaper = new List<Prescription_Order__c>();
        List<Prescription_Order__c> dataWithProtocol = new List<Prescription_Order__c>();
         List<Prescription_Order__c> dataWithStandard = new List<Prescription_Order__c>();
         List<Prescription_Order__c> dataWithActionOrder = new List<Prescription_Order__c>();
        
        for(Prescription_Order__c p :Medicationlst ){
            if(p.Type__c=='PRN') {
                dataWithPrn.add(p);               
            }
            else if(p.Type__c=='Taper') {
                dataWithTaper.add(p);
            }
             else if(p.Type__c=='Protocol') {
                dataWithProtocol.add(p);
            }
             else if(p.Type__c=='Standard') {
                dataWithStandard.add(p);
            }
             else if(p.Type__c=='Action Order') {
                dataWithActionOrder.add(p);
            }
            
            System.debug('Avction order'+dataWithActionOrder);
            
        } 
       
			System.debug('ftnmhgft '+dataWithPrn);  
       String nameSpace=Elixir_Utility.getNamespace();
      
        return (new wrapData(dataWithPrn,dataWithTaper,dataWithProtocol,dataWithStandard,dataWithActionOrder,nameSpace) );
    }
        public class wrapData{
        @AuraEnabled
        public List<Prescription_Order__c> prescriptionWithPRN;
        @AuraEnabled
         public List<Prescription_Order__c> prescriptionWithTaper;
        @AuraEnabled
         public List<Prescription_Order__c> prescriptionWithProtocol;
        @AuraEnabled
         public List<Prescription_Order__c> prescriptionWithStandard;
          @AuraEnabled
         public List<Prescription_Order__c> prescriptionActionOrder;
            @AuraEnabled public String nameSpace;
      
        public wrapData(List<Prescription_Order__c> prescriptionWithPRN, List<Prescription_Order__c> prescriptionWithTaper,
                        List<Prescription_Order__c> prescriptionWithProtocol,List<Prescription_Order__c> prescriptionWithStandard,
                       List<Prescription_Order__c> prescriptionActionOrder, String nameSpace){
            this.prescriptionWithPRN=prescriptionWithPRN;
            this.prescriptionWithTaper=prescriptionWithTaper;
            this.prescriptionWithProtocol=prescriptionWithProtocol;
            this.prescriptionWithStandard=prescriptionWithStandard;
            this.prescriptionActionOrder=prescriptionActionOrder;
            this.nameSpace=nameSpace;               
            
            
        }
        
    }
}