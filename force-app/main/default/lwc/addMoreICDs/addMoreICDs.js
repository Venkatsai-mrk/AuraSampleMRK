import { LightningElement, api, track, wire } from 'lwc';
import getICDList from '@salesforce/apex/OrderAPICallouts.getICDList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'ICD Id', fieldName: 'Name' },
    { label: 'ICD Name', fieldName: 'ElixirSuite__Code_Description1__c' }
];


export default class Modal extends LightningElement {
    lastLoadedRecordId = null;
    BATCH_SIZE = 200;
    showModal = false;
selectedValuesBox=false;
    loadMoreStatus;
    targetDatatable;
    @api selectedRows;
    @track count;
    @track searchValue;
    @api show() {
        window.console.log('ICD modal Show Called');
        this.showModal = true;
        this.searchKey = '';
        this.handleSearch();
    }
    handleDialogClose() {
        this.showModal = false;
this.selectedValues =[];
         this.selectedValuesBox=false;
    }
    columns = columns;
    @track data=[];
    error;
    allRecordsLoaded = false;
    searchFlag = false;
    //,  labId: this.labid 
    /*@wire(getICDList, { searchKey: '$searchKey'})
    Lab_Orders(result) {
        console.log('Anarth Ho gaya !! Wire Chall Gaya!!');
        if (result.data) {
            this.data = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }*/

    handleSearchKey(event) {
        var str = event.detail.value;
        this.searchKey = str.trim();
        if (this.searchKey == '') {
            this.show();
        }
        this.searchFlag = true;
    }
    handleICDSearch(){
        this.data = [];
        this.lastLoadedRecordId = null;
        this.handleSearch();
    }

    handleSearch() {
        getICDList({ searchKey: this.searchKey, startRecordId: this.lastLoadedRecordId, batchSize: this.BATCH_SIZE })
            .then((result) => {
                //var i = 0;
                //this.facilities = result;
                this.allRecordsLoaded = false;
                if(this.searchFlag){
                    this.data = [];
                    this.searchFlag = false;
                }
               /* this.error = undefined;
                this.data = result;
                 this.count = result.length;*/
                 this.data = [...this.data, ...result];
                this.count = this.data.length;
                this.error = undefined;
                this.loadMoreStatus = '';
                if (result.length < this.BATCH_SIZE) {
                    // If the number of records loaded is less than the batch size, it means all records are loaded.
                    this.allRecordsLoaded = true;
                }
                
                //Disable a spinner to signal that data has been loaded
                if (this.targetDatatable) this.targetDatatable.isLoading = false;
                //console.log('getTestList call completed : '+result);
            })
            .catch((error) => {
                this.error = error;
                //this.returnedOrderID = undefined;
                window.console.log('getICDList Function Call NOT Completed!!');
                window.console.log('ERROR : ' + error.body.message);
            });

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
            this.selectedValues = event.detail.selectedRows.map(row => ({
        Id: row.Id,
        Name: this.getNameById(row.Id),
        ElixirSuite__Code_Description1__c: this.getTestIdById(row.Id)
    }));
    this.selectedValuesBox = true;
    break;
        case 'deselectAllRows':
            this.selectedValues = [];
            break;
        case 'rowSelect':
        this.selectedValuesBox=true;
            this.selectedValues.push({
                Id: event.detail.config.value,
                Name: this.getNameById(event.detail.config.value),
                ElixirSuite__Code_Description1__c: this.getTestIdById(event.detail.config.value)
                
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
}
 

   getNameById(Id) {
    console.log('insidegetNameById : ' + JSON.stringify(this.data));
    const row = this.data.find(item => item.Id === Id);
   
    return row ? row.Name : '';
}

getTestIdById(Id) {
    const row = this.data.find(item => item.Id === Id);
    return row ? row.ElixirSuite__Code_Description1__c : '';
}
    getSelectedICDRecords() {

        //var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        // console.log('selectedRecords are ', selectedRecords);
       // console.log('selectedRecords 1 ', selectedRecords[0].Test_Description__c);
        //console.log('selectedRecords 2 ', selectedRecords[1].Test_Description__c);
        // this.selectedRows = selectedRecords;

        // console.log('selectedRows are########### ', this.selectedRows);
        //Fire Custom Event
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("icdsadded", {
            detail: this.selectedValues
        });

        // Dispatches the event.
         if (this.selectedValues.length > 0) {
        this.dispatchEvent(selectedEvent);
        this.handleDialogClose();
         }
        else {
                   console.log('Inside Error @@@@@@@@@@@');
                   this.showErrorToast('No ICD Selected');
                   console.log('Inside Error @@@@@@@@@@@#################111');
               }

    }
}