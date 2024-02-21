import { LightningElement, track, wire } from 'lwc';
import fetchAllPaymentDetail from '@salesforce/apex/PortalBillingClass.getTransactions';
import searchTransaction from '@salesforce/apex/PortalBillingClass.searchTransaction';
import MY_IMAGE from '@salesforce/resourceUrl/PrescriptionPDFImages';


const PAGE_SIZE = 10; // Number of records to load per page
const SCROLL_LOAD_THRESHOLD = 300; // Threshold in pixels for triggering lazy loading

export default class PaymentsBillingOverview extends LightningElement {
    @track transactions = [];
    @track showLoading = false;
    @track showNoMoreData = false;
    offset = 0;
    
    fromDate=null;
    toDate=null;

    connectedCallback() {
        this.loadData();
    }

    loadData(){
        return fetchAllPaymentDetail({ pageSize: PAGE_SIZE, offset: this.offset }).then(result=>{
            
            if(result){ 
                var resultData = JSON.parse(result);
                for(let data=0; data < resultData.length; data++){
                    var trans = resultData[data];
                    if(trans.lstTransaction.ElixirSuite__Payment_Information__r){
                        
                        var cardNumber = trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c;
                        trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c = '************'+cardNumber.slice(cardNumber.length - 4);
                        
                        if(trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Company__c == 'Master Card'){
                            resultData[data].isImageURL = MY_IMAGE + '/MasterCard.png';
                        }
                        else if(trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Company__c == 'Visa'){
                            resultData[data].isImageURL = MY_IMAGE + '/Visa.png';
                        }
                        else if(trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Company__c == 'Discover'){
                            resultData[data].isImageURL = MY_IMAGE + '/Discover.png';
                        }
                        else if(trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Company__c == 'American Express'){
                            resultData[data].isImageURL = MY_IMAGE + '/AmericanExpress.png';
                        }
                    }
                }
                
                
                this.offset += resultData.length;
                    
                    this.showLoading = false;
                    
                    if (resultData.length < PAGE_SIZE) {
                        this.showNoMoreData = true;
                    }
                this.transactions =[...this.transactions, ...resultData];
                //this.transactions.push(...resultData);
                console.log('inside fetchAllPaymentDetail',this.transactions);
                return new Promise((resolve) => {
                    resolve();
                });
            }
            else{
                
                this.showLoading = false; // No more transactions to load
                    this.showNoMoreData = true;
            }
        }).catch(error=>{
            
            console.log('error inside of fetchAllPaymentDetail',error);
        })
    }

    changeFromDate(event){
        this.fromDate = event.target.value;
    }

    changeToDate(event){
        this.toDate = event.target.value;
    }

    search(event){
        console.log('this.fromDate',this.fromDate,'this.toDate',this.toDate);
        let dte = new Date(this.fromDate+'T00:00:00.000Z');
        let endte = new Date(this.toDate+'T23:59:00.000Z');
        
        if(this.fromDate != null && this.toDate != null){
            this.transactions=[];
            this.offset=0;
            searchTransaction({fromDate : dte, toDate : endte}).then(result=>{
            if(result){
                var resultData = JSON.parse(result);
                for(let data=0; data < resultData.length; data++){
                    var trans = resultData[data];
                    if(trans.lstTransaction.ElixirSuite__Payment_Information__r){
                        
                        var cardNumber = trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c;
                        trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Number__c = '************'+cardNumber.slice(cardNumber.length - 4);
                        
                        if(trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Company__c == 'Master Card'){
                            resultData[data].isImageURL = MY_IMAGE + '/MasterCard.png';
                        }
                        else if(trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Company__c == 'Visa'){
                            resultData[data].isImageURL = MY_IMAGE + '/Visa.png';
                        }
                        else if(trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Company__c == 'Discover'){
                            resultData[data].isImageURL = MY_IMAGE + '/Discover.png';
                        }
                        else if(trans.lstTransaction.ElixirSuite__Payment_Information__r.ElixirSuite__Credit_Card_Company__c == 'American Express'){
                            resultData[data].isImageURL = MY_IMAGE + '/AmericanExpress.png';
                        }
                    }
                }
                this.transactions = resultData;
                console.log('inside search transaction',this.transactions);
            }
            }).catch(error=>{
                console.log('error inside of search transaction',error);
            })
        }
    }

    clearFilter(event){
        this.fromDate=null;
        this.toDate=null;
        this.transactions=[];
        this.offset=0;
        this.loadData();
    }


    get visibleTransactions() {
        const pageSize = 10;
        return this.transactions.slice(0, this.currentPage * pageSize);
    }
   
    
    
    loadingMoreRecords = false;
    loadMoreRecords(event) {
       
        // Lazy load more transactions when the user scrolls to the bottom
        if (!this.loadingMoreRecords && this.transactions.length > 0) {
            
            //console.log(`scrollTop: ${event.target.scrollTop} scrollHeight: ${event.target.scrollHeight} offsetHeight: ${event.target.offsetHeight}`);
            this.loadingMoreRecords = ((event.target.scrollHeight - event.target.offsetHeight) - event.target.scrollTop) < 1;
            console.log(' this.loadingMoreRecords: ',  this.loadingMoreRecords);
            
            if (this.loadingMoreRecords) {
                
                // scrolled to botoom first time
                console.log("calling getAvailableBedsJS");
                if(this.fromDate != null && this.toDate != null){
                    this.search();
                }
                else{
                    this.loadData()
                    .then(() => {
                        
                        this.loadingMoreRecords = false;
                        console.log('Value of loading more record' + this.loadingMoreRecords);
                    });
                console.log("done calling getAvailableBedsJS");
                }

                
            }
        }
        
    }
       
    

}