import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTestList from '@salesforce/apex/OrderAPICallouts.getTestList';
import getInhouseTestList from '@salesforce/apex/OrderAPICallouts.getInhouseTestList';

const columns = [
   
    { label: 'Test Id', fieldName: 'ElixirSuite__Test_Id__c' },
    { label: 'Test Name', fieldName: 'ElixirSuite__Test_Name__c' }
];
const columnsManuals = [
    { label: 'Test Id', fieldName: 'ElixirSuite__Test_Id__c' },
    { label: 'Test Name', fieldName: 'ElixirSuite__Test_Name__c' }
    
];
//{ label: 'Test Description', fieldName: 'Test_Description__c'}]; //Test_Description__c



//export default class AddMoreTests extends LightningElement {}
export default class Modal extends LightningElement {
    lastLoadedRecordId = null;
    BATCH_SIZE = 100;
    loadMoreStatus;
    targetDatatable;

    showModal = false;
    @track searchValue;
    @api selectedRows;
    @track count;
    @api labid = '9999'; //'2701389'
    @api labtype='';
searchBox=false;
    selectedValuesBox=false;

    @api show() {
        // window.console.log('Modal Show Called');
        console.log('Child : LabID : ' + this.labid);
        console.log('Child : labtype : ' + this.labtype);
        this.showModal = true;
        this.searchKey = '';
        this.handleSearch();


    }
    handleDialogClose() {
        this.showModal = false;
        this.data = [];
        this.searchKey = '';
        this.lastLoadedRecordId = null;
this.selectedValues =[];
           this.selectedValuesBox=false;
    }

    columns;
    @track data=[];
    error;

    searchKey = '';
    //,  labId: this.labid
    /* 
    @wire(getTestList, { searchKey: '$searchKey' ,  labId: ''})
    Lab_Orders(result) {

        if (result.data) {
            this.data = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }*/
    searchFlag = false;
    allRecordsLoaded = false;

    handleSearchKey(event) {

        var str = event.detail.value;
        this.searchKey = str.trim();
        if (this.searchKey == '') {
            this.show();
        }
        this.searchFlag = true;
    }
@track opp=false;
    handleTestSearch(){
        this.data = [];
        this.lastLoadedRecordId = null;
        this.handleSearch();
this.opp=true;
    }

    handleSearch() {
        //this.searchKey = event.detail.value;
        if (this.labid != '') {
            console.log('inside handleSearch: labtype : ' + this.labtype);
            if(this.labtype =='Manual'){
                getInhouseTestList({ searchKey: this.searchKey,startRecordId: this.lastLoadedRecordId, batchSize: this.BATCH_SIZE })
                .then((result) => {
                   
                    this.allRecordsLoaded = false;
                    if(this.searchFlag){
                        this.data = [];
                        this.searchFlag = false;
                    }
                    this.data = [...this.data, ...result];
                    this.count = this.data.length;
                    this.error = undefined;
                    this.loadMoreStatus = '';
                    this.columns=columnsManuals;

                    if (result.length < this.BATCH_SIZE) {
                        // If the number of records loaded is less than the batch size, it means all records are loaded.
                        this.allRecordsLoaded = true;
                    }
                    if (this.targetDatatable) this.targetDatatable.isLoading = false;
                    //console.log('getTestList call completed : '+result);
                })
                .catch((error) => {
                    this.error = error;
                    //this.returnedOrderID = undefined;
                    window.console.log('getInhouseTestList Function Call NOT Completed!!');
                    window.console.log('ERROR : ' + error.body.message);
                });
            }else{

            
            getTestList({ searchKey: this.searchKey, labId: this.labid, startRecordId: this.lastLoadedRecordId, batchSize: this.BATCH_SIZE })
                .then((result) => {
                    // var i = 0;
                    //this.facilities = result;
                    //this.error = undefined;
                    // this.data = result;
                    this.allRecordsLoaded = false;
                    if(this.searchFlag){
                        this.data = [];
                        this.searchFlag = false;
                    }
                    this.data = [...this.data, ...result];
                    this.count = this.data.length;
                    this.error = undefined;
                    this.loadMoreStatus = '';
                    this.columns=columns;

                    if (result.length < this.BATCH_SIZE) {
                        // If the number of records loaded is less than the batch size, it means all records are loaded.
                        this.allRecordsLoaded = true;
                    }
                    if (this.targetDatatable) this.targetDatatable.isLoading = false;
                    //console.log('getTestList call completed : '+result);
                })
                .catch((error) => {
                    this.error = error;
                    //this.returnedOrderID = undefined;
                    window.console.log('getTestList Function Call NOT Completed!!');
                    window.console.log('ERROR : ' + error.body.message);
                });
        }
     } else {
            // alert('Please select a lab before adding tests!');
            this.showErrorToast('Please select a lab before adding tests!');
            this.showModal = false;
        
    }
    }

    handleLoadMore(event) {
        event.preventDefault();
        if (this.allRecordsLoaded) {
            // If all records are already loaded, do nothing.
            return;
        }

        event.target.isLoading = true;

        this.targetDatatable = event.target;

        this.loadMoreStatus = 'Loading';
        this.lastLoadedRecordId = this.data[this.data.length - 1].Id;

        this.handleSearch();
    }

    showSuccessToast(message) {
        const evt = new ShowToastEvent({
            title: 'Toast Success',
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showErrorToast(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
@track selectedValues = [];
handleRowSelection(event) {
    switch (event.detail.config.action) {
        case 'selectAllRows':
            this.selectedValues = this.selectedValues = event.detail.selectedRows.map(row => ({
                Id: row.Id,
                ElixirSuite__Test_Name__c: this.getNameById(row.Id),
                ElixirSuite__Test_Id__c: this.getTestIdById(row.Id),
            }));
              this.selectedValuesBox=true;
            break;
        case 'deselectAllRows':
            this.selectedValues = [];
             if(this.selectedValues >0){
          this.selectedValuesBox=false;
    }
            break;
        case 'rowSelect':
         this.selectedValuesBox=true;
            this.selectedValues.push({
                Id: event.detail.config.value,
                ElixirSuite__Test_Name__c: this.getNameById(event.detail.config.value),
                ElixirSuite__Test_Id__c: this.getTestIdById(event.detail.config.value),
            });
            break;
        case 'rowDeselect':
            const index = this.selectedValues.findIndex(item => item.Id === event.detail.config.value);
            if (index !== -1) {
                this.selectedValues.splice(index, 1);
           
            }
            break;
        default:
            break;
    }

    console.log('selectedValues: ' + JSON.stringify(this.selectedValues));
    if(this.selectedValues >0){
          this.selectedValuesBox=true;
    }
   
}

getNameById(Id) {
    console.log('insidegetNameById : ' + JSON.stringify(this.data));
    const row = this.data.find(item => item.Id === Id);
   
    return row ? row.ElixirSuite__Test_Name__c : '';
}

getTestIdById(Id) {
    const row = this.data.find(item => item.Id === Id);
    return row ? row.ElixirSuite__Test_Id__c : '';
}


    getSelectedTestRecords() {
// console.log('All Selected Rows: getSelectedTestRecords' + JSON.stringify(this.allSelectedRows));

            //var selectedRecords = this.selectedRowss;
            // console.log('selectedRecords 1 ', selectedRecords[0].Test_Description__c);
            // this.selectedRows = this.selectedRowss;
            //Fire Custom Event
            // Creates the event with the data.
            const selectedEvent = new CustomEvent("testsadded", {
                detail: this.selectedValues
            });

            // Dispatches the event.
            if (this.selectedValues.length > 0) {
                this.dispatchEvent(selectedEvent);
                this.handleDialogClose();
            } else {
                this.showErrorToast('No Test Selected');
            }
        }
        //handleSearchCloseDialogue() {
        //   if (this.searchValue == '') {
        //       this.showModal = true;
        //  }

    //  }

}