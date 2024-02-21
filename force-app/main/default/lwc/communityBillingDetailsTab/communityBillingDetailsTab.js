import { LightningElement, api, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import fetchAllBillingDetail from '@salesforce/apex/PortalBillingClass.displayBillingDetail';
import searchVisit from '@salesforce/apex/PortalBillingClass.searchVisit';

export default class CommunityBillingDetailsTab extends LightningElement {
   userId = Id;
   lstVisit = [];
   fromDate=null;
   toDate=null;

   connectedCallback(){
        this.displayBillingDetail(); 
    }

    displayBillingDetail(){
        fetchAllBillingDetail({userId : this.userId}).then(result=>{
            if(result){
                var resultData = result;
                
                this.lstVisit = resultData;
                console.log('inside this.lstVisit',this.lstVisit);
            }
        }).catch(error=>{
            console.log('error inside of displayBillingDetail',error);
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
        let fromDate = this.template.querySelector('.fDate');
        if(dte > endte){
            fromDate.setCustomValidity("From date should not be larger than To date.");
            fromDate.reportValidity();
        }
        else{
        fromDate.setCustomValidity("");
        fromDate.reportValidity();
        if(this.fromDate != null && this.toDate != null){
            searchVisit({fromDate : dte, toDate : endte, userId : this.userId}).then(result=>{
            if(result){
                let resultData = result;
                this.lstVisit = resultData;
                console.log('inside search lstVisit',this.lstVisit);
            }
            }).catch(error=>{
                console.log('error inside of search visit',error);
            })
        }
        }
        
    }

    clearFilter(event){
        this.fromDate=null;
        this.toDate=null;
        this.displayBillingDetail();
    }

    enablePayment(event){
        let btnPayment = this.template.querySelector('.pay-btn');
        btnPayment.disabled = false;
    }

    disablePayment(event){
        let btnPayment = this.template.querySelector('.pay-btn');
        if(btnPayment.disabled == false){
            btnPayment.disabled = true;
        }
    }
}