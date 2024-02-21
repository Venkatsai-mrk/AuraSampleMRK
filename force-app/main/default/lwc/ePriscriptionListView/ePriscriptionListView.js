import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
// import getPrescriptionList from '@salesforce/apex/GetPrescriptionController.getPrescriptionList';
// import deleteAllRelatedRecords from '@salesforce/apex/GetPrescriptionController.deleteAllRelatedRecords';
// import getPrescriptionsById from '@salesforce/apex/GetPrescriptionController.getPrescriptionsById';
// import getPrescriptionBySearch from '@salesforce/apex/GetPrescriptionController.getPrescriptionBySearch';
// import getPrescriptionsById from '@salesforce/apex/GetPrescriptionsByQuery.getPrescriptionsById';
// import getPrescriptionBySearch from '@salesforce/apex/GetPrescriptionsByQuery.getPrescriptionBySearch';
import getPrescriptionList from '@salesforce/apex/CHC_PrescriptionsCallout.getPrescriptionList';
import { NavigationMixin } from 'lightning/navigation'

const filterOptions = [
    { value: 'All', label: 'All' },
    { value: 'Active', label: 'Active' },
    { value: 'VOID', label: 'VOID' },
    
    { value: 'Discontinued', label: 'Discontinued' }
];

export default class EPriscriptionListView extends NavigationMixin(LightningElement) {
    result;
    @api rId;
    @track sortBy;
    @track lastestData = [];
    @track sortDirection;
    @track countRecord;
    filterOptions = filterOptions;
    @track data;
    @api rxStatus1;
    @track searchValue;
    @track keySearch;
    @track isExpanded = false;
    @track currentFilter='All';
    @track filterTextValue='';
    @track wiredCHCList = [];
    // @track columns = [
    //     { label: 'Name', fieldName: 'Name', type: 'button', sortable: "true", hideDefaultActions : 'true',
    //     typeAttributes: { label: { fieldName: 'Name' }, target: '_blank', name: 'recLink', variant: 'Base' },
    //     }, 
    //     { label: 'Drug Name', fieldName: 'Drug_Name__c', type: 'text', sortable: "true", hideDefaultActions : 'true'},    
    //     { label: 'Prescriber', fieldName: 'Prescriber__c', type: 'text', sortable: "true", hideDefaultActions : 'true'},
    //     { label: 'Quantity', fieldName: 'Quantity__c', type: 'text', sortable: "true", hideDefaultActions : 'true'},
    //     { label: 'SIG', fieldName: 'SIG__c', type: 'text', sortable: "true", hideDefaultActions : 'true'}
    //     ];

    @track columns = [
        { label: 'Drug Name', fieldName: 'DrugName', type: 'text', sortable: "true", hideDefaultActions : 'true'},    
        { label: 'Prescriber', fieldName: 'prescriber', type: 'text', sortable: "true", hideDefaultActions : 'true'},
        { label: 'Quantity', fieldName: 'Quantity', type: 'text', sortable: "true", hideDefaultActions : 'true'},
        { label: 'SIG', fieldName: 'sig', type: 'text', sortable: "true", hideDefaultActions : 'true'},
        { label: 'Status', fieldName: 'rxStatus', type: 'text', sortable: "true", hideDefaultActions : 'true'},
        { label: 'Type', fieldName: 'RxType', type: 'text', sortable: "true", hideDefaultActions : 'true'},
        // { label: 'Renew', type:'button',hideDefaultActions : 'true', typeAttributes: {label: 'Renew', target: '_blank',name: 'Renew', varient: 'brand-outline'}}
        ];

        @wire(getPrescriptionList, {accId: '$rId' , rxStatus1: '$filterTextValue'})
        wiredPrescriptions(result){
            this.wiredCHCList = result;
            if(result.data){
                
                this.data = JSON.parse(result.data);
                
                console.log(result.data);
            }
            else{
                console.log(result.error);
            }
            refreshApex(this.wiredCHCList);
        }
        
    // @wire(getPrescriptionsById, {accountId: '$rId'})
    // prescriptionRecords({data,error}){
    //     this.lastestData = data;
    //     console.log(this.lastestData);
    //     if(data){
    //         this.data = data;
    //         console.log(this.data);
    //     }
    //     else if(error){
    //         this.data = undefined;
    //     }
    // }
 
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }
    sortData(fieldname, direction) {
        console.log('Whats Data' + JSON.stringify(this.data));
        let parseData = JSON.parse(JSON.stringify(this.data));
        console.log('Whats Data  22222' + JSON.stringify(this.data));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking sorting direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
        console.log('After Parse ::::--' + JSON.stringify(this.data));
    }
    navigateToRefill(){
        this[NavigationMixin.Navigate]({
            type:"standard__webPage",
            attributes:{
                url:"/apex/CHC_RefillPage?Id="+this.rId
            }
        })
    }
    navigateToRenew(){
        this[NavigationMixin.Navigate]({
            type:"standard__webPage",
            attributes:{
                url:"/apex/PrescriptionRenewalIFrame?Id="+this.rId
            }
        })
    }
    navigateToAllergy(){
        this[NavigationMixin.Navigate]({
            type:"standard__webPage",
            attributes:{
                url:"/apex/PatientAllergyIFrame?Id="+this.rId
            }
        })
    }

    navigateToCreatePrescription(){
        this[NavigationMixin.Navigate]({
            type:"standard__webPage",
            attributes:{
                url:"/apex/CreatePrescription?Id="+this.rId
            }
        })
    }
    
    
    // fetchrecord(event) {
    //     const actionName = event.detail.action.name;
    //     console.log('actionName' + JSON.stringify(actionName));
    //     const row = event.detail.row;
    //     // this.orderidvalue = row[this.Name];
    //     // console.log('orderidvalue' + this.orderidvalue);
    //     console.log('row' + JSON.stringify(row));

    //     //alert(row.Id);
    //     switch (actionName) {
    //         case 'recLink':

    //             this[NavigationMixin.Navigate]({
    //                 type: 'standard__recordPage',
    //                 attributes: {
    //                     recordId: row.Id,
    //                     objectApiName: 'ElixirSuite__Prescription_Order__c',
    //                     actionName: 'view',
    //                 },

                // this[NavigationMixin.GenerateUrl]({
                //     type: 'standard__recordPage',
                //     attributes: {
                //         recordId: this.rId,
                //         objectApiName: 'ElixirSuite__Prescription_Order__c',
                //         actionName: 'view',
                //     },
                // }).then((url) => {
                //     this.recordPageUrl = url;
                // });
                // var printWindow = window.open(this.recordPageUrl);
                // this.recordId = row.Id;
                // const payload = { recordId: row.Id };
                // publish(this.messageContext, fetchRecordIdMC, payload);
        //         break;

        //     default:
        //         break;
        // }
        // if (actionName === 'Fetch Record') {
        //     // this.showDetailComponent = true;
        //     // this.activetabdetail='2';
        //     var url = '/apex/LabOrderResults?id='+row.Id;

        //     var printWindow = window.open(url);
           /* this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__ViewLabOrderResult'
                },
                state: {
                    c__activetabdetail: '2',
                    c__rid: row.Id
                }
            });*/
        // }
        get dropdownTriggerClass() {
            if (this.isExpanded) {
                return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-is-open '
            } else {
                return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view'
            }
        }
        handleFilterChangeButton(event) {
            //let filter = event.target.dataset.filter;
            this.isExpanded = !this.isExpanded;
            
                this.currentFilter = event.target.dataset.filter;
                setTimeout(() => {
                    this.handleFilterData(this.currentFilter), 0
                });
            
        }
    
        handleFilterData(filter) {
            if (filter === 'All') {
               
                this.filterTextValue ='';
            } else if (filter === 'Active') {
                //this.filterFieldValue = 'Status__c';
                //this.filterOperatorValue = '=';
                this.filterTextValue = 'AUTHORIZED';
            } else if (filter === 'VOID') {
                //this.filterFieldValue = 'Status__c';
                //this.filterOperatorValue = '=';
                this.filterTextValue = 'VOID';
            }
            else if (filter === 'Discontinued') {
                //this.filterFieldValue = 'Status__c';
                //this.filterOperatorValue = '=';
                this.filterTextValue = 'Discontinued';
            }
           
           
        }
        handleFilterClickExtend() {
            this.isExpanded = !this.isExpanded;
        }
        handleRefresh() {
       
       
        refreshApex(this.wiredCHCList);
        // console.log('line 80 ' + JSON.stringify(this.result));
           
        }
        
        handleFilterRefresh() {
            this.selectedFieldValue = '';
            this.selectedOperatorValue = '';
            this.selectedTextValue = '';
            refreshApex(this.wiredLaborderList);
        }
    
    
    refreshComponent(){
   
        console.log('refresh button');
    // this.handleFilterData('All');
        refreshApex(this.wiredCHCList);
        console.log(this.data);
        console.log(this.wiredCHCList);
    this.filterTextValue ='';   
    }
    
}