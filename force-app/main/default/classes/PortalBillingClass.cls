public without sharing class PortalBillingClass {
    @AuraEnabled(cacheable=true)
    public static list<DisplayBillingDetailWrap> displayBillingDetail(Id userId){
        list<DisplayBillingDetailWrap> lstDbw = new list<DisplayBillingDetailWrap>();
        list<User> u  = Database.query('SELECT id,ContactId,AccountId FROM User WHERE Id =:userId');
        if(u != null && !u.isEmpty()){

            //initialize variables
            Map<Id,List<ElixirSuite__Payment_Transaction__c>> mapPrivatePayment = new Map<Id,List<ElixirSuite__Payment_Transaction__c>>();
            Map<Id,List<ElixirSuite__Payment_Transaction__c>> mapInsurancePayment = new Map<Id,List<ElixirSuite__Payment_Transaction__c>>();
            Map<Id,Event> mapAppointment = new Map<Id,Event>();
            Map<Id,ElixirSuite__Procedure__c> mapProc = new Map<Id,ElixirSuite__Procedure__c>();
            Map<Id, List<ElixirSuite__Claim__c>> mapVisitClaim = new Map<Id, List<ElixirSuite__Claim__c>>();
            Map<Id, List<ElixirSuite__Claim_Line_Items__c>> mapClaimAndLineItem = new Map<Id, List<ElixirSuite__Claim_Line_Items__c>>();
            List<String> appointmentType = new List<String>();
            Set<Id> procIds = new Set<Id>();

            String patientId= (String)u[0].get('AccountId');
            Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
            String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
            if(string.isBlank(careFilter)){
                careFilter = 'createddate desc';
            }
            String careStatus = 'Closed';
            
            string querystr = '';
            querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c,Name,ElixirSuite__Care_Episode_Location__r.Name,ElixirSuite__Account__r.Name,ElixirSuite__Account__r.ElixirSuite__MRN_Number_New__c,createddate from ElixirSuite__Visits__c where ElixirSuite__Status__c =: careStatus AND ElixirSuite__Account__c =: patientId WITH SECURITY_ENFORCED order by ';
            querystr += careFilter ;
            List<ElixirSuite__Visits__c> lstOfVisit = database.query(querystr);
            
            //map of visits
            Map<Id,ElixirSuite__Visits__c> mapVisit = new Map<Id,ElixirSuite__Visits__c>(lstOfVisit);
            
            List<Event> lstEvent = [SELECT Id,ElixirSuite__Appointment_Type__c,ElixirSuite__Care_Episode__c,ElixirSuite__Practitioner__r.Name,WhatId,StartDateTime FROM Event WHERE ElixirSuite__Care_Episode__c IN : mapVisit.keySet() WITH SECURITY_ENFORCED];

            //for appointment..if any care episode created from appointment..
            for(Event e : lstEvent){
                appointmentType.add(e.ElixirSuite__Appointment_Type__c);
                mapAppointment.put(e.ElixirSuite__Care_Episode__c,e);
            }
            List<ElixirSuite__Procedure__c> lstProc = [SELECT Id,Name,ElixirSuite__Code_Description__c,ElixirSuite__Visits__c from ElixirSuite__Procedure__c where Name IN : appointmentType WITH SECURITY_ENFORCED];

            for(ElixirSuite__Procedure__c proc : lstProc){
                mapProc.put(proc.ElixirSuite__Visits__c,proc);
            }

            //fetch all claims related to care episode/visits
            Map<Id,ElixirSuite__Claim__c> mapOfClaims = new Map<Id,ElixirSuite__Claim__c>([SELECT Id,ElixirSuite__Visits__c,ElixirSuite__Posted__c FROM ElixirSuite__Claim__c WHERE ElixirSuite__Visits__c IN : mapVisit.keySet()]);

            //for visit and claim
            for(ElixirSuite__Claim__c cl : mapOfClaims.values()){
                if(mapVisitClaim.containsKey(cl.ElixirSuite__Visits__c)){
                    mapVisitClaim.get(cl.ElixirSuite__Visits__c).add(cl);
                }
                else{
                    mapVisitClaim.put(cl.ElixirSuite__Visits__c,new List<ElixirSuite__Claim__c>{cl});
                }
            }

            //fetch all claim line items related to claims
            Map<Id,	ElixirSuite__Claim_Line_Items__c> mapOfClaimLineItems = new Map<Id,ElixirSuite__Claim_Line_Items__c>([SELECT Id,ElixirSuite__Procedure__c,ElixirSuite__Claim__c FROM ElixirSuite__Claim_Line_Items__c WHERE ElixirSuite__Claim__c IN : mapOfClaims.keySet()]);

            //for claim and claim line item
            for(ElixirSuite__Claim_Line_Items__c clLineItem : mapOfClaimLineItems.values()){
                procIds.add(clLineItem.ElixirSuite__Procedure__c); //store procedure Ids

                if(mapClaimAndLineItem.containsKey(clLineItem.ElixirSuite__Claim__c)){
                    mapClaimAndLineItem.get(clLineItem.ElixirSuite__Claim__c).add(clLineItem);
                }
                else{
                    mapClaimAndLineItem.put(clLineItem.ElixirSuite__Claim__c,new List<ElixirSuite__Claim_Line_Items__c>{clLineItem});
                }
            }

            //based on procIds fetch all the payment transaction
            List<ElixirSuite__Payment_Transaction__c> lstPtInsurance = [SELECT ID,ElixirSuite__Account__c,ElixirSuite__Actual_Price__c,ElixirSuite__Insurance_Payments__c,ElixirSuite__Secondary_Insurance_Paid__c,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Insurance_Paid__c,ElixirSuite__PatientOutstanding__c,ElixirSuite__Procedure__r.ElixirSuite__Visits__c,ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c,ElixirSuite__Procedure__c  from ElixirSuite__Payment_Transaction__c where ElixirSuite__Procedure__c  IN : procIds AND ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c = 'Insurance Payment' WITH SECURITY_ENFORCED];

            //for procedure and insurance payment
            for(ElixirSuite__Payment_Transaction__c payment : lstPtInsurance){
                if(mapInsurancePayment.containsKey(payment.ElixirSuite__Procedure__c)){
                    mapInsurancePayment.get(payment.ElixirSuite__Procedure__c).add(payment);
                }
                else{
                    List<ElixirSuite__Payment_Transaction__c> insurancePT = new List<ElixirSuite__Payment_Transaction__c>();
                    insurancePT.add(payment);
                    mapInsurancePayment.put(payment.ElixirSuite__Procedure__c,insurancePT);
                }
            }

            //based on visit ids fetch all the payment transaction through procedure
            List<ElixirSuite__Payment_Transaction__c> lstPtPrivate = [SELECT ID,ElixirSuite__Account__c,ElixirSuite__Actual_Price__c,ElixirSuite__Insurance_Payments__c,ElixirSuite__Secondary_Insurance_Paid__c,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Insurance_Paid__c,ElixirSuite__PatientOutstanding__c,ElixirSuite__Procedure__r.ElixirSuite__Visits__c,ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c  from ElixirSuite__Payment_Transaction__c where ElixirSuite__Procedure__r.ElixirSuite__Visits__c  IN : mapVisit.keySet() AND ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c = 'Private Payment' WITH SECURITY_ENFORCED];

            //for visit and private payment
            for(ElixirSuite__Payment_Transaction__c payment : lstPtPrivate){
                if(mapPrivatePayment.containsKey(payment.ElixirSuite__Procedure__r.ElixirSuite__Visits__c)){
                    mapPrivatePayment.get(payment.ElixirSuite__Procedure__r.ElixirSuite__Visits__c).add(payment);
                }
                else{
                    List<ElixirSuite__Payment_Transaction__c> privatePT = new List<ElixirSuite__Payment_Transaction__c>();
                    privatePT.add(payment);
                    mapPrivatePayment.put(payment.ElixirSuite__Procedure__r.ElixirSuite__Visits__c,privatePT);
                }
            }

            //collect all the transaction for private and insurance payments
            for(Id visitId : mapVisit.keySet()){

                //collect payment for private based on visits....
                if(mapPrivatePayment.containsKey(visitId)){
                    Decimal totalCharges = 0;
                    Decimal patientPaid = 0;
                    Decimal insurancePaid = 0;
                    Decimal remainingCharges = 0;

                    for(ElixirSuite__Payment_Transaction__c ptPvt : mapPrivatePayment.get(visitId)){
                        totalCharges += ptPvt.ElixirSuite__Actual_Price__c;
                        patientPaid += ptPvt.ElixirSuite__Total_Paid_Amount__c;
                        remainingCharges += ptPvt.ElixirSuite__PatientOutstanding__c;
                    }
                    if(mapAppointment.containsKey(visitId)){
                       lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),'$'+String.valueOf(insurancePaid),'$'+String.valueOf(remainingCharges),'Private',mapAppointment.get(visitId),mapProc.get(visitId)));
                    }
                    else{
                        lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),'$'+String.valueOf(insurancePaid),'$'+String.valueOf(remainingCharges),'Private',null,null));
                    }
                    
                }
                //collect payment for insurance based on claim....
                if(mapVisitClaim.containsKey(visitId)){  
                    for(ElixirSuite__Claim__c claim : mapVisitClaim.get(visitId)){
                        Decimal totalCharges = 0;
                        Decimal patientPaid = 0;
                        Decimal insurancePaid = 0;
                        Decimal remainingCharges = 0;

                        if(mapClaimAndLineItem.containsKey(claim.Id)){
                            for(ElixirSuite__Claim_Line_Items__c lineItem : mapClaimAndLineItem.get(claim.Id)){
                                if(mapInsurancePayment.containsKey(lineItem.ElixirSuite__Procedure__c)){
                                    for(ElixirSuite__Payment_Transaction__c ptIns : mapInsurancePayment.get(lineItem.ElixirSuite__Procedure__c)){
                                        totalCharges += ptIns.ElixirSuite__Actual_Price__c;
                                        insurancePaid += ptIns.ElixirSuite__Insurance_Paid__c + ptIns.ElixirSuite__Secondary_Insurance_Paid__c;
                                        remainingCharges += ptIns.ElixirSuite__PatientOutstanding__c;
                                        patientPaid += ptIns.ElixirSuite__Total_Paid_Amount__c;
                                    }
                                }
                            }
                        }
                        if(mapAppointment.containsKey(visitId)){
                            if(claim.ElixirSuite__Posted__c == FALSE){
                                lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),'Pending','Pending','Insurance',mapAppointment.get(visitId),mapProc.get(visitId)));
                            }
                            else{
                                lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),insurancePaid != 0 ? '-$'+String.valueOf(insurancePaid) : '$'+String.valueOf(insurancePaid),'$'+String.valueOf(remainingCharges),'Insurance',mapAppointment.get(visitId),mapProc.get(visitId)));
                            }
                        }
                        else{
                            if(claim.ElixirSuite__Posted__c == FALSE){
                                lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),'Pending','Pending','Insurance',null,null));
                            }
                            else{
                                lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),insurancePaid != 0 ? '-$'+String.valueOf(insurancePaid) : '$'+String.valueOf(insurancePaid),'$'+String.valueOf(remainingCharges),'Insurance',null,null));
                            }
                        }
                    } 
                }
            }   
        }
        return lstDbw;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<DisplayBillingDetailWrap> searchVisit(Date fromDate, Date toDate, Id userId){
        list<DisplayBillingDetailWrap> lstDbw = new list<DisplayBillingDetailWrap>();
        list<User> u  = Database.query('SELECT id,ContactId,AccountId FROM User WHERE Id =:userId');

        if(u != null && !u.isEmpty()){
            //initialize variables
            Map<Id,List<ElixirSuite__Payment_Transaction__c>> mapPrivatePayment = new Map<Id,List<ElixirSuite__Payment_Transaction__c>>();
            Map<Id,List<ElixirSuite__Payment_Transaction__c>> mapInsurancePayment = new Map<Id,List<ElixirSuite__Payment_Transaction__c>>();
            Map<Id,Event> mapAppointment = new Map<Id,Event>();
            Map<Id,ElixirSuite__Procedure__c> mapProc = new Map<Id,ElixirSuite__Procedure__c>();
            Map<Id, List<ElixirSuite__Claim__c>> mapVisitClaim = new Map<Id, List<ElixirSuite__Claim__c>>();
            Map<Id, List<ElixirSuite__Claim_Line_Items__c>> mapClaimAndLineItem = new Map<Id, List<ElixirSuite__Claim_Line_Items__c>>();
            List<String> appointmentType = new List<String>();
            Set<Id> procIds = new Set<Id>();

            String patientId= (String)u[0].get('AccountId');
            Elixir_Custom_Setting__c customSetting = Elixir_Custom_Setting__c.getOrgDefaults();
            String careFilter = customSetting.ElixirSuite__Default_Active_Care_Episode_Filter__c;
            if(string.isBlank(careFilter)){
                careFilter = 'createddate desc';
            }
            String careStatus = 'Closed';
            
            string querystr = '';
            querystr += 'Select Id,ElixirSuite__Account__c,ElixirSuite__Status__c,Name,ElixirSuite__Care_Episode_Location__r.Name,ElixirSuite__Account__r.Name,ElixirSuite__Account__r.ElixirSuite__MRN_Number_New__c,createddate from ElixirSuite__Visits__c where ElixirSuite__Status__c =: careStatus AND ElixirSuite__Account__c =: patientId AND (CreatedDate >= : fromDate AND CreatedDate <= : toDate) WITH SECURITY_ENFORCED order by ';
            querystr += careFilter ;
            List<ElixirSuite__Visits__c> lstOfVisit = database.query(querystr);
            
            //map of visits
            Map<Id,ElixirSuite__Visits__c> mapVisit = new Map<Id,ElixirSuite__Visits__c>(lstOfVisit);
            
            List<Event> lstEvent = [SELECT Id,ElixirSuite__Appointment_Type__c,ElixirSuite__Care_Episode__c,ElixirSuite__Practitioner__r.Name,WhatId,StartDateTime FROM Event WHERE ElixirSuite__Care_Episode__c IN : mapVisit.keySet() WITH SECURITY_ENFORCED];

            //for appointment..if any care episode created from appointment..
            for(Event e : lstEvent){
                appointmentType.add(e.ElixirSuite__Appointment_Type__c);
                mapAppointment.put(e.ElixirSuite__Care_Episode__c,e);
            }
            List<ElixirSuite__Procedure__c> lstProc = [SELECT Id,Name,ElixirSuite__Code_Description__c,ElixirSuite__Visits__c from ElixirSuite__Procedure__c where Name IN : appointmentType WITH SECURITY_ENFORCED];

            for(ElixirSuite__Procedure__c proc : lstProc){
                mapProc.put(proc.ElixirSuite__Visits__c,proc);
            }

            //fetch all claims related to care episode/visits
            Map<Id,ElixirSuite__Claim__c> mapOfClaims = new Map<Id,ElixirSuite__Claim__c>([SELECT Id,ElixirSuite__Visits__c,ElixirSuite__Posted__c FROM ElixirSuite__Claim__c WHERE ElixirSuite__Visits__c IN : mapVisit.keySet()]);

            //for visit and claim
            for(ElixirSuite__Claim__c cl : mapOfClaims.values()){
                if(mapVisitClaim.containsKey(cl.ElixirSuite__Visits__c)){
                    mapVisitClaim.get(cl.ElixirSuite__Visits__c).add(cl);
                }
                else{
                    mapVisitClaim.put(cl.ElixirSuite__Visits__c,new List<ElixirSuite__Claim__c>{cl});
                }
            }

            //fetch all claim line items related to claims
            Map<Id,	ElixirSuite__Claim_Line_Items__c> mapOfClaimLineItems = new Map<Id,ElixirSuite__Claim_Line_Items__c>([SELECT Id,ElixirSuite__Procedure__c,ElixirSuite__Claim__c FROM ElixirSuite__Claim_Line_Items__c WHERE ElixirSuite__Claim__c IN : mapOfClaims.keySet()]);

            //for claim and claim line item
            for(ElixirSuite__Claim_Line_Items__c clLineItem : mapOfClaimLineItems.values()){
                procIds.add(clLineItem.ElixirSuite__Procedure__c); //store procedure Ids

                if(mapClaimAndLineItem.containsKey(clLineItem.ElixirSuite__Claim__c)){
                    mapClaimAndLineItem.get(clLineItem.ElixirSuite__Claim__c).add(clLineItem);
                }
                else{
                    mapClaimAndLineItem.put(clLineItem.ElixirSuite__Claim__c,new List<ElixirSuite__Claim_Line_Items__c>{clLineItem});
                }
            }

            //based on procIds fetch all the payment transaction
            List<ElixirSuite__Payment_Transaction__c> lstPtInsurance = [SELECT ID,ElixirSuite__Account__c,ElixirSuite__Actual_Price__c,ElixirSuite__Insurance_Payments__c,ElixirSuite__Secondary_Insurance_Paid__c,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Insurance_Paid__c,ElixirSuite__PatientOutstanding__c,ElixirSuite__Procedure__r.ElixirSuite__Visits__c,ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c,ElixirSuite__Procedure__c  from ElixirSuite__Payment_Transaction__c where ElixirSuite__Procedure__c  IN : procIds AND ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c = 'Insurance Payment' WITH SECURITY_ENFORCED];

            //for procedure and insurance payment
            for(ElixirSuite__Payment_Transaction__c payment : lstPtInsurance){
                if(mapInsurancePayment.containsKey(payment.ElixirSuite__Procedure__c)){
                    mapInsurancePayment.get(payment.ElixirSuite__Procedure__c).add(payment);
                }
                else{
                    List<ElixirSuite__Payment_Transaction__c> insurancePT = new List<ElixirSuite__Payment_Transaction__c>();
                    insurancePT.add(payment);
                    mapInsurancePayment.put(payment.ElixirSuite__Procedure__c,insurancePT);
                }
            }

            //based on visit ids fetch all the payment transaction through procedure
            List<ElixirSuite__Payment_Transaction__c> lstPtPrivate = [SELECT ID,ElixirSuite__Account__c,ElixirSuite__Actual_Price__c,ElixirSuite__Insurance_Payments__c,ElixirSuite__Secondary_Insurance_Paid__c,ElixirSuite__Total_Paid_Amount__c,ElixirSuite__Insurance_Paid__c,ElixirSuite__PatientOutstanding__c,ElixirSuite__Procedure__r.ElixirSuite__Visits__c,ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c  from ElixirSuite__Payment_Transaction__c where ElixirSuite__Procedure__r.ElixirSuite__Visits__c  IN : mapVisit.keySet() AND ElixirSuite__Procedure__r.ElixirSuite__Type_of_Procedure__c = 'Private Payment' WITH SECURITY_ENFORCED];

            //for visit and private payment
            for(ElixirSuite__Payment_Transaction__c payment : lstPtPrivate){
                if(mapPrivatePayment.containsKey(payment.ElixirSuite__Procedure__r.ElixirSuite__Visits__c)){
                    mapPrivatePayment.get(payment.ElixirSuite__Procedure__r.ElixirSuite__Visits__c).add(payment);
                }
                else{
                    List<ElixirSuite__Payment_Transaction__c> privatePT = new List<ElixirSuite__Payment_Transaction__c>();
                    privatePT.add(payment);
                    mapPrivatePayment.put(payment.ElixirSuite__Procedure__r.ElixirSuite__Visits__c,privatePT);
                }
            }

            //collect all the transaction for private and insurance payments
            for(Id visitId : mapVisit.keySet()){

                //collect payment for private based on visits....
                if(mapPrivatePayment.containsKey(visitId)){
                    Decimal totalCharges = 0;
                    Decimal patientPaid = 0;
                    Decimal insurancePaid = 0;
                    Decimal remainingCharges = 0;

                    for(ElixirSuite__Payment_Transaction__c ptPvt : mapPrivatePayment.get(visitId)){
                        totalCharges += ptPvt.ElixirSuite__Actual_Price__c;
                        patientPaid += ptPvt.ElixirSuite__Total_Paid_Amount__c;
                        remainingCharges += ptPvt.ElixirSuite__PatientOutstanding__c;
                    }
                    if(mapAppointment.containsKey(visitId)){
                       lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),'$'+String.valueOf(insurancePaid),'$'+String.valueOf(remainingCharges),'Private',mapAppointment.get(visitId),mapProc.get(visitId)));
                    }
                    else{
                        lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),'$'+String.valueOf(insurancePaid),'$'+String.valueOf(remainingCharges),'Private',null,null));
                    }
                    
                }
                //collect payment for insurance based on claim....
                if(mapVisitClaim.containsKey(visitId)){  
                    for(ElixirSuite__Claim__c claim : mapVisitClaim.get(visitId)){
                        Decimal totalCharges = 0;
                        Decimal patientPaid = 0;
                        Decimal insurancePaid = 0;
                        Decimal remainingCharges = 0;

                        if(mapClaimAndLineItem.containsKey(claim.Id)){
                            for(ElixirSuite__Claim_Line_Items__c lineItem : mapClaimAndLineItem.get(claim.Id)){
                                if(mapInsurancePayment.containsKey(lineItem.ElixirSuite__Procedure__c)){
                                    for(ElixirSuite__Payment_Transaction__c ptIns : mapInsurancePayment.get(lineItem.ElixirSuite__Procedure__c)){
                                        totalCharges += ptIns.ElixirSuite__Actual_Price__c;
                                        insurancePaid += ptIns.ElixirSuite__Insurance_Paid__c + ptIns.ElixirSuite__Secondary_Insurance_Paid__c;
                                        remainingCharges += ptIns.ElixirSuite__PatientOutstanding__c;
                                        patientPaid += ptIns.ElixirSuite__Total_Paid_Amount__c;
                                    }
                                }
                            }
                        }
                        if(mapAppointment.containsKey(visitId)){
                            if(claim.ElixirSuite__Posted__c == FALSE){
                                lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),'Pending','Pending','Insurance',mapAppointment.get(visitId),mapProc.get(visitId)));
                            }
                            else{
                                lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),insurancePaid != 0 ? '-$'+String.valueOf(insurancePaid) : '$'+String.valueOf(insurancePaid),'$'+String.valueOf(remainingCharges),'Insurance',mapAppointment.get(visitId),mapProc.get(visitId)));
                            }                        }
                        else{
                            if(claim.ElixirSuite__Posted__c == FALSE){
                                lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),'Pending','Pending','Insurance',null,null));
                            }
                            else{
                                lstDbw.add(new DisplayBillingDetailWrap((mapVisit.get(visitId)),totalCharges,patientPaid != 0 ? '-$'+String.valueOf(patientPaid) : '$'+String.valueOf(patientPaid),insurancePaid != 0 ? '-$'+String.valueOf(insurancePaid) : '$'+String.valueOf(insurancePaid),'$'+String.valueOf(remainingCharges),'Insurance',null,null));
                            }
                        }
                    } 
                }
            }   
        }
        return lstDbw;
    }
    
    public class DisplayBillingDetailWrap{
        @AuraEnabled public ElixirSuite__Visits__c lstVisits;
        @AuraEnabled public String payer;
        @AuraEnabled public Decimal totalCharges;
        @AuraEnabled public String patientPaid;
        @AuraEnabled public String insurancePaid;
        @AuraEnabled public String remainingCharges;
        @AuraEnabled public Event events;
        @AuraEnabled public ElixirSuite__Procedure__c proc;
        public DisplayBillingDetailWrap(ElixirSuite__Visits__c visits,Decimal tc, String pp, String ip, String rc, String payer,Event events,ElixirSuite__Procedure__c proc){
            this.lstVisits = visits;
            this.totalCharges = tc;
            this.patientPaid = pp;
            this.insurancePaid = ip;
            this.remainingCharges = rc;
            this.payer = payer;
            this.events = events;
            this.proc = proc;
        }
        
    }
public class DisplayBillingTransactionWrap{
        @AuraEnabled public ElixirSuite__Transactions__c lstTransaction;
        @AuraEnabled public Boolean isCash;
        @AuraEnabled public Boolean isCard;
        @AuraEnabled public Boolean isCheque;

        public DisplayBillingTransactionWrap(ElixirSuite__Transactions__c trans,Boolean isCash,Boolean isCard,Boolean isCheque){
            this.lstTransaction = trans;
            this.isCash = isCash;
            this.isCard = isCard;
            this.isCheque = isCheque;
        }
        
    }
    
    public static String getPatientId() {
        String patientId='';
        String uId =UserInfo.getUserId();
        List<User> userRecs = Database.query('SELECT id,ContactId,AccountId FROM User WHERE Id =:uId');
        if(userRecs!=null && userRecs.size()>0){
            patientId = (String)userRecs[0].get('AccountId');
        }
        return patientId;
    }
    
    public class ProviderPaymentWrapper {
        @AuraEnabled public ElixirSuite__Visits__c episode;
        @AuraEnabled public List<ElixirSuite__Procedure__c> procedures;
        @AuraEnabled public ElixirSuite__Provider__c provider;
        @AuraEnabled public List<ElixirSuite__Payment_Transaction__c> paymentTransactions;
        @AuraEnabled public List<String> imageUrls;
        @AuraEnabled public Decimal totalRemainingAmount;
        @AuraEnabled public Account acc;
        @AuraEnabled public Account accDetails;
        
        
        public ProviderPaymentWrapper(Account accDetails,ElixirSuite__Provider__c provider, Decimal totalRemainingAmount,List<String> imageUrls) {
            //this.episode = episode;
            //this.procedures = procedures;
            //this.acc = acc;
            this.accDetails = accDetails;
            this.provider = provider;
            this.totalRemainingAmount = totalRemainingAmount;
            //this.paymentTransactions = paymentTransactions;
            this.imageUrls = imageUrls;
            
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ProviderPaymentWrapper> getProviderPaymentWrapper() {
        List<ProviderPaymentWrapper> providerPaymentWrappers = new List<ProviderPaymentWrapper>();
        
        // Retrieve the patientId based on the userId or your logic
        String patientId = getPatientId();//patientId 0011y00000faClLAAU
        Id problemRecType = Schema.SObjectType.ElixirSuite__Provider__c.getRecordTypeInfosByDeveloperName().get('Patient_Provider').getRecordTypeId();
        
        // Step 1: Retrieve Patient Care Episodes
        List<ElixirSuite__Visits__c> careEpisodes = [SELECT Id, Name,ElixirSuite__Account__c, ElixirSuite__Care_Episode_Location__c, ElixirSuite__Location_Address__c, ElixirSuite__Location__c, ElixirSuite__Status__c FROM ElixirSuite__Visits__c where ElixirSuite__Account__c =: patientId WITH SECURITY_ENFORCED ];
        Account accDetails = null;
        
        if (patientId != null) {
            accDetails = [SELECT Name, ElixirSuite__MRN_Number_New__c FROM Account WHERE Id = :patientId WITH SECURITY_ENFORCED];
        }
        
        // Step 2: Group Care Episodes
        Map<String, List<ElixirSuite__Visits__c>> groupedEpisodes = new Map<String, List<ElixirSuite__Visits__c>>();
        
        for (ElixirSuite__Visits__c episode : careEpisodes) {
            String location = episode.ElixirSuite__Care_Episode_Location__c;
            
            if (!groupedEpisodes.containsKey(location)) {
                groupedEpisodes.put(location, new List<ElixirSuite__Visits__c>());
            }
            
            groupedEpisodes.get(location).add(episode);
        }
        
        // Step 3: Select Associated Procedures
        Map<Id, List<ElixirSuite__Procedure__c>> episodeProcedures = new Map<Id, List<ElixirSuite__Procedure__c>>();
        Set<Id> episodeIds = new Set<Id>();
        
        // Collecting all Visit IDs
        for (ElixirSuite__Visits__c episode : careEpisodes) {
            episodeIds.add(episode.Id);
        }
        
        // Querying all procedures for the collected Visit IDs
        List<ElixirSuite__Procedure__c> allProcedures = [SELECT Id, ElixirSuite__Visits__c FROM ElixirSuite__Procedure__c WHERE ElixirSuite__Visits__c IN :episodeIds WITH SECURITY_ENFORCED];
        
        // Organizing procedures into the episodeProcedures map
        for (ElixirSuite__Procedure__c procedure : allProcedures) {
            if (!episodeProcedures.containsKey(procedure.ElixirSuite__Visits__c)) {
                episodeProcedures.put(procedure.ElixirSuite__Visits__c, new List<ElixirSuite__Procedure__c>());
            }
            
            episodeProcedures.get(procedure.ElixirSuite__Visits__c).add(procedure);
        }
        
        // Step 4: Retrieve Master Transactions
        Map<Id, List<ElixirSuite__Payment_Transaction__c>> episodeMasterTransactions = new Map<Id, List<ElixirSuite__Payment_Transaction__c>>();
        Map<Id, Decimal> totalOutstandingAmounts = new Map<Id, Decimal>();
        Set<Id> procedureIds = new Set<Id>();
        
        // Collecting all Procedure IDs
        for (ElixirSuite__Procedure__c procedure : allProcedures) {
            procedureIds.add(procedure.Id);
        }
        
        // Querying all Payment Transactions for the collected Procedure IDs
        // Querying all Payment Transactions for the collected Procedure IDs
        List<ElixirSuite__Payment_Transaction__c> allTransactions = [
            SELECT Id, ElixirSuite__Account__c, ElixirSuite__PatientOutstanding__c, ElixirSuite__Procedure__c
            FROM ElixirSuite__Payment_Transaction__c
            WHERE ElixirSuite__Procedure__c IN :procedureIds WITH SECURITY_ENFORCED
        ];
        
        // Map to store Procedure IDs and associated Visits
        Map<Id, Id> procedureToVisitMap = new Map<Id, Id>();
        for (ElixirSuite__Procedure__c procedure : [
            SELECT Id, ElixirSuite__Visits__c
            FROM ElixirSuite__Procedure__c
            WHERE Id IN :procedureIds WITH SECURITY_ENFORCED
        ]) {
            procedureToVisitMap.put(procedure.Id, procedure.ElixirSuite__Visits__c);
        }
        
        // Organizing transactions into the episodeMasterTransactions map
        for (ElixirSuite__Payment_Transaction__c transactions : allTransactions) {
            Id procedureId = transactions.ElixirSuite__Procedure__c;
            Id episodeId = procedureToVisitMap.get(procedureId);
            
            if (episodeId != null) {
                if (!episodeMasterTransactions.containsKey(episodeId)) {
                    episodeMasterTransactions.put(episodeId, new List<ElixirSuite__Payment_Transaction__c>());
                }
                
                episodeMasterTransactions.get(episodeId).add(transactions);
                
                Decimal outstanding = transactions.ElixirSuite__PatientOutstanding__c != null
                    ? transactions.ElixirSuite__PatientOutstanding__c
                    : 0;
                
                if (!totalOutstandingAmounts.containsKey(episodeId)) {
                    totalOutstandingAmounts.put(episodeId, 0);
                }
                
                totalOutstandingAmounts.put(episodeId, totalOutstandingAmounts.get(episodeId) + outstanding);
            }
        }
        List <Id> locationIdList = new List <Id>();
        List<String> imageUrls;
        for (String location : groupedEpisodes.keySet()){
            
            locationIdList.add(location);
        }
        Map<Id,ElixirSuite__Provider__c> providerMap =new Map<Id,ElixirSuite__Provider__c>([Select Id,Name,ElixirSuite__Account__r.Name,ElixirSuite__Account__r.ElixirSuite__MRN_Number_New__c from ElixirSuite__Provider__c where ID IN :locationIdList]);
        for(Id key : providerMap.keySet()) {
            ElixirSuite__Provider__c provider = providerMap.get(key);
            List<ElixirSuite__Visits__c> episodes = groupedEpisodes.get(key);
            Decimal allRemainingAmount = 0.00;
            imageUrls = getImageUrls(key);
            // Create a ProviderPaymentWrapper for each care episode
            for (ElixirSuite__Visits__c episode : episodes) {
                Id episodeId = episode.Id;
                
                // Get associated procedures and transactions
                //List<ElixirSuite__Procedure__c> procedures = episodeProcedures.get(episodeId);
                
                // Change the loop variable name from 'transactions' to 'episodeTransactions'
                //List<ElixirSuite__Payment_Transaction__c> paymentTransactions = episodeMasterTransactions.get(episodeId);
                
                // Get image URLs using the provided method
                
                if(totalOutstandingAmounts.get(episodeId) != null){
                    allRemainingAmount += totalOutstandingAmounts.get(episodeId);
                }
                
            }
            providerPaymentWrappers.add(new ProviderPaymentWrapper(accDetails,provider, allRemainingAmount, imageUrls));
            
        }
        return providerPaymentWrappers;
    }
    public static List<String> getImageUrls(String location) {
        List<String> imageUrls = new List<String>();
        
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        List<ContentDocumentLink> documentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: location AND ContentDocument.Title LIKE 'branding_%'];
        Set<id> docIds = new Set<id>(); 
        if(documentLinks != null && !documentLinks.isEmpty()){
            for(ContentDocumentLink cdl : documentLinks){
                docIds.add(cdl.ContentDocumentId);
            }
            list<ContentVersion> cv = [select id,VersionData,CreatedDate from ContentVersion where ContentDocumentId IN :docIds ORDER BY CreatedDate DESC];
            imageUrls.add('/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+cv[0].Id);
        }
        
        return imageUrls;
    }

    //Below methond is for test
    @AuraEnabled(cacheable=true)
    public static String getTransactions(Integer pageSize, Integer offset) {
        list<DisplayBillingTransactionWrap> lstBT = new list<DisplayBillingTransactionWrap>();
        String patientId = getPatientId();
        List<ElixirSuite__Transactions__c> lstTrans = [SELECT Id, Name,ElixirSuite__Amount_Paid__c,ElixirSuite__Payment_DateTime__c,ElixirSuite__Cheque_Number__c,ElixirSuite__Mode_of_Payment__c,ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c,ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Company__c FROM ElixirSuite__Transactions__c  WHERE ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c =: patientId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :offset];
        for(ElixirSuite__Transactions__c trans : lstTrans){
            if(trans.ElixirSuite__Mode_of_Payment__c == 'Cash'){
                lstBT.add(new DisplayBillingTransactionWrap(trans,true,false,false));
            }
            else if(trans.ElixirSuite__Mode_of_Payment__c == 'Credit Card'){
                lstBT.add(new DisplayBillingTransactionWrap(trans,false,true,false));
            }
            else if(trans.ElixirSuite__Mode_of_Payment__c == 'Cheque'){
                String chequeNo = trans.ElixirSuite__Cheque_Number__c;
                trans.ElixirSuite__Cheque_Number__c = String.isNotEmpty(trans.ElixirSuite__Cheque_Number__c) ? chequeNo.substring(chequeNo.length() - 4) : trans.ElixirSuite__Cheque_Number__c;
                lstBT.add(new DisplayBillingTransactionWrap(trans,false,false,true));
            }
        }
        return JSON.serialize(lstBT);
    }

    @AuraEnabled(cacheable=true)
    public static String searchTransaction(Date fromDate, Date toDate) {
        list<DisplayBillingTransactionWrap> lstBT = new list<DisplayBillingTransactionWrap>();
        String patientId = getPatientId();
        List<ElixirSuite__Transactions__c> lstTrans = [SELECT Id, Name,ElixirSuite__Amount_Paid__c,ElixirSuite__Payment_DateTime__c,
                                                       ElixirSuite__Cheque_Number__c,ElixirSuite__Mode_of_Payment__c,
                                                       ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c,
                                                       ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Company__c 
                                                       FROM ElixirSuite__Transactions__c 
                                                       WHERE (ElixirSuite__Payment_DateTime__c >=: fromDate AND 
                                                       ElixirSuite__Payment_DateTime__c <=: toDate) AND 
                                                       ElixirSuite__Master_Transaction__r.ElixirSuite__Account__c =: patientId
                                                       WITH SECURITY_ENFORCED
                                                       ORDER BY ElixirSuite__Payment_DateTime__c ASC];
        for(ElixirSuite__Transactions__c trans : lstTrans){
            if(trans.ElixirSuite__Mode_of_Payment__c == 'Cash'){
                lstBT.add(new DisplayBillingTransactionWrap(trans,true,false,false));
            }
            else if(trans.ElixirSuite__Mode_of_Payment__c == 'Credit Card'){
                lstBT.add(new DisplayBillingTransactionWrap(trans,false,true,false));
            }
            else if(trans.ElixirSuite__Mode_of_Payment__c == 'Cheque'){
                String chequeNo = trans.ElixirSuite__Cheque_Number__c;
                trans.ElixirSuite__Cheque_Number__c = String.isNotEmpty(trans.ElixirSuite__Cheque_Number__c) ? chequeNo.substring(chequeNo.length() - 4) : trans.ElixirSuite__Cheque_Number__c;
                lstBT.add(new DisplayBillingTransactionWrap(trans,false,false,true));
            }
        }
        return JSON.serialize(lstBT);
    }
}