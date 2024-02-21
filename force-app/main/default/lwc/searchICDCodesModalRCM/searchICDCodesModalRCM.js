import { LightningElement, api, track } from 'lwc';
import getICDList from '@salesforce/apex/diagnosisCustomLookupControllerRCM.fetchRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  { label: 'ICD Name', fieldName: 'label' },
  { label: 'ICD Description', fieldName: 'description' }
    
];
export default class SearchICDCodesModalRCM extends LightningElement {
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
  @api selectedRows =[];
  @api deSelectedRows =[];
  @track count;
  @track searchValue;
  searchKey = '';
  excludeIcdCode=[];
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
      const selectedEvent = new CustomEvent("cancelicds", {detail: { selectedRecords }});
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
        this.problemName,this.startRecordId);
        this.deSelectedRows.push(this.selectedRecordId);
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
        startRecordId: this.lastLoadedRecordId,
        
    })
      .then((result) => {
         

  try{
          //alert('result'+ JSON.stringify(result));  
         
          this.allRecordsLoaded = false;
          if (this.searchFlag) {
          this.data = [];
          this.searchFlag = false;
          }
       
          const uniqueResult = result.filter((item) => {
          return !this.data.some((existingItem) => existingItem.value === item.value);
          });

          this.data = [...this.data, ...uniqueResult.map((item) => ({
          description: item.description,
          label: item.label,
          value: item.value
          }))];

          

          this.count = this.data.length;
          if(result.length < this.BATCH_SIZE) {
          // If the number of records loaded is less than the batch size, it means all records are loaded.
          this.allRecordsLoaded = true;
          }

         //Disable a spinner to signal that data has been loaded
         if (this.targetDatatable) this.targetDatatable.isLoading = false;
      }
      
      catch(error)
      {
          alert('error'+error);
      }
         
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
        console.log('this.allRecordsLoaded'+this.allRecordsLoaded);
        if (this.allRecordsLoaded) {
      // If all records are already loaded, do nothing.
         return;
        }
	      if (event && event.target) {
        event.target.isLoading = true;
        this.targetDatatable = event.target;
      
        if (this.data.length > 0) {
        this.lastLoadedRecordId = this.data[this.data.length - 1].value;
        }
        this.handleSearch();
        } 
        else {
        console.error('Invalid event structure:', event);
       }
    }
    catch(error)
    {
       //alert('Error in handleLoadMore:', error);
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

    onRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('selectedRows are', JSON.stringify(selectedRows));
        this.selectedRows = selectedRows;
    }

  getSelectedICDRecords() {
    try {
        // Dispatches the event.
        if (this.selectedRows){

        if(this.selectedRows.length > 0) {
            const selectedRecords = this.selectedRows;
            let deSelectedRecords = this.deSelectedRows;
      const selectedEvent = new CustomEvent("icdsadded", {
      detail: { selectedRecords, deSelectedRecords }
      });
      this.dispatchEvent(selectedEvent);
      // this.handleDialogClose(); // Uncomment if needed
    }
    else {
      console.log("Inside Error @@@@@@@@@@@");
      this.showErrorToast("No ICD Selected");
      }
    }
    
         
    } catch (error) {
        console.error(error);
    }
  }

}