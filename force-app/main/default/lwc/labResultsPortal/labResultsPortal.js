import { LightningElement,track,api } from 'lwc';
import fetchAllLabOrders from '@salesforce/apex/LabResultsController.fetchLabOrders';
import { NavigationMixin } from 'lightning/navigation';  
import Id from '@salesforce/user/Id';

const chcColumns = [
    {label: 'Medical Test',fieldName: 'ElixirSuite__Test_Name__c', type: 'text'},
    {label: 'Date', fieldName: 'ElixirSuite__Collection_Date_Time__c', type: 'date',
    typeAttributes: { day: 'numeric',
     month: 'short', 
     year: 'numeric', 
     hour: '2-digit', 
     minute: '2-digit', 
     second: '2-digit', 
     hour12: true }},
    {label: 'Status', fieldName: 'ElixirSuite__Status__c', type: 'text'},
    {label: 'Result', type: "button", typeAttributes: {  
        label: 'Download',  
        name: 'View/Print',  
        title: 'View/Print',  
        disabled: { fieldName: 'isChActive' },  
        value: 'chcView',  
        iconPosition: 'center',
        variant: 'brand'  
    }}
];

/*const loColumns = [
    {label: 'Medical Test',fieldName: 'ElixirSuite__Medical_Test__c', type: 'text'},
    {label: 'Date', fieldName: 'ElixirSuite__Start_Date__c', type: 'date',
    typeAttributes: { day: 'numeric',
     month: 'short', 
     year: 'numeric', 
     hour: '2-digit', 
     minute: '2-digit', 
     second: '2-digit', 
     hour12: true }},
    {label: 'Status', fieldName: 'ElixirSuite__Status__c', type: 'text'},
    {label: 'Result', type: "button", typeAttributes: {  
        label: 'View/Print',  
        name: 'View/Print',  
        title: 'View/Print',  
        disabled: { fieldName: 'isLoActive' },    
        value: 'loView',  
        iconPosition: 'center',
        variant: 'brand'  
    }}
];*/

export default class LabResultsPortal extends NavigationMixin(LightningElement) {
    userId = Id;
    @track nameSpace='ElixirSuite__';
    columns =[];
    @api displayFiles=false
    @track labResults = [];
    showResults = false;
    @api singleRowId='';
    @track pageSize = 10;
    @track pageNumber = 0;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track recordEnd = 0;
    @track isPrev = true;
    @track isNext = true;
    futureItemArray = [];

    connectedCallback(){
        this.labResultsPortal(); 
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
    //handle first
    handleFirst(){
        this.pageNumber = 0;
        this.itemMethod(this.pageSize, this.pageNumber);
    }

    labResultsPortal(){
        fetchAllLabOrders({userId : this.userId}).then(result=>{
            if(result){
                this.columns=chcColumns;
                /*if (result.labWrapper=='CHC LabOrder') {
                    this.columns=chcColumns;
                }
                else if(result.labWrapper=='Dummy LabOrder') {
                    this.columns=loColumns;
                }*/
                this.labResults = result.sobjectWrapper;
                this.showResults = true;
                this.totalRecords = result.totalRecordsWrapper;
                this.recordEnd = this.totalRecords >= (this.pageSize * this.pageNumber) + this.pageSize ? (this.pageSize * this.pageNumber) + this.pageSize : this.totalRecords;
                this.totalPages = Math.floor(result.totalRecordsWrapper / this.pageSize);
                this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                this.isPrev = (this.pageNumber == 0 || this.totalRecords < this.pageSize);
                this.itemMethod(this.pageSize,this.pageNumber);
                for (var i = 0; i < this.labResults.length; i++) {
                    //this.labResults[i].isLoActive = true;
                    this.labResults[i].isChActive = true;
                    if (this.labResults[i][this.nameSpace+'LabOrder_HL7_Results__r'] != undefined) {
                        this.labResults[i].isChActive = false;
                    }
                    /*if(this.labResults[i].ElixirSuite__Is_File_Created__c==true){
                        this.labResults[i].isLoActive = false;
                    }*/
                }
            }
            else{
                console.log('Result: ',result);
            }
        }).catch(error=>{
            console.log('Error: ',error);
        })
    }

    fetchrecord(event){      
        const actionValue = event.detail.action.value;
        const row = event.detail.row;
        if (actionValue === 'chcView'){
            var url = '/apex/'+this.nameSpace+'LabOrderResults?id='+row.Id;
             var printWindow = window.open(url,"_self");
             /*Below lines are kept for future reference purpose
               window.location.href = url;
               window.history.back();
               var strFile = "data:application/pdf;base64,"+this.base64String;
               console.log('base64',strFile);
               window.download(strFile, "Pdf Report");
               window.print(url);
               print(url);
               window.location.href = url;*/  
        }
        /*if (actionValue === 'loView'){
            this.singleRowId=row.Id;
            this.displayFiles=true;
        }*/   
    }
    modalCloseHandler(){
        this.displayFiles = false
    }
    itemMethod(pagesize, pagenumber){
        this.futureItemArray = [];
         for(var i =pagenumber*pagesize; i<(pagenumber*pagesize)+pagesize && i<this.labResults.length; i++){
             this.futureItemArray.push(this.labResults[i]);
         }   
         this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
         this.isPrev = (this.pageNumber == 0 || this.totalRecords < this.pageSize);
         this.recordEnd = this.totalRecords >= (this.pageSize * this.pageNumber) + this.pageSize ? (this.pageSize * this.pageNumber) + this.pageSize : this.totalRecords;  
     }
}