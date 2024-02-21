import { LightningElement, track, wire, api } from 'lwc';
//import getPrescriptions from '@salesforce/apex/NC_Subscription.getPrescriptions';
import newPrescription from '@salesforce/apex/NewcropCallouts.newPrescription';
// import fetchPrescription from '@salesforce/apex/NewcropCallouts.fetchPrescription';
import getFieldsFromCustomSetting from '@salesforce/apex/PrescriptionColumnConfigurationClass.getFieldsFromCustomSetting';
import getObjectFields from '@salesforce/apex/PrescriptionColumnConfigurationClass.getObjectFields';
import getPrescriptionBySearch from '@salesforce/apex/newCropPresSearch.getPrescriptionBySearch';
import getPrescriptionByStatus from '@salesforce/apex/newCropPresSearch.getPrescriptionByStatus';
import getUserInfo from '@salesforce/apex/newCropPresSearch.getUserInfo';
import getUserType from '@salesforce/apex/newCropPresSearch.getUserType';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getAccountId from '@salesforce/apex/UpcomingAppointmentController.getAccountId';
import getProfile from '@salesforce/apex/UpcomingAppointmentController.getProfile';
//Added by Ashwini//
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import NewCrop_Screen_Header from '@salesforce/label/c.NewCrop_Screen_Header';
//End Ashwini
//import getData from '@salesforce/apex/LabTestController.getData';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
const filterOptions = [
    { value: 'All', label: 'All' },
    { value: 'Active Medications', label: 'Active Medications' },
    { value: 'Inactive Medications', label: 'Inactive Medications' },
    { value: 'All Medications', label: 'All Medications' },
    { value: 'Completed Order', label: 'Completed Order' },
    { value: 'Pending Order', label: 'Pending Order' },
    { value: 'All Orders', label: 'All Orders' }

];

const cols = [
    { label: 'Name', fieldName: 'Name', type: 'text', hideDefaultActions: 'true' },
    { label: 'Drug Name', fieldName: 'ElixirSuite__Drug_Name__c', type: 'text', hideDefaultActions: 'true', sortable: "true" },
    { label: 'Drug Info', fieldName: 'ElixirSuite__Reason_new__c', type: 'text', hideDefaultActions: 'true', sortable: "true" },
    { label: 'SIG', fieldName: 'ElixirSuite__Patient_SIG__c', type: 'text', hideDefaultActions: 'true', sortable: "true" },
    { label: 'Refills', fieldName: 'ElixirSuite__Refills__c', type: 'text', hideDefaultActions: 'true', sortable: "true" },
    { label: 'Order Status', fieldName: 'ElixirSuite__Status_NC__c', type: 'text', hideDefaultActions: 'true', sortable: "true" },
    { label: 'Drug Status', fieldName: 'ElixirSuite__Archive_Status_NC__c', type: 'text', hideDefaultActions: 'true', sortable: "true" },
   // { label: 'Edit Rx', fieldName: 'ElixirSuite__IsEditButtonActive__c', type: 'button', hideDefaultActions: 'true', typeAttributes: { label: 'Edit', disabled: { fieldName: 'ElixirSuite__IsEditButtonActive__c' }, target: '_blank', name: 'edit', varient: 'brand-outline' } }
];



export default class NewCropPrescriptions extends NavigationMixin(LightningElement) {
    @track defaultCols = cols;
    // @track defaultCols=[];
    @api recordVal;
    page = '';
    @track wiredCHCList = [];
    @track wiredNewList = [];
    @track data;
    @track uData = '';
    filterOptions = filterOptions;
    // mapOfApiAndLabel=mapOfApiAndLabel;
    //allTextColumns=allTextColumns;
    @track isExpanded = false;
    @track currentFilter = 'All';
    @track filterTextValue = '';
    @track Status = '%';
    handleSearch() { }
    keySearch() { }
    handleSearchKey() { }
    @track pageName = '';
    @track openVf = false;
    //  booleanValue=true;
    
      selectedFields = [];
      labelToApiList = [];
      objectInfo;
     
    customLabel = NewCrop_Screen_Header;

    @wire(getUserInfo)
    wiredUser(result) {
        // this.wiredCHCList = result;
        if (result.data) {
            console.log('Lucky' + result.data);
            this.uData = result.data;
            console.log(this.uData);

        }
        else {
            console.log(result.error);
        }

    }
    @wire(getObjectInfo, { objectApiName: 'ElixirSuite__Prescription_Order__c' })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.objectInfo = data;
            this.handleObjectInfo();
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    handleObjectInfo() {
        console.log('handleObjectInfo invoked');

        if (this.objectInfo) {
            console.log('Data received:', this.objectInfo);

            const fields = this.objectInfo.fields;
            const fieldList = Object.keys(fields).map(apiName => {
                const field = fields[apiName];
                return {
                    label: field.label,
                    fieldName: apiName,
                    dataType: field.dataType,
                    hideDefaultActions: true,
                    sortable: true,
                };
            });

            this.labelToApiList = fieldList;
            console.log('INIT labelToApiList ===' + JSON.stringify(this.labelToApiList));
            console.log('fieldList', fieldList);
            console.log('Field List:', fieldList);
        }
    }



    generateColumns(selectedFieldsLst) {
    console.log('labelToApiList===' + JSON.stringify(this.labelToApiList));

   // const dynamicCols = [];
   // console.log('dynamicCols Before: ' + JSON.stringify(selectedFieldsLst));
    selectedFieldsLst.forEach(fieldName => {
        let reqField = this.labelToApiList.find(field => field.fieldName === fieldName);

        if (reqField) {
            let label = reqField.label;
            let dataType = reqField.dataType;

            defaultCols.push({
                label: label,
                fieldName: fieldName,
                type: dataType,
                sortable: true,
                hideDefaultActions: true,
            });
           
        } else {
            console.error(`Field "${fieldName}" not found in labelToApiList.`);
        }
    });
      }


    navigateToNewCrop() {
        var flag = this.uData;
        console.log(flag);
        if (flag == '1') {
            const event = new ShowToastEvent({
                title: 'Mandatory Fields!',
                message: 'Please provide the required information on User Setup \n UserType \n RoleType',
                variant: 'warning',
                mode: 'sticky'

            });
            this.dispatchEvent(event);
        }
        else if (flag == '2') {
            const event = new ShowToastEvent({
                title: 'Mandatory Fields!',
                message: 'Please provide the required information on User Setup \n Phone \n Fax \n License  \n Site Id \n City \n State \n PostalCode \n Street \n Country',
                variant: 'warning',
                mode: 'sticky'

            });
            this.dispatchEvent(event);
        }
        else if (flag == '3') {
            const event = new ShowToastEvent({
                title: 'Mandatory Fields!',
                message: 'Please provide the required information on User Setup \n Phone \n Fax \n Site Id \n City \n State \n PostalCode \n Street \n Country',
                variant: 'warning',
                mode: 'sticky'

            });
            this.dispatchEvent(event);
        }
        else if (flag == '0') {
            this.openVf = true;
            this.pageName = 'newcropScript';
            this.page = 'compose';
            console.log("Open");

        }
    }
     /*fetchDataFromCustomSetting() {
        getFieldsFromCustomSetting()
             .then(result => {
                // Remove duplicates and add fields to selectedFields
               const uniqueFields = [...new Set([...this.selectedFields, ...result])];
                this.selectedFields = uniqueFields;
                  console.log('selectedFields from custom setting in parent:', JSON.stringify(this.selectedFields));
                console.log('Fields from custom setting in parent:', JSON.stringify(result));
                this.generateColumns(this.selectedFields);
                console.log('generateColumns:');
            })
            .catch(error => {
                // Handle errors (e.g., log to console)
                console.error('Error fetching fields from custom setting:', error);
            });
    }*/

    fetchCustomSettingFields() {
    Promise.all([getObjectFields(), getFieldsFromCustomSetting()])
        .then(([objectData, customSettingFields]) => {
            // Create a map to quickly look up the index of each custom setting field
            console.log('in the custom setting')
            const customSettingFieldIndex = {};
            customSettingFields.forEach((field, index) => {
                customSettingFieldIndex[field] = index;
            });

            // Filter object fields based on custom setting fields and order them
            //this.defaultCols = objectData
            // Filter object fields based on custom setting fields and order them
            const newCols = objectData
                .filter(fieldInfo => customSettingFields.includes(fieldInfo.apiName))
                .sort((a, b) => customSettingFieldIndex[a.apiName] - customSettingFieldIndex[b.apiName])
                .map(fieldInfo => ({
                    label: fieldInfo.label,
                    fieldName: fieldInfo.apiName,
                    type: 'text',
                    sortable: true,
                }));
                
            // Combine the existing defaultCols with the newCols
           // this.defaultCols = [];
           // Create a new array with newCols and cols

            
             var updatedCols = [...cols, ...newCols];
             
           
            // Add 'Edit Rx' button
            updatedCols.push({
                label: 'Edit Rx',
                fieldName: 'ElixirSuite__IsEditButtonActive__c',
                type: 'button',
                hideDefaultActions: 'true',
                typeAttributes: {
                    label: 'Edit',
                    disabled: { fieldName: 'ElixirSuite__IsEditButtonActive__c' },
                    target: '_blank',
                    name: 'edit',
                    varient: 'brand-outline'
                }
            });

            this.defaultCols = updatedCols;
 
        })
        .catch(error => {
            var updatedCols = [...cols];
             
           
            // Add 'Edit Rx' button
            updatedCols.push({
                label: 'Edit Rx',
                fieldName: 'ElixirSuite__IsEditButtonActive__c',
                type: 'button',
                hideDefaultActions: 'true',
                typeAttributes: {
                    label: 'Edit',
                    disabled: { fieldName: 'ElixirSuite__IsEditButtonActive__c' },
                    target: '_blank',
                    name: 'edit',
                    varient: 'brand-outline'
                }
            });

            this.defaultCols = updatedCols;
            console.error('Error fetching data:', error);
            // Handle specific error scenarios if needed
        });
}
    handleCallMethodEvent(){
        console.log('Open');
        this.fetchCustomSettingFields();
        this.handleRefreshCalls();
        refreshApex(this.wiredNewList);
     }

    hideModalBox() {
        this.openVf = false;
        this.handleRefreshCalls();
        refreshApex(this.wiredNewList);
    }

    navigateToNewCropMedEntry() {
        this.pageName = 'newcropScript';
        this.page = 'medentry';
        this.openVf = true;

    }


    
  

    visible;

    @wire(getUserType)
    wiredUserType(result) {
        // this.wiredCHCList = result;
        if (result.data) {
            console.log('Lucky' + result.data);
            this.visible = result.data;
            this.visible = !this.visible;
            if (this.visible) {
                this.columns = [...cols];
            } else {
                // return every column but the one you want to hide
                this.columns = [...cols].filter(col => col.fieldName != 'ElixirSuite__IsEditButtonActive__c');
            }

        }
        else {
            console.log(result.error);
        }

    }


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

    get dropdownTriggerClass() {
        if (this.isExpanded) {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-is-open dropDown '
        } else {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view dropDown'
        }
    }
    handleFilterChangeButton(event) {
        //let filter = event.target.dataset.filter;
        this.isExpanded = !this.isExpanded;
        // this.booleanValue=false;

        this.currentFilter = event.target.dataset.filter;
        console.log('this.currentFilter' + this.currentFilter);
        setTimeout(() => {
            this.handleFilterData(this.currentFilter), 0
        });

    }

    handleFilterData(filter) {
        if (filter === 'All') {
            // this.data = this.wiredCHCList;
            //this.filterTextValue ='';
            this.filterTextValue = 'N';
        }
        else if (filter === 'Active Medications') {

            this.filterTextValue = 'N';
        }
        else if (filter === 'Inactive Medications') {

            this.filterTextValue = 'Y';
        }
        else if (filter === 'All Medications') {

            this.data = this.wiredCHCList;
        }
        else if (filter === 'Completed Order') {

            this.filterTextValue = 'C';
        } else if (filter === 'Pending Order') {

            this.filterTextValue = 'P';
        }
        else if (filter === 'All Orders') {

            this.data = this.wiredCHCList;
        }


    }
    handleFilterClickExtend() {
        this.isExpanded = !this.isExpanded;
    }




    @track patientAccount;
    @track patientAccountError;
    ShowBtn;
    @track communityUser;
    @track profileError;


    constructor() {
    super();
    if (this.objectInfo) {
            console.log('this.objectInfo', this.objectInfo);
            this.handleObjectInfo();
        }
    }


    renderedCallback() {
        if (this.objectInfo) {
            console.log('this.objectInfo', this.objectInfo);
            this.handleObjectInfo();
        }
    }

    connectedCallback() {
        
         if (this.objectInfo) {
             console.log('this.objectInfo '+this.objectInfo);
            this.handleObjectInfo();
        }
         refreshApex(this.ObjectInfo);
            this.fetchCustomSettingFields();
       this.handleRefreshCalls();
        this.handleFilterData(this.currentFilter);
        console.log('this.labelToApiList'+this.labelToApiList);
        getAccountId()
            .then(result => {
                console.log('Community result data ' + result);
                if (result != '' && result != null) {
                    this.recordVal = result;
                }

                console.log('this.recordVal result data ' + this.recordVal);

            })
            .catch(error => {
                console.log('reeoe' + JSON.stringify(error));
            });
        getProfile()
            .then(result => {
                this.communityUser = result;
                if (this.communityUser == 'Patient') {
                    this.ShowBtn = false;
                }
                else {
                    this.ShowBtn = true;
                }
                this.profileError = undefined;
                 this.handleRefresh();
            })
            .catch(error => {
                this.profileError = error;
                this.communityUser = undefined;
            });

            
    }

    handleRefreshCalls() {
console.log('handle 2');
        newPrescription({ accId: this.recordVal, status: this.Status })

            .then(result => {


                console.log('result data ' + JSON.stringify(result));
                // Update the ElixirSuite__Status_NC__c based on conditions

                result.forEach(prescription => {
                    if (prescription.ElixirSuite__Status_NC__c === 'C') {
                        prescription.ElixirSuite__Status_NC__c = 'Completed';
                    } else if (prescription.ElixirSuite__Status_NC__c === 'P') {
                        prescription.ElixirSuite__Status_NC__c = 'Pending';
                    }
                    if (prescription.ElixirSuite__Archive_Status_NC__c === 'N') {
                        prescription.ElixirSuite__Archive_Status_NC__c = 'Active';
                    }
                    if (prescription.ElixirSuite__Archive_Status_NC__c === 'Y') {
                        prescription.ElixirSuite__Archive_Status_NC__c = 'Inactive';
                    }
                });



                console.log('result data ' + JSON.stringify(result));
                this.data = result;
                this.wiredCHCList = result;
               
            })

            .catch(error => {

                console.log('Error in Handle Refresh Call' + JSON.stringify(error));

            });

    }
    handleRefresh() {
        this.handleRefreshCalls();
        console.log('handle 1');
        refreshApex(this.ObjectInfo);
       // this.fetchDataFromCustomSetting();
        
        refreshApex(this.wiredNewList);
    }
    /* handleclick(){
          var iframeh=this.template.querySelector('[data-id="iframe"]');
        
         iframeh.style.display = "block";
         iframeh.style.height ='960px';
        
        iframeh.src = '../apex/newcropScript?recordId=' + this.recordVal;
      
         
     }*/

    searchValue = '';

    // update searchValue var when input field value change
    searchKeyword(event) {
        this.searchValue = event.target.value;
        this.data = this.wiredCHCList;
    }

    // call apex method on button click 
    handleSearchKeyword() {

        if (this.searchValue !== '') {
            getPrescriptionBySearch({
                keySearch: this.searchValue, accId: this.recordVal
            })
                .then(result => {
                    console.log('result for Handle seaerch ====' + JSON.stringify(result));
                    // Clone the data to avoid modifying the original object
                    const prescriptions = JSON.parse(JSON.stringify(result));
                    prescriptions.forEach(prescription => {
                        if (prescription.ElixirSuite__Status_NC__c === 'C') {
                            prescription.ElixirSuite__Status_NC__c = 'Completed';
                        } else if (prescription.ElixirSuite__Status_NC__c === 'P') {
                            prescription.ElixirSuite__Status_NC__c = 'Pending';
                        }
                        if (prescription.ElixirSuite__Archive_Status_NC__c === 'N') {
                            prescription.ElixirSuite__Archive_Status_NC__c = 'Active';
                        }
                        if (prescription.ElixirSuite__Archive_Status_NC__c === 'Y') {
                            prescription.ElixirSuite__Archive_Status_NC__c = 'Inactive';
                        }
                    });

                    this.data = prescriptions;
                    console.log('this.data' + JSON.stringify(this.data));
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body ? error.body.message : 'An error occurred while fetching data.',
                    });
                    this.dispatchEvent(event);
                    this.data = null; // Reset data in case of an error
                });
        } else {
            // Handle the case where searchValue is empty
            this.data = this.wiredCHCList;
            const event = new ShowToastEvent({
                variant: 'error',
                message: 'Search text missing..',
            });
            this.dispatchEvent(event);
        }
    }


    //Added by Ashwini
    navToListView(event) {
        // event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }

        });
        //your custom navigation here
    }
    @wire(getRecord, { recordId: '$recordVal', fields: [NAME_FIELD] })
    accName;
    get AccountName() {
        return getFieldValue(this.accName.data, NAME_FIELD);
    }
    navToAccRecord(event) {
        event.preventDefault();
        //your custom navigation here
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordVal,
                objectApiName: 'Account',
                actionName: 'view'
            },
        });

    }
    //End Ashwini

    @wire(getPrescriptionByStatus, { accId: '$recordVal', status: '$filterTextValue' })
    wiredRecords(result) {
        // this.wiredCHCList =wiredRecords result;

        if (result.data) {
            var result = result.data;

            // Clone the data to avoid modifying the original object
            const prescriptions = JSON.parse(JSON.stringify(result));

            prescriptions.forEach(prescription => {
                if (prescription.ElixirSuite__Status_NC__c === 'C') {
                    prescription.ElixirSuite__Status_NC__c = 'Completed';
                } else if (prescription.ElixirSuite__Status_NC__c === 'P') {
                    prescription.ElixirSuite__Status_NC__c = 'Pending';
                }
                if (prescription.ElixirSuite__Archive_Status_NC__c === 'N') {
                    prescription.ElixirSuite__Archive_Status_NC__c = 'Active';
                }
                if (prescription.ElixirSuite__Archive_Status_NC__c === 'Y') {
                    prescription.ElixirSuite__Archive_Status_NC__c = 'Inactive';
                }
            });

            this.data = prescriptions;
            this.wiredNewList = prescriptions;
            console.log('this.data' + this.data);
            console.log('Data ====' + JSON.stringify(this.data));
            console.log(' this.wiredNewList' + this.wiredNewList);
            console.log('wiredNewList' + JSON.stringify(this.wiredNewList));
        }
        else {
            console.log(result.error);
        }
        refreshApex(this.wiredNewList);
    }

    fetchrecord(event) {
        const actionName = event.detail.action.name;
        console.log('actionName' + JSON.stringify(actionName));
        var rowId = event.detail.row.ElixirSuite__Prescription_Guid__c;
        // this.orderidvalue = row[this.Name];
        // console.log('orderidvalue' + this.orderidvalue);
        console.log('row' + JSON.stringify(rowId));

        //alert(row.Id);
        switch (actionName) {
            case 'edit':

                this.openVf = true;
                this.page = rowId;
                this.pageName = 'Nc_EditScript';


                break;

            default:
                break;
        }

    }


}