import { LightningElement, api, track } from 'lwc';
import getProblemList from '@salesforce/apex/AddOnlyProblemController.fetchRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import maxRowSelection from '@salesforce/label/c.Max_Limit_of_Existing_Problem_Selection';

const columns = [
        { label: 'Name', fieldName: 'label' ,sortable: true},
        { label: 'SNOMED CT Code', fieldName: 'snowmed',sortable: true },
        { label: 'Problem Type', fieldName: 'problemType',sortable: true },
        { label: 'Status', fieldName: 'status',sortable: true },
        { label: 'Start Date', fieldName: 'dateOnset',sortable: true },
        { label: 'End Date', fieldName: 'endDate',sortable: true },
        { label: 'Notes', fieldName: 'notes',sortable: true }
    ];

export default class AddOnlyExistingProblem extends LightningElement {
label = {maxRowSelection};
    @api showAddExistingProblem = false;
    @api patientID;
    @api objectName;
    @api fieldName;
    columns = columns;
    @track data = [];
    error;
    allRecordsLoaded = false;
    searchFlag = false;
    lastLoadedRecordId = null;
    @track count;
    BATCH_SIZE = 200;
    targetDatatable;
    searchKey = '';
    @track searchValue;
    sortedBy;
    sortedDirection;
    

    handleDialogClose() {
        this.showAddExistingProblem = false;
        this.data = [];
        this.searchKey = '';
        this.searchValue = '';
        this.lastLoadedRecordId = null;
        var selectedRecords = [];
        const selectedEvent = new CustomEvent("problemsadded", {detail: { selectedRecords }});
        this.dispatchEvent(selectedEvent);
        this.handleSearch(); 
    }

    connectedCallback(){
        console.log(this.objectName,this.fieldName);
        this.handleSearch();
    }

    handleSort(event) {
    try {
        const { fieldName: newSortedBy, sortDirection: newSortDirection } = event.detail;
        const cloneData = [...this.data];

        if (this.sortedBy === newSortedBy) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortDirection = newSortDirection;
        }

        cloneData.sort(this.sortBy(newSortedBy, this.sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortedBy = newSortedBy;
        } catch (error) {
         console.error('Error in sorting: '+error);   
        }
    }

     sortBy(field, reverse) {
        return function (a, b) {
            const aValue = a[field] || '';
            const bValue = b[field] || '';

            return reverse * ((aValue > bValue) - (bValue > aValue));
        };
    }


    handleSearch() {
    getProblemList({
        objectName: this.objectName,
        filterField: this.fieldName,
        searchString: this.searchKey,
        accountId: this.patientID,
        startRecordId: this.lastLoadedRecordId
    })
      .then((result) => {
        this.allRecordsLoaded = false;
        if (this.searchFlag) {
          this.data = [];
          this.searchFlag = false;
        }
        /* this.error = undefined;
                this.data = result;
                 this.count = result.length;*/
        this.data = [...this.data,...result.map(item => ({
          description: item.description,
          label: item.label,
          value: item.value,
          problemType: item.problemType,
          status: item.status,
          tempProbId: item.tempProbId,
          snowmed: item.snowmed,
          notes: item.notes,
          dateOnset: item.dateOnset,
          endDate: item.endDate
      }))];
        this.count = this.data.length;
        console.log('data is',JSON.stringify(this.data), 'length is',this.count);
        // this.error = undefined;
        // this.loadMoreStatus = "";
        if(result.length < this.BATCH_SIZE) {
        // If the number of records loaded is less than the batch size, it means all records are loaded.
           this.allRecordsLoaded = true;
        }

        // //Disable a spinner to signal that data has been loaded
        if (this.targetDatatable) this.targetDatatable.isLoading = false;
        // //console.log('getTestList call completed : '+result);
      })
      .catch((error) => {
        this.error = error;
        //this.returnedOrderID = undefined;
        window.console.log("getProblemList Function Call NOT Completed!!");
        window.console.log("ERROR : " + error.body.message);
      });
    }

    handleLoadMore(event) {
    try{
    event.preventDefault();
    if (this.allRecordsLoaded) {
      console.log('allRecordsLoaded');
      // If all records are already loaded, do nothing.
      return;
    }
    event.target.isLoading = true;
    this.targetDatatable = event.target;
    this.loadMoreStatus = "Loading";
    this.lastLoadedRecordId = this.data[this.data.length - 1].value;
    console.log('###handleLoadMore',
        this.objectName,
        this.fieldName,
        this.lastLoadedRecordId);
    this.handleSearch();
    }
    catch(e){
      console.log(e);
    }
  }
  
    showSuccessToast(message) {
    const evt = new ShowToastEvent({
      title: "Toast Success",
      message: message,
      variant: "success",
      mode: "dismissable"
    });
    this.dispatchEvent(evt);
    }

    showErrorToast(message) {
    const evt = new ShowToastEvent({
      title: "Error",
      message: message,
      variant: "error",
      mode: "dismissable"
    });
    this.dispatchEvent(evt);
    }

    getSelectedProblemRecords() {
    var selectedRecords = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();
    console.log("selectedRecords are ", selectedRecords);
    // console.log('selectedRecords 1 ', selectedRecords[0].Test_Description__c);
    //console.log('selectedRecords 2 ', selectedRecords[1].Test_Description__c);
    this.selectedRows = selectedRecords;

    console.log("selectedRows are########### ", this.selectedRows);
    //Fire Custom Event
    // Creates the event with the data.
    const selectedEvent = new CustomEvent("problemsadded", {
      detail: { selectedRecords }
    });

    // Dispatches the event.
    if (this.selectedRows.length > 0) {
      this.dispatchEvent(selectedEvent);
      //this.handleDialogClose();
    } else {
      console.log("Inside getSelectedProblemRecords Error");
      this.showErrorToast("No problem Selected");
    }
    }
}