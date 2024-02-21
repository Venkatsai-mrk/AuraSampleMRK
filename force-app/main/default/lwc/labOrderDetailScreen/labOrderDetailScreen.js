import { LightningElement, api, track, wire } from 'lwc';
import getLabOrderDetails from '@salesforce/apex/LabOrderDetails.getLabOrderDetails';
import addNote from '@salesforce/apex/LabOrderDetails.addNote';
import getLabs from '@salesforce/apex/OrderAPICallouts.getLabs';
import getFacilities from '@salesforce/apex/OrderAPICallouts.getFacilities';
import getPhysicians from '@salesforce/apex/LabOrderDetails.getPhysicians';
import getTests from '@salesforce/apex/LabOrderDetails.getTests';
import getICDs from '@salesforce/apex/LabOrderDetails.getICDs';
import getTestResultsTextLWC from '@salesforce/apex/LabOrderDetails.getTestResultsTextLWC';
import My_Resource from '@salesforce/resourceUrl/Result_CHC';
import My_Resource_Image from '@salesforce/resourceUrl/ResultImageCHC';
import { refreshApex } from '@salesforce/apex';
import { publish, MessageContext } from 'lightning/messageService';
import {subscribe,unsubscribe} from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchRecordIdMC from '@salesforce/messageChannel/FetchLabRecordId__c';
import fetchIsPrintMC from '@salesforce/messageChannel/FetchLabIsPrint__c';
import getPatientId from '@salesforce/apex/LabOrderDetails.getPatientId';

const testColumns = [
    { label: 'Test Id', fieldName: 'ElixirSuite__Test_Id__c' , hideDefaultActions : 'true'},
    { label: 'Test Name', fieldName: 'ElixirSuite__Test_Name__c', hideDefaultActions : 'true' },
];
const icdColumns = [
    { label: 'ICD Id', fieldName: 'Name' , hideDefaultActions : 'true'},
    { label: 'ICD Name', fieldName: 'ElixirSuite__Code_Description1__c', hideDefaultActions : 'true' },
];
const notesColumns = [
    { label: 'Name', fieldName: 'ElixirSuite__Test_Result_Detail_Name__c' , hideDefaultActions : 'true' },
{ label: 'Observations', fieldName: 'ElixirSuite__Observation_Value_Text__c' , hideDefaultActions : 'true' },

];
export default class LabOrderDetailScreen extends LightningElement {
    //value for this rid will get from grid
    @track nameSpace='ElixirSuite__'
    columns = testColumns;
    columnsIcd = icdColumns;
    notesColumn = notesColumns;
    //tdata = data;
    @track TestTextData;
    @track add_note = false;
    @api rid;
     @api activetabdetail;
    @track
    data;
    @track
    error;
    @track 
    lab;
    @track
    labs= [];
    @track 
    physician;
    @track
    Physicians;
    @track 
    collectionTime;
   @track 
    test = [];
    @track
    tests = [];
     @track 
    icd = [];
    @track
    ICDs = [];
    @track 
    facility;
    @track
    facilities = [];
    @ track
    doctorNote  ;
    @track
     titleNote;
    @track
    OrderId;
    @track
    expectedTime;
    @track
    isPSC = false;
     myVal = My_Resource ;
     ecgImg = My_Resource_Image;
     refreshNote;
     refreshTable;
     accountId;
     @track isNewButtonVisible = true;
     @track orderingPhysicianValue = '';
  @wire(getLabOrderDetails,{recordId : "$rid" })
  LabOrder(result) {
      this.refreshTable = result;
       window.console.log(result.data);
    if (result.data) {
        console.log('lab: ' +JSON.stringify(result.data));
        //window.console.log(result.data);
        console.log('result.data.ElixirSuite__Lab_Order_Req__c '+result.data.ElixirSuite__Lab_Order_Req__c);
        this.OrderId = result.data.ElixirSuite__Lab_Order_Req__c;
        this.lab = result.data[this.nameSpace+'Lab_Id__c'];
        this.accountId = result.data[this.nameSpace+'Account_Id__c'];
        console.log('Account Id', this.accountId);
        console.log('OrderId: ' +JSON.stringify(this.OrderId));
        if(result.data[this.nameSpace+'ICD_Id__c'] != undefined){
            this.icd =result.data[this.nameSpace+'ICD_Id__c'].split(";");}
       this.handleFacilityTestsAndICDs();
        this.doctorNote = result.data[this.nameSpace+'Doctors_Note__c'];
        console.log('this.doctorNote : ' +JSON.stringify(this.doctorNote ));
        this.orderingPhysicianValue =  result.data.ElixirSuite__Physician_Name__c;
        let lastName = result.data.ElixirSuite__Ordering_Provider__r.LastName;
        let firstName = result.data.ElixirSuite__Ordering_Provider__r.FirstName;

            if(firstName){
                this.physician = lastName+','+firstName;
            }else{
                this.physician = lastName;
            }
        console.log('this.physician '+this.physician);
        this.facility = result.data[this.nameSpace+'Facility_Id__c'];

        this.collectionTime = result.data[this.nameSpace+'Collection_Date_Time__c'];
       // this.test = [result.data.Test_Id__c];
        this.expectedTime = result.data[this.nameSpace+'Expected_Date_Time__c'];
        if(result.data[this.nameSpace+'Order_Type__c'] == 'PSC'){
            this.isPSC = true;
        }
        window.console.log('ICD selected '+ this.icd);
        this.error = undefined;
        
    } else if (result.error) {
        
        this.error = result.error;
        this.data = undefined;
        window.console.log(this.error);
        alert(this.error + ' error');
    }

}
@wire(getPatientId)
    wiredPatientId({ data, error }) {
        if (data) {
            // Check if patientId is present
            this.isNewButtonVisible = !data; // Hide the button if patientId is present
        } else if (error) {
            // Handle error
            console.error('Error retrieving patientId', error);
        }
    }

@wire(getLabs)
    wiredLabs({ error, data }){
        console.log('Lab Wire Excecuted');
        var i=0;
        if(data){
            this.labs=[];
            for(i=0; i<data.length; i++)  {
                //this.labs = [...this.labs ,{value: data[i].lab_id__c , label: data[i].Name} ];
                this.labs = [...this.labs ,{value: data[i][this.nameSpace+'Lab_Id__c'] , label: data[i].Name} ];                                   
            
                console.log('Recieved Lab : ' + data[i][this.nameSpace+'Lab_Id__c'] + ' : '+ data[i].Name);   
            }
                         
            this.error = undefined;
        }else if (error) {
            this.error = error;
            console.log('Lab Wire Error: '+error.body.message); 
        }
    }
   
    @wire(getPhysicians)
    wiredgetPhysicians({ error, data }){
        console.log('Physican Wire Excecuted');
        var i=0;
        if(data){
            this.physicians=[];
            for(i=0; i<data.length; i++)  {
                let physicianName = data[i]['LastName'];
      if (data[i]['FirstName']) {
        physicianName += ',' + data[i]['FirstName'];
      }
      this.physicians = [...this.physicians, { value: physicianName, label: physicianName}];
                //this.physicians = [...this.physicians ,{value: (data[i]['LastName'] + ',' +data[i]['FirstName']), label: (data[i]['LastName'] + ',' +data[i]['FirstName'])} ];                                   
            }

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.showErrorToast(error.body.message);

        }
    }
    
   
    handleFacilityTestsAndICDs(){
       
        getFacilities({ labId: this.lab })
            .then((result) => {
                var i =0;
                //this.facilities = result;
                this.error = undefined;
                this.facilities=[];
                for(i=0; i<result.length; i++)  {
                    //this.labs = [...this.labs ,{value: data[i].lab_id__c , label: data[i].Name} ];
                    this.facilities = [...this.facilities ,{value: result[i][this.nameSpace+'Facility_Id__c'] , label: result[i].Name} ];
                    console.log('Recieved Facility : ' + result[i][this.nameSpace+'Facility_Id__c'] + ' : '+ result[i].Name);
                }
                window.console.log('getFacilities Function Call Completed!!');
            })
            .catch((error) => {
                this.error = error;
                //this.returnedOrderID = undefined;
                window.console.log('getFacilities Function Call NOT Completed!!');
                window.console.log('ERROR : '+error.body.message);
            });

            getTests({ OrderId: this.OrderId })
            .then((result) => {
                var i =0;
                //this.facilities = result;
                this.error = undefined;
                this.tests=[];
                this.test = result;
                //Window.console.log('Order Id : ' + OrderId);
                //Window.console.log('test' + this.test);
                for(i=0; i<result.length; i++)  {
                    //this.labs = [...this.labs ,{value: data[i].lab_id__c , label: data[i].Name} ];
                    this.tests = [...this.tests ,{value: result[i][this.nameSpace+'Test_Id__c'] , label: result[i][this.nameSpace+'Test_Name__c']} ];
                    //this.test.push(result[i].Test_Id__c);
                    console.log('Recieved test : ' + result[i][this.nameSpace+'Test_Id__c']+ ' : '+ result[i][this.nameSpace+'Test_Name__c']);
                }
                window.console.log('getTests Function Call Completed!!' + this.OrderId);
                
            })
            .catch((error) => {
                this.error = error;
                //this.returnedOrderID = undefined;
                
                window.console.log('getTests Function Call NOT Completed!!');
                window.console.log('ERROR : '+error.body.message);
            });

            getICDs({ICD_Id : this.icd, accountId : this.accountId})
            .then((result) => {
                var i =0;
                //this.facilities = result;
                this.error = undefined;
                this.ICDs=[];
                this.icd = result;
                //Window.console.log('Order Id : ' + OrderId);
                for(i=0; i<result.length; i++)  {
                    //this.labs = [...this.labs ,{value: data[i].lab_id__c , label: data[i].Name} ];
                    this.ICDs = [...this.ICDs ,{value: result[i]['Name'] , label: result[i].ElixirSuite__Code_Description1__c} ];
                    // console.log('Recieved ICDs : ' + result[i][this.nameSpace+'ICD_Id__c']+ ' : '+ result[i].Name);
                }
                window.console.log('getICDs Function Call Completed!!' );
                
            })
            .catch((error) => {
                this.error = error;
                //this.returnedOrderID = undefined;
                
                window.console.log('getICDs Function Call NOT Completed!!');
                window.console.log('ERROR : '+error.body.message);
            });

    }


    @track dataLength = 0; 
    @track havedata;
    @wire(getTestResultsTextLWC, {r_id : "$rid"})
    testresult(result){
        if (result.data) {
            //this.tdata = result.data;
           
            this.TestTextData = JSON.parse(JSON.stringify(result.data));
            window.console.log('test res data : '+JSON.stringify(result.data));
           
               
           this.dataLength =this.TestTextData.length; 
            //this.data[0].image = this.image;
            window.console.log('data length '+this.TestTextData.length);
            if(this.TestTextData.length > 0){
                this.dataLength = this.TestTextData.length;
            }
            this.error = undefined;
           
        }
            else if (result.error) {
                
            
            this.error = result.error;
            this.TestTextData = undefined;
            window.console.log(this.error);
            
        }
        
        
    }
get labOptions() {
    return  this.labs;
}
get orderingPhysicianOptions() {
    return this.physicians ;
}
   
get facilityOptions() {
    return this.facilities ;
}

get testsOptions() {
    
    return this.tests;
}

get ICD10Options() {
    return this.ICDs ;
}

handleNoteChange(event){
    //alert('changed' + event.target.value);
    this.doctorNote = event.target.value;
    
    
}
haveChange(){
    this.havedata = true;
}
/*handleCancelNote(event){
    this.add_note = false;
}

handleNoteChange(event){
this.doctorNote = event.detail.value;
}

handleTitleChange(event){
    this.titleNote = event.detail.value;
}*/
handleSave(){
   // alert(this.doctorNote);
    addNote({ recordId: this.rid , doctorNote : this.doctorNote })
    .then((result) => {
        this.returnedOrderID = result;
        this.error = undefined;
        const event = new ShowToastEvent({
            variant: 'success',
            title: 'Success!',
            message: "Doctor's Note is saved",
           
        });
        this.dispatchEvent(event);
        window.console.log('Function Call Completed!!');
         refreshApex(this.refreshTable);
         refreshApex(this.refreshNote);
    })
    .catch((error) => {
        this.error = error;
        this.returnedOrderID = undefined;
        window.console.log('Function Call NOT Completed!! for note');
        window.console.log('ERROR : '+error.body.message);
    });


//alert(this.errors);

if (this.errors == undefined) {
    
    //alert("Congratulations! Order Added successfully");
    window.console.log('Order Added!!, OrderID : '+ this.returnedOrderID);
    //sendMessage();
    
} else {
    alert("Following error reported : "+ this.errors);
}
this.add_note = false;
 refreshApex(this.refreshNote);
}

@wire(MessageContext)
messageContext;

//funtion to go back to lab order list by changing the variable value to null which is used for rendering the lab order list comp
handleClose(){
        //this.rid = null;
        const payload = { recordId: null };
        publish(this.messageContext, fetchRecordIdMC, payload);
        //return refreshApex(this.result);
}



    generatePdf(){
        
        var url = '/apex/'+this.nameSpace+'LabOrderResults?id='+this.rid;
        var printWindow = window.open(url);
        
    }

    handleRequisitionLabel(){
        var url = '/apex/'+this.nameSpace+'getRequisitionLabel?id='+this.rid;
        var printWindow = window.open(url);
    }

    handleRequisitionPdf(){
        var url = '/apex/'+this.nameSpace+'LabOrderRequisitionPdf2?id='+this.rid;
        var printWindow = window.open(url);
    }

    @track
    isPrint = true;

    connectedCallback(){
        //subscribing to the Lightning Message Service Channel
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                fetchIsPrintMC,
                (message) => this.SetIsPrint(message)
                
            );
        }
        //this.loadRelatedContacts("");
    }
    
    //function related to message channel for disabling subscription
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    SetIsPrint(message){
        
        this.isPrint = message.isPrint;
    }

}