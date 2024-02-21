import { LightningElement ,track, wire} from 'lwc';
//import allMedication from '@salesforce/apex/activeMedicationApex.medicationHistory';
//import sendEmail from '@salesforce/apex/activeMedicationApex.sendEmail';
//import Id from '@salesforce/user/Id';
//import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';  
/*const columns = [
    { label: 'Medicine', fieldName: 'ElixirSuite__Drug_Name__c' },
    { label: 'Dosage', fieldName: 'ElixirSuite__Patient_SIG__c', type: 'text', sortable: true },
    { label: 'Frequency', fieldName: 'ElixirSuite__Ferquency__c', type:'text',sortable: "true" },
    {  type:'button',  typeAttributes: { 
        label: 'Request Refill', 
        title: 'Request Refill',
        //disabled: { fieldName: 'isActive' },
        disabled: false,
        iconPosition:'Center',
        target: '_blank',
        name: 'Request_Refill', 
        variant: 'brand'}
    }
];*/
export default class ActiveMedications extends NavigationMixin(LightningElement) {
   /* @track data;
    @track columns = columns;
    @track wiredNewList = [];
    @track medicationRecords = [];
    userId = Id;
    showMedication = false;
    @track pageSize = 3;
    @track pageNumber = 0;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track recordEnd = 0;
    @track isPrev = true;
    @track isNext = true;
    futureItemArray = [];
    isActive = true;
    @track disableActions = false;
    @track selectedRow='';


    connectedCallback(){
        this.displayMedication();
        refreshApex(this.wiredNewList);
    }
     //handle first
     handleFirst(){
        this.pageNumber = 0;
        this.itemMethod(this.pageSize, this.pageNumber);
    }
    //handle next
    handleNext(){
        this.pageNumber = this.pageNumber+1;
        this.itemMethod(this.pageSize, this.pageNumber);
    }
    //handle prev
    handlePrev(){
        this.pageNumber = this.pageNumber-1;
        this.itemMethod(this.pageSize, this.pageNumber);
    }
    //handle Last
    handleLast(){
        this.pageNumber = Math.floor(this.totalRecords / this.pageSize);
        this.itemMethod(this.pageSize, this.pageNumber);
    }

 
    displayMedication(){
        allMedication({userId : this.userId}).then(result=>{
            if(result){
            console.log('result data ',result);
            var resultData = JSON.parse(result);
            console.log('resultdata',resultData)
            this.medicationRecords = resultData.objPO;
            //this.medicationRecords = result;
            //this.wiredNewList = result;
            //this.showMedication = true;
            this.totalRecords = resultData.totalRecords;
            this.recordEnd = this.totalRecords >= (this.pageSize * this.pageNumber) + this.pageSize ? (this.pageSize * this.pageNumber) + this.pageSize : this.totalRecords;
            this.totalPages = Math.floor(resultData.totalRecords / this.pageSize);
            this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
            this.isPrev = (this.pageNumber == 0 || this.totalRecords < this.pageSize);  
            this.itemMethod(this.pageSize,this.pageNumber);
            }
            else{
                console.log('medicationrecord result',result);
            }
        })
        .catch(error => {
            console.log('error in data',error);
        });
    }
    
    itemMethod(pagesize, pagenumber){
        this.futureItemArray = []; 
         for(var i =pagenumber*pagesize; i<(pagenumber*pagesize)+pagesize && i<this.medicationRecords.length; i++){
             this.futureItemArray.push(this.medicationRecords[i]);
         }

         this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
         this.isPrev = (this.pageNumber == 0 || this.totalRecords < this.pageSize);
         this.recordEnd = this.totalRecords >= (this.pageSize * this.pageNumber) + this.pageSize ? (this.pageSize * this.pageNumber) + this.pageSize : this.totalRecords;     
    }


    //@wire(sendEmail) sendEmail;

   handleSendEmail(event){

    console.log('inside handleSendEmail');
    //this.disabled = true;
    let recId =  event.detail.row.Id; 
    console.log('recIdrecId', JSON.stringify(recId)); 
    let actionName = event.detail.action.name;
    console.log('inside actionName', actionName);
    console.log('inside name', event.detail.action.disabled);
    let selectedRow = event.detail.row;
    ///if (this.disableActions) {
       // event.preventDefault();
    //}

    if (actionName === 'Request_Refill') { 
        selectedRow.Request_Refill.disabled = true;
        window.setTimeout(() => {
            // enable the button
            this.disabled = true;
        }, 20);

        sendEmail().then(result =>{
            console.log('Email sent successfully',result);
            //Enable the button
            selectedRow.Request_Refill.disabled = false;
           // for (var i = 0; i < this.medicationRecords.length; i++) {
                //this.medicationRecords[i].isActive = true;
            //}
            //this.disabled = true;
            //console.log('disabled',this.disabled)
            //this.disableActions = true;
            //this.isActive = true;
         })
         .catch(error => { 
            console.error('Error sending email: ', error); 
            
            });  
        }  
}
}


//for (var i = 0; i < this.labResults.length; i++)
 //{
   // this.labResults[i].isLoActive = true;

//idOfPrescription = this.recId
  /* const actionName = event.detail.action.name;
  //this.showMedication = true;
   let recId = event.detail.row.Id;
    switch (actionName) {
        if(actionName === 'Request_Refill'){
        //case 'Request_Refill':
            sendEmail().then(result =>{
                console.log('Email sent successfully',result);
             })
             .catch(error => { 
                console.error('Error sending email: ', error); 
                });  
            }        
            //break;

        //default:
            //break;*/
    
        }