import { LightningElement, api, track } from 'lwc';
import getICDList from '@salesforce/apex/AddOnlyDiagnosisController.fetchTemplateRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  { label: 'ICD Name', fieldName: 'label' },
  { label: 'ICD Description', fieldName: 'description' }
    
];

export default class SearchICDCodesModalNotes extends LightningElement {
    @api label;
  @api objectName;
  @api fieldName;
@api accountId;
  @api selectedRecordId;
  @api selectedRecordName;
  @api ICDSearchParam;
  @api diagnosisVersionChange;
  @api problemName;
  lastLoadedRecordId = null;
  BATCH_SIZE = 200;
  @api showModal;
  loadMoreStatus;
  targetDatatable;
  @api selectedRows;
  @track count;
  @track searchValue;
  searchKey = '';
  @api show() {
    window.console.log("ICD modal Show Called");
    this.showModal = true;
    this.searchKey = "";
    this.handleSearch();
  }
  handleDialogClose() {
      this.showModal = false;
      this.data = [];
      this.searchKey = '';
      this.searchValue = '';
      this.lastLoadedRecordId = null;
      var selectedRecords = [];
      const selectedEvent = new CustomEvent("icdsadded", {detail: { selectedRecords }});
      this.dispatchEvent(selectedEvent);
      this.handleSearch();
  }
  columns = columns;
  @track data = [];
  error;
  allRecordsLoaded = false;
  searchFlag = false;

  handleSearchKey(event) {
    var str = event.detail.value;
    this.searchKey = str.trim();
    if (this.searchKey == "") {
      this.lastLoadedRecordId = null;
      this.data = [];
      this.show();
    }
    if(this.searchKey.length >= 3){
      this.data = [];
      this.lastLoadedRecordId = null;
      this.handleSearch();
      this.searchFlag = true;
    }
    
  }
  handleICDSearch() {
    this.data = [];
    this.lastLoadedRecordId = null;
    this.handleSearch();
  }

  connectedCallback(){
    console.log(this.label,
        this.objectName,
        this.fieldName,
        this.selectedRecordId,
        this.selectedRecordName,
        this.ICDSearchParam,
        this.diagnosisVersionChange,
        this.problemName,this.startRecordId,this.accountId);
        this.handleSearch();
  }

  handleSearch() {
    getICDList({
        objectName: this.objectName,
        filterField: this.fieldName,
        searchString: this.searchKey,
        value: '',
        icdVersion: this.ICDSearchParam,
        accountId: this.accountId,
        filterOnAccountId: false,
        startRecordId: this.lastLoadedRecordId
    })
      .then((result) => {
        this.allRecordsLoaded = false;
        if (this.searchFlag) {
          this.data = [];
          this.searchFlag = false;
        }
        this.data = [...this.data,...result.map(item => ({
          description: item.description,
          label: item.label,
          value: item.value
      }))];
        this.count = this.data.length;
        console.log('data is',JSON.stringify(this.data), 'length is',this.count);
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
        window.console.log("getICDList Function Call NOT Completed!!");
        window.console.log("ERROR : " + error.body.message);
      });
  }
  handleLoadMore(event) {
    try{
    event.preventDefault();
    if (this.allRecordsLoaded) {
      // If all records are already loaded, do nothing.
      return;
    }
    event.target.isLoading = true;
    this.targetDatatable = event.target;
    this.loadMoreStatus = "Loading";
    this.lastLoadedRecordId = this.data[this.data.length - 1].value;
    console.log('###handleLoadMore',this.label,
        this.objectName,
        this.fieldName,
        this.selectedRecordId,
        this.selectedRecordName,
        this.ICDSearchParam,
        this.accountId,
        this.diagnosisVersionChange,
        this.problemName,this.lastLoadedRecordId);
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

  getSelectedICDRecords() {
    var selectedRecords = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();
    console.log("selectedRecords are ", selectedRecords);
    this.selectedRows = selectedRecords;

    console.log("selectedRows are########### ", this.selectedRows);
    //Fire Custom Event
    // Creates the event with the data.
    const selectedEvent = new CustomEvent("icdsadded", {
      detail: { selectedRecords }
    });

    // Dispatches the event.
    if (this.selectedRows.length > 0) {
      this.dispatchEvent(selectedEvent);
      //this.handleDialogClose();
    } else {
        console.log("Inside Error getSelectedICDRecords");
        this.showErrorToast("No ICD Selected");
    }
  }
}