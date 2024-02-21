public with sharing class ReservationProcedureCreation_Batch implements Database.Batchable<sObject> {
    
    public String lineItemQuery;
    public Date dateFilter;
    public List<String> statusFilter;
    public String isBillable;
    
    
    public ReservationProcedureCreation_Batch(){
        dateFilter  = System.today();
        String reservationStatus = System.Label.ReservationStatus;
        statusFilter = reservationStatus.split(',');
        isBillable = 'True';   
        lineItemQuery = 'SELECT Id, Name, Suite__c, Room__c, Bed__c, Reservation__c, Unit_Price__c, Reservation__r.Account__c FROM Reservation_line_item__c WHERE isBillable__c =: isBillable AND Bed_Status__c IN: statusFilter AND DAY_ONLY(Start_Date__c)<=: dateFilter AND DAY_ONLY(End_Date__c)>=: dateFilter ';
    }
    
    public ReservationProcedureCreation_Batch(Date customDateTime){
        dateFilter = customDateTime;
        String reservationStatus = System.Label.ReservationStatus;
        statusFilter = reservationStatus.split(',');
        isBillable = 'True';
        
        lineItemQuery = 'SELECT Id, Name, Suite__c, Room__c, Bed__c, Reservation__c, Unit_Price__c, Reservation__r.Account__c FROM Reservation_line_item__c WHERE isBillable__c =: isBillable AND Bed_Status__c IN: statusFilter AND DAY_ONLY(Start_Date__c)<=: dateFilter AND DAY_ONLY(End_Date__c)>=: dateFilter ';
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(lineItemQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<ElixirSuite__Reservation_line_item__c> lineItems){
        
        Set<Id> reservationIds = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        //Map<Id, Procedure__c> accountToProcedure = new Map<Id, Procedure__c>(); //Map to check patient procedure of that account
        Map<Id, Set<Id>> accountToProcedure = new Map<Id, Set<Id>>(); //Map to check patient procedure of that account
        for(ElixirSuite__Reservation_line_item__c item : lineItems){
            reservationIds.add(item.Reservation__c);
            accIds.add(item.Reservation__r.Account__c);
            if(item.Suite__c != null){
                locationIds.add(item.Suite__c);
            }
            if(item.Room__c != null){
                locationIds.add(item.Room__c);                    
            }
            if(item.Bed__c != null){
                locationIds.add(item.Bed__c);                   
            }
        }
        Id recordTypId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Template_Procedure').getRecordTypeId();
        List<ElixirSuite__Procedure__c> procedureOfLocation = [SELECT Id, Name,Type_of_Procedure__c, ElixirSuite__Location__r.Name, ElixirSuite__Location__r.Id FROM ElixirSuite__Procedure__c WHERE ElixirSuite__Location__r.Id IN: locationIds AND RecordTypeId =: recordTypId WITH SECURITY_ENFORCED];
        
        Map<String, String> locationToName = new Map<String, String>();
        Map<String, String> locationToProcedureType = new Map<String, String>(); //addded by sivasai
        for(ElixirSuite__Procedure__c pro : procedureOfLocation){
            locationToName.put(pro.ElixirSuite__Location__r.Id, pro.Name);
            locationToProcedureType.put(pro.ElixirSuite__Location__r.Id, pro.Type_of_Procedure__c);
        }
        
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Procedure__c.getRecordTypeInfosByDeveloperName().get('Patient_Procedure').getRecordTypeId();
        
        List<Procedure__c> todaysProcedures = [SELECT Id, Name, Account__c, Location__c 
                                               FROM Procedure__c
                                               WHERE Account__c IN: accIds AND DAY_ONLY(CreatedDate) =: dateFilter
                                               AND Location__c!=NULL
                                               WITH SECURITY_ENFORCED];
        Set<String> locations = new Set<String>();
        
        if(todaysProcedures!=null && todaysProcedures.size()>0){
            for(Procedure__c procedure : todaysProcedures){
                if(accountToProcedure.containsKey(procedure.Account__c)){
                    accountToProcedure.get(procedure.Account__c).add(procedure.location__c);
                }else{
                    accountToProcedure.put(procedure.Account__c, new Set<Id>{procedure.location__c});
                }         
            }
        }        
        
        List<ElixirSuite__Procedure__c> procedureList = new List<ElixirSuite__Procedure__c>();
        for(ElixirSuite__Reservation_line_item__c item : lineItems){
            String patientId = item.Reservation__r.Account__c;
            if(accountToProcedure!=null && accountToProcedure.containsKey(patientId))
            {
                Set<Id> proceduredLocations = accountToProcedure.get(item.Reservation__r.Account__c);
                if(item.Suite__c != null && proceduredLocations.contains(item.Suite__c)){
                    continue;
                }
                if(item.Room__c != null && proceduredLocations.contains(item.Room__c)){
                    continue;                     
                }
                if(item.Bed__c != null  && proceduredLocations.contains(item.Bed__c)){
                    continue;                   
                }
            }
            else{
                ElixirSuite__Procedure__c procedure = new ElixirSuite__Procedure__c();
                procedure.RecordTypeId = recordTypeId;
                procedure.Account__c = patientId;
                if(item.Id != null){
                procedure.ElixirSuite__Reservation_Line_Item__c = item.Id; 
                }
                if(item.Suite__c != null){
                    procedure.Location__c = item.Suite__c;
                    procedure.Name = locationToName.get(item.Suite__c);
                    procedure.Type_of_Procedure__c =locationToProcedureType.get(item.Suite__c);
                }
                if(item.Room__c != null){
                    procedure.Location__c = item.Room__c;
                    procedure.Name = locationToName.get(item.Room__c);
                    procedure.Type_of_Procedure__c =locationToProcedureType.get(item.Room__c);                    
                }
                if(item.Bed__c != null){
                    procedure.Location__c = item.Bed__c;
                    procedure.Name = locationToName.get(item.Bed__c);
                    procedure.Type_of_Procedure__c =locationToProcedureType.get(item.Bed__c);                   
                }
                procedure.Charges__c = item.Unit_Price__c;
                procedure.From_Date_of_Service__c = System.now();
                procedure.To_Date_of_Service__c = System.now(); 
                //procedure.Type_of_Procedure__c = 'Private Payment';
                procedure.Is_Billable__c = true;
                procedureList.add(procedure);
            }
            
        }
        if(procedureList.size()>0){
           // insert procedureList;
           DMLManager.insertAsUser(procedureList);
            }        
    }
    
    public void finish(Database.BatchableContext bc) {}
}