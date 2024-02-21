import { LightningElement,track,api } from 'lwc';
//import Id from '@salesforce/user/Id';
//import fetchAllInsurance from '@salesforce/apex/displayInsuranceCommunity.fetchInsurance'; 
import { NavigationMixin } from 'lightning/navigation';  
  
/*const COLUMNS = [  
    { label: 'Id', type: "button", typeAttributes: { label: { fieldName: "Name" }, name: "gotoInsurance", variant: "base" } },  
    { label: 'Subscriber Name', fieldName: 'ElixirSuite__Subscriber_Name__c' },  
    { label: 'Provider', fieldName: 'ElixirSuite__Insurance_Provider_Sec__c' },
    { label: 'Type', fieldName: 'ElixirSuite__Insurance_Type_Sec__c' },
    { label: 'Group Number', fieldName: 'ElixirSuite__Insurance_Group_Number__c' },  
    { type: "button", typeAttributes: {  
        label: 'Request Update',  
        name: 'Request Update',  
        title: 'Request Update',  
        disabled: false,  
        value: 'Request Update',  
        iconPosition: 'centre',
        variant: 'brand'  
    } }
];*/

export default class DisplayInsurance extends NavigationMixin(LightningElement) {

    /*userId = Id;
    columns = COLUMNS;
    @track insuranceRecords = [];
    showInsurance = false;
    @track pageSize = 3;
    @track pageNumber = 0;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track recordEnd = 0;
    @track isPrev = true;
    @track isNext = true;
    futureItemArray = [];

    connectedCallback(){
        this.displayInsurance(); 
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

    displayInsurance(){
        fetchAllInsurance({userId : this.userId}).then(result=>{
            if(result){
                var resultData = JSON.parse(result);
                console.log('resultdata',resultData)
                this.insuranceRecords = resultData.objVOB;
                this.totalRecords = resultData.totalRecords;
                this.recordEnd = this.totalRecords >= (this.pageSize * this.pageNumber) + this.pageSize ? (this.pageSize * this.pageNumber) + this.pageSize : this.totalRecords;
                this.totalPages = Math.floor(resultData.totalRecords / this.pageSize);
                this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                this.isPrev = (this.pageNumber == 0 || this.totalRecords < this.pageSize);
                //this.insuranceRecords = result;
                //this.showInsurance = true;
                this.itemMethod(this.pageSize,this.pageNumber);
            }
            else{
                console.log('insuranceRecords result',result);
            }
        }).catch(error=>{
            console.log('error inside of displayInsurance',error);
        })
    }

    callRowAction(event){
        console.log('inside requestUpdateHandler');
        let recId =  event.detail.row.Id;  
        let actionName = event.detail.action.name;

        if (actionName === 'gotoInsurance') {  
            this[NavigationMixin.Navigate]({  
                type: 'standard__webPage',  
                attributes: {  
                    /*recordId: recId,  
                    objectApiName: 'ElixirSuite__VOB__c',  
                    actionName: 'view'
                    url: '/detailVob/' + recId
                }  
            },true);
        } 
    }

    itemMethod(pagesize, pagenumber){

        this.futureItemArray = [];
 
         for(var i =pagenumber*pagesize; i<(pagenumber*pagesize)+pagesize && i<this.insuranceRecords.length; i++){
             this.futureItemArray.push(this.insuranceRecords[i]);
         }
     
         this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
         this.isPrev = (this.pageNumber == 0 || this.totalRecords < this.pageSize);
         this.recordEnd = this.totalRecords >= (this.pageSize * this.pageNumber) + this.pageSize ? (this.pageSize * this.pageNumber) + this.pageSize : this.totalRecords;
         
     }*/
}