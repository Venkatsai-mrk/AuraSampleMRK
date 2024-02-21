import { LightningElement, api, track } from 'lwc';
import getICDList from '@salesforce/apex/AddOnlyDiagnosisController.fetchRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import maxRowSelectionDiagnosis from '@salesforce/label/c.Max_Limit_of_Existing_Diagnosis_Selection';

const columns = [
  { label: 'Code Label', fieldName: 'label' },
  { label: 'Code Description', fieldName: 'description' },
  { label: 'ICD Version', fieldName: 'version' },
  { label: 'Diagnosis Type', fieldName: 'diagnosisType' },
  { label: 'Date Diagnoses', fieldName: 'dateOnDiagnoses' },
  { label: 'Notes', fieldName: 'notes' }
    
];
export default class AddOnlyExistingDiagnosis extends LightningElement {
  labelDiagnosis = {maxRowSelectionDiagnosis};
  @api showModal;
  @api patientID;
  @api label;
  @api objectName;
  @api fieldName;
  lastLoadedRecordId = null;
  BATCH_SIZE = 200;
  loadMoreStatus;
  targetDatatable;
  @api selectedRows;
  @track count;
  @track searchValue;
  searchKey = '';
  columns = columns;
  @track data = [];
  error;
  allRecordsLoaded = false;
  searchFlag = false;
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
        this.startRecordId,
        this.lastLoadedRecordId
        );
        this.handleSearch();
  }

  handleSearch() {
    getICDList({
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
        this.data = [...this.data,...result.map(item => ({
          description: item.description,
          label: item.label,
          value: item.value,
          version: item.version,
          diagnosisType: item.diagnosisType,
          notes: item.notes,
          dateOnDiagnoses: item.dateOnDiagnoses
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
    console.log('@@@',this.label,
        this.objectName,
        this.fieldName,
        this.startRecordId,
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

  getSelectedICDRecords() {
    var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
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
      console.log("Inside getSelectedICDRecords Error");
      this.showErrorToast("No ICD Selected");
    }
  }
}