public class Hl7Message {

    public mshHl7 msh;
    public pidHl7 pid;
    public pv1Hl7 pv1;
    public orcHl7 orc;
    public List<obrHl7> obr;
    public tq1Hl7 tq1;
    public spmHl7 spm;
    
    public Hl7Message(){
        msh=new mshHl7();
        pid=new pidHl7();
        pv1=new pv1Hl7();
        orc=new orcHl7();
        obr= new List<obrHl7>();
        tq1=new tq1Hl7();
        spm=new spmHl7();
        
    }
  
    //MSH-Message Header - required, non-repeating
	public class MshHl7 {
    
 		public String sendingApplication;
 		public String sendingFacility;
 		public String receivingApplication;
 		public String receivingFacility;
 		public String dateTimeofMessage;
 		public String messageType; 
 		public String messageControlID;
 		public String processingID;
    	public String versionID;

	}
    //Patient Identification - required, non-repeating
	public class PidHl7 {
    
    	public String setID;
 		public String patientID;
 		public String patientIdentifierList;
 		public String patientName;
 		public String dateofBirth;
 		public String sex;
 		public String patientAddress;
 		public String phoneNumberHome;
    	public String ssnPatient;
    	public List<NTEHl7> nTE;
    	public pidHl7(){
     		NTE=new List<nteHl7>();  
   		}
	}
    //Patient Visit - optional, non-repeating
	public class Pv1Hl7 {
       public integer containInfo=0;   
       public String setID;
       public String patientClass;
       public String attendingPhysician;
       public String referringPhysician;
       public String consultingPhysician;
       public String admittingPhysician;
       public String encounterID;
       public String primaryPhysician;
           
                 
	}
    
    //Common Order - optional, non-repeating
	public class OrcHl7 {
        public integer containInfo=0;
        public String orderControl;
        public String placerOrderNumber;
        public String fillerOrderNumber;
        public String orderStatus;
        public String dateTimeofTransaction;
        public String orderingProvider;
	}
    
    //Timing/Quantity - optional, non-repeating
	public class Tq1Hl7 {
    
    	public integer containInfo=0;
    	public String setID;
    	public String quantity;
    	public String relativeTimeandUnits;
    	public String serviceDuration;
    	public String startdatetime;
    	public String enddatetime;
    	public String occurrenceduration;
    
	}
    //SPM-Specimen - optional, non-repeating
	public class SpmHl7 {
        public integer containInfo=0; 
		public String setID;
        public String specimenID;
        public String specimenType;
        public String specimenSourceSite;
        public String specimenCollectionSite;
                        
	}
    //Observation Request - required, repeating as block 1
	public class ObrHl7 {
       public String setID;
       public String placerOrderNumber;
       public String fillerOrderNumber;
       public String universalServiceID;
       public String observationDateTime;
       public String specimenReceivedDateTime;
       public String specimenSource;
       public String orderingProvider;
       public String resultsRptStatusChangeDateTime;
       public String diagnosticServSectID;
       public String resultStatus;
       public String parentResult;
       public String quantityTiming;
       public String parent;
       public String reasonforStudy;
       public List<nteHl7> nTE;
       public List<obxHl7> obx;
       
        public obrHl7(){
        
        	NTE=new List<nteHl7>(); 
        	obx=new List<obxHl7>();
    	} 
	}
    //Laboratory Report comments – optional, repeating
	public class NteHl7 {
       
       public String setID;
       public String sourceofComment; 
       public String comment;
         
	}
  
   //Observation Result - required, repeating as block 2
	public class ObxHl7 {

        public String setID;
        public String valueType;
        public String observationIdentifier;
        public String observationSubID;
        public String observationValue;
        public String units;
        public String referencesRange; 
        public String abnormalFlags;
        public String observResultStatus; 
        public String dateTimeoftheObservation;
        public String producerID;
        public Integer obrSetNo;
        public List<nteHl7> nTE;
        public obxHl7(){
            NTE=new List<nteHl7>();
        } 
	}
    
}