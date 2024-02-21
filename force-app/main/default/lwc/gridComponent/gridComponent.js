import { LightningElement, wire, track, api } from 'lwc';
import getLabOrderList from '@salesforce/apex/LabOrderRecords.getLabOrderList';
//import getHL7 from '@salesforce/apex/LabOrderRecords.getHL7';
import { refreshApex } from '@salesforce/apex';
//import { RecordFieldDataType } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { publish, MessageContext } from 'lightning/messageService';
import fetchRecordIdMC from '@salesforce/messageChannel/FetchLabRecordId__c';
import updateOrderStatus from '@salesforce/apex/OrderAPICallouts.updateOrderStatus';
import updateOrderStatusInhouse from '@salesforce/apex/InHouseLabOrder.updateOrderStatusInHouse';
//import updateRecordStatus from '@salesforce/apex/OrderAPICallouts.updateRecordStatus';
import { NavigationMixin } from 'lightning/navigation';
import getPatientId from '@salesforce/apex/LabOrderDetails.getPatientId';
//Added by Ashwini//
 import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
 import NAME_FIELD from '@salesforce/schema/Account.Name';
 //End Ashwini
//import getObjectFields from '@salesforce/apex/LabOrderRecords.getObjectFields';
//import TickerSymbol from '@salesforce/schema/Account.TickerSymbol';
const columns = [
    {
        label: 'Name',
        fieldName: 'Name',
        type: 'button',
        sortable: "true",
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank', name: 'recLink', variant: 'Base' },
    },{
        label: 'Lab Order #',
        fieldName: 'ElixirSuite__Lab_Order_Req__c',
        sortable: "true",
    },
    { label: 'Lab', fieldName: 'ElixirSuite__LabName__c', sortable: "true"},
    { label: 'Test Name', fieldName: 'ElixirSuite__Test_Name__c', sortable: "true"},
    { label: 'Type', fieldName: 'ElixirSuite__Lab_Type__c', sortable: "true"},
    { label: 'Status', fieldName: 'ElixirSuite__Status__c', sortable: "true" },
    {
        label: 'Created Date',
        fieldName: 'CreatedDate',
        type: 'date',
        sortable: "true",
        typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true }
    },
    {
        label: 'Last Modified Date',
        fieldName: 'LastModifiedDate',
        type: 'date',
        sortable: "true",
        typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true }
    },
    { label: 'Reports', type: "button", typeAttributes: { label: 'Download', name: 'Fetch Record', disabled: { fieldName: 'isActive' }, value: 'Fetch record' } },
    {type: 'action',typeAttributes: {rowActions: [{label: 'Edit',name: 'edit'}]}}
];

const portalColumns = [
    {
        label: 'Name',
        fieldName: 'Name',
        type: 'button',
        sortable: "true",
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank', name: 'recLink', variant: 'Base' },
    },
    { label: 'Test Name', fieldName: 'ElixirSuite__Test_Name__c', sortable: "true"},
    { label: 'Lab', fieldName: 'ElixirSuite__LabName__c', sortable: "true"},
    { label: 'Status', fieldName: 'ElixirSuite__Status__c', sortable: "true" },
    {
        label: 'Lab Order Date',
        fieldName: 'CreatedDate',
        type: 'date',
        sortable: "true",
        typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true }
    },
    { label: 'Reports', type: "button", typeAttributes: { label: 'Download', name: 'Fetch Record', disabled: { fieldName: 'isActive' }, value: 'Fetch record' } }
    ];

const filterOptions = [
    { value: 'All', label: 'All' },
    { value: 'Entered', label: 'Entered' },
    { value: 'Transmitted', label: 'Transmitted' },
    { value: 'Cancelled', label: 'Cancelled' },
    { value: 'Results Received (Partial)', label: 'Results Received (Partial)' },
    { value: 'Results Received', label: 'Results Received' },
    { value: 'eLab', label: 'eLab Orders' },
    { value: 'Manual', label: 'Manual Orders' }
    
];
/*const settingOptions = [
    { value: 'Select field to display', label: 'Select field to display' }
];*/

export default class GridComponent extends NavigationMixin(LightningElement) {
    @track nameSpace='ElixirSuite__';
    @track data;
    @track countRecord;
    columns = columns;
    filterOptions = filterOptions;
    portalColumns=portalColumns;
    //settingOptions = settingOptions;
    @track error;
    @track sortBy;
    @track sortDirection;
    @track itemLength;
    @track searchValue = '';
    @track selectedLabId = [];
    @track selectedLabOrderId = [];
    @track singleSelectedLabId = [];
    @track labOrderIds = [];
    @track showDetailComponent = false;
    @track transmitbutton = true;
    @api searchKey = '';
    @api patientaccountid;
    @api orderidvalue;
    @api activetabdetail;
    @track result;
    @track wiredLaborderList = [];
    @api filterfield;
    @api filteroperator;
    @api filtervalue;
    @track selectedFieldValue = '';
    @track selectedOperatorValue = '';
    @track selectedTextValue = '';
    //for list view toggal
    @track currentFilter = 'All';
    @track isExpanded = false;
    @track filterFieldValue = '';
    @track filterOperatorValue = '';
    @track filterTextValue = '';
    // For Filter Button
    /*@track showFilter = false;
    @track selectedField = '';
    @track selectedOperator = '';
    @track selectedTValue = '';
    @track fields = [];*/
    ShowBtn
    @track communityUser;
    @track profileError;
    @track selectedLabOrderIdInhouse = [];
    @track isNewButtonVisible = true;
@track isLoading = true;
    // constructor(){
    //     console.log('constructor called');
    // }
    
    /*connectedCallback(){
        getProfile()
        .then(result => {
            this.communityUser = result;
            if(this.communityUser == 'Patient'){
                this.ShowBtn=false;
            }
            else{
                this.ShowBtn=true;
            } 
            this.profileError = undefined;
        })
        .catch(error => {
            this.profileError = error;
            this.communityUser = undefined;
        });
        //window.location.reload()
   } */

   @wire(getPatientId)
    wiredPatientId({ data, error }) {
        if (data) {
            // Check if patientId is present
            this.isNewButtonVisible = !data; // Hide the button if patientId is present
        } else if (error) {
            // Handle error
            console.error('Error retrieving patientId', error);
        }
    }
  
  


    @wire(getLabOrderList, { searchKey: '$searchKey', accountid: '$patientaccountid', filterField: '$filterFieldValue', filterOperator: '$filterOperatorValue', filterText: '$filterTextValue' })
    Lab_Orders(result) {
        this.wiredLaborderList = result;
        if (result.data) {
            // this.data = result.data;
            var res = JSON.parse(JSON.stringify(result.data));
            console.log('res---' + JSON.stringify(res));
            res.forEach((element, index) => {
                console.log(index);
            if (element.hasOwnProperty('ElixirSuite__Order__r')) {
            console.log('element.ElixirSuite__Order__r.Name: ' + element.ElixirSuite__Order__r.Name);
            element['OrderNumber'] = element.ElixirSuite__Order__r.Name;
            console.log( 'OrderNumber '+element['OrderNumber']);
            }
            });

            this.data = JSON.parse(JSON.stringify(res));
setTimeout(() => {
                this.isLoading = false;
            }, 3000);
            for (var i = 0; i < this.data.length; i++) {
                this.data[i].isActive = true;
                console.log('Result_Status__c'+ JSON.stringify(this.data[i][this.nameSpace+'Result_Status__c']));
                console.log(JSON.stringify(this.data[i]['Attachments']));
                if (this.data[i][this.nameSpace+'Result_Status__c'] == 'Final results stored and verified' || this.data[i][this.nameSpace+'Result_Status__c'] == 'Some, but not all, results available' || this.data[i][this.nameSpace+'Result_Status__c'] == 'Preliminary results verified and available') {
if (this.data[i]['Attachments'] != undefined) {
                const attachments = this.data[i]['Attachments'];
                for (let j = 0; j < attachments.length; j++) {
                    if (attachments[j].Name.startsWith('pdfReport')) {
                    this.data[i].isActive = false;
// You can break out of the loop if you want to stop checking other attachments
                        // break;
                    }
                }
            }
                }

            }
            //console.log('Account Id'+this.patientaccountid);
            console.log('data lab order ' + JSON.stringify(this.data));
            this.countRecord = result.data.length;

            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
setTimeout(() => {
                this.isLoading = false;
            }, 1000);
        }
        refreshApex(this.wiredLaborderList);
    }




    handleRefresh() {
        //Input of Filter Popup
        this.selectedFieldValue = '';
        this.selectedOperatorValue = '';
        this.selectedTextValue = '';
        //Input of Filter List View
        this.filterFieldValue = '';
        this.filterOperatorValue = '';
        this.filterTextValue = '';
        this.currentFilter = 'All'
        refreshApex(this.wiredLaborderList);
        // console.log('line 80 ' + JSON.stringify(this.result));
        this.searchKey = '';
        this.searchValue = '';
        this.handleSearch();
        console.log('inside refresh' + this.patientaccountid);
    }
    handleFilterRefresh() {
        this.selectedFieldValue = '';
        this.selectedOperatorValue = '';
        this.selectedTextValue = '';
        refreshApex(this.wiredLaborderList);
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

    //for messaging service
    @wire(MessageContext)
    messageContext;

    @api recordId;

    getSelectedName(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('selectedRows' + JSON.stringify(selectedRows));
        this.selectedLabId = [];
        this.selectedLabOrderId = [];
        var allEntered = true; // assume all selected records have status = "Entered"
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++) {
            if(selectedRows[i][this.nameSpace+'Lab_Type__c'] == 'Manual'){
                this.selectedLabOrderIdInhouse.push(selectedRows[i]['Id']);
                if (selectedRows[i].ElixirSuite__Status__c !== 'Entered') {
                    allEntered = false; // if any selected record has status other than "Entered", set allEntered = false
                }
            }
            else{
                // this.selectedLabId=[];
                this.selectedLabId.push(selectedRows[i][this.nameSpace+'Lab_Order_Number__c']);
                this.selectedLabOrderId.push(selectedRows[i]['Id']);
                console.log(JSON.stringify('this.selectedLabId lab order ids '+this.selectedLabOrderId));
                console.log('selectedRows-status' + JSON.stringify(selectedRows[i].ElixirSuite__Status__c));
                console.log('selectedRows-status' + selectedRows[i].ElixirSuite__Status__c);
                if (selectedRows[i].ElixirSuite__Status__c !== 'Entered') {
                    allEntered = false; // if any selected record has status other than "Entered", set allEntered = false
                }
            }
        }
        console.log('selectedLabId' + JSON.stringify(this.selectedLabId));
        this.singleSelectedLabId = [...new Set(this.selectedLabId)];
        this.labOrderIds = [...new Set(this.selectedLabOrderId)];
        console.log(JSON.stringify('this.labOrderIds '+this.labOrderIds));
        console.log(JSON.stringify(this.singleSelectedLabId));
        if ((this.singleSelectedLabId.length > 0 || this.selectedLabOrderIdInhouse.length > 0 ) && allEntered) {
            this.transmitbutton = false;
        } else {
            this.transmitbutton = true;
        }
    }
    handleTransmit() {
        console.log('trasmit');
        if(this.selectedLabOrderIdInhouse.length > 0){
            updateOrderStatusInhouse({labOrderIds: this.selectedLabOrderIdInhouse}).then((result) => {
                    console.log('Transmit Result Manual'+result);
                    if(result)
                    {
                        this.showSuccessToast(); 
                    }
                })
                .catch((error) => {
                    console.log('Error in Transmit Result Manual'+error);
                });
        }
        updateOrderStatus({ orderidvalue: this.singleSelectedLabId, labOrderIds: this.labOrderIds })
            //getInsuranceDetails()
            
            .then((result) => {
                console.log('Transmit Result'+result);
            
                if(result.includes('ERROR'))
                    {
                        this.showErrorToast(result);
                    }
                    else if(result!=null){
                        this.showSuccessToast();
                    }
                //console.log(result);
                //this.data = result.data;
                //this.showDetailComponent = true;
                //this.error = undefined;
            })
            .catch((error) => {
                console.log('Error'+error);
               
                //this.error = result.error;
                //this.data = undefined;
                //window.console.log(this.error);
                // alert(error.body.message + ' error');
            });
        // updateRecordStatus({ orderidvalue: this.singleSelectedLabId, accountid: this.patientaccountid })
        //     //getInsuranceDetails()
        //     .then((result) => {

        //         //this.data = result.data;
        //         //this.showDetailComponent = true;
        //         this.error = undefined;
        //         this.showSuccessToast();

        //     })
        //     .catch((error) => {
        //         this.error = result.error;
        //         this.data = undefined;
        //         window.console.log(this.error);
        //         // alert(error.body.message + ' error');
        //     });



    }
        showSuccessToast() {
            const evt = new ShowToastEvent({
                title: 'success',
                message: 'Lab order transmitted successfully!',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.transmitbutton = true;
            this.handleRefresh();
            this.template.querySelector('lightning-datatable').selectedRows=[];
            //this.selectedLabId = [];
            //this.singleSelectedLabId=[];
        }



        //funtion to fetch the record id from the grid when the record is clicked and then sent it to the display screen component
    fetchrecord(event) {
        const actionName = event.detail.action.name;
        console.log('actionName' + JSON.stringify(actionName));
        const row = event.detail.row;
        console.log('Id '+row.Id);
        console.log('ElixirSuite__Lab_Type__c '+row.ElixirSuite__Lab_Type__c);

        var labOrderId = row.Id;
        var LabTypeName = row.ElixirSuite__Lab_Type__c;
        if(LabTypeName == 'Manual' && actionName !="edit"){
          this.navigateToRecordDetail(labOrderId);
        }
        else{
            console.log('row.ElixirSuite__Status__c '+row.ElixirSuite__Status__c);
            console.log('ElixirSuite__LabOrder_HL7_Results__r '+row.ElixirSuite__LabOrder_HL7_Results__r);
            this.orderidvalue = row[this.nameSpace+'Lab_Order_Number__c'];
            console.log('orderidvalue' + this.orderidvalue);
            console.log('row' + JSON.stringify(row));
            let payload = '';

            switch (actionName) {
            
                case 'recLink':
                    this.recordId = row.Id;
                    payload = { recordId: row.Id };
                    publish(this.messageContext, fetchRecordIdMC, payload);
                    break;

                    
                    case 'edit':
                        console.log('inside edit switch');
                    if(row.ElixirSuite__Status__c === 'Cancelled'){
                        const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'You are not allowed to edit lab orders for canceled tests',
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvent);
                    }else if(row.ElixirSuite__Status__c === 'Transmitted'){
                        const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'You are not allowed to edit transmitted lab orders',
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvent);
                    }else if(row.hasOwnProperty('ElixirSuite__LabOrder_HL7_Results__r')){
                        const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: 'This order cannot be edited',
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvent);
                    }
                    else{
                        console.log('inside edit switch1');
                        console.log(this.patientaccountid);
                        console.log(row.Id);
                        this[NavigationMixin.Navigate]({
                            type: "standard__component",
                        attributes: {
                            componentName: "ElixirSuite__EditOrderCHC"
                        },
                        state: {
                            c__accountId: this.patientaccountid,
                            c__labOrderId: row.Id
                        }
                        });
                     }

                break;
                default:
                    break;
                    
            }
            if (actionName === 'Fetch Record') {
                var url = '/apex/'+this.nameSpace+'LabOrderResults?id='+row.Id;

                window.open(url);
            }
        }
    }
    // Define a function to navigate to a Manual LabOrder record detail page
        navigateToRecordDetail(labOrderId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
            recordId: labOrderId,
            objectApiName: 'ElixirSuite__Lab_Order__c', 
            actionName: 'view',
            },
        });
        }

    //funtion to open the new lab order form
    handleNew() {
        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
        // Fire the custom event
        this.dispatchEvent(closeclickedevt);
        this[NavigationMixin.Navigate]({

            type: "standard__component",
            attributes: {
                componentName: "ElixirSuite__NewOrderCHC"
            },
            state: {
                c__accountId: this.patientaccountid
            }
        });


    }

    //function to start the serach process by refreshin the apex code with searchkey
    handleSearch() {
            console.log('Inside Handle search************');
            let searchCmp = this.template.querySelector(".searchInput");
            let searchval = searchCmp.value;

            if (searchval.length < 3 && searchval.length > 0) {
                searchCmp.setCustomValidity("Enter atleast 3 letters");

            } else {
                searchCmp.setCustomValidity(""); // clear previous value
            }

            console.log(searchval);
            searchCmp.reportValidity();
            if (this.searchValue.length >= 3) {

                this.searchKey = this.searchValue;
                return refreshApex(this.result);

            }

        }
        //funtion to fetch the Search value
    handleSearchKey(event) {
        this.searchValue = event.target.value;
        if (this.searchValue == '') {
            this.handleRefresh();
        }
    }

    handleKey(component) {
            if (component.which == 13) {
                this.handleSearch();
            }
        }
        //For List View Filter
    get dropdownTriggerClass() {
        if (this.isExpanded) {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view slds-is-open dropDown '
        } else {
            return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click custom_list_view dropDown '
        }
    }
    handleFilterChangeButton(event) {
        let filter = event.target.dataset.filter;
        this.isExpanded = !this.isExpanded;
        if (filter !== this.currentFilter) {
            this.currentFilter = event.target.dataset.filter;
            setTimeout(() => {
                this.handleFilterData(this.currentFilter), 0
            });
        }
    }

    handleFilterData(filter) {
        if (filter === 'All') {
            this.handleRefresh();
        } else if (filter === 'Entered') {
            this.filterFieldValue = 'ElixirSuite__Status__c';
            this.filterOperatorValue = '=';
            this.filterTextValue = 'E';
        } else if (filter === 'Transmitted') {
            this.filterFieldValue = 'ElixirSuite__Status__c';
            this.filterOperatorValue = '=';
            this.filterTextValue = 'R';
        }
        else if (filter === 'Cancelled') {
            this.filterFieldValue = 'ElixirSuite__Status__c';
            this.filterOperatorValue = '=';
            this.filterTextValue = 'C';
        }
        else if (filter === 'Results Received (Partial)') {
            this.filterFieldValue = 'ElixirSuite__Status__c';
            this.filterOperatorValue = '=';
            this.filterTextValue = 'Results Received (Partial)';
        }
        else if (filter === 'Results Received') {
            this.filterFieldValue = 'ElixirSuite__Status__c';
            this.filterOperatorValue = '=';
            this.filterTextValue = 'Results Received';
        }
        else if (filter === 'eLab') {
            this.filterFieldValue = 'ElixirSuite__Lab_Type__c';
            this.filterOperatorValue = '=';
            this.filterTextValue = 'eLab';
        }
        else if (filter === 'Manual') {
            this.filterFieldValue = 'ElixirSuite__Lab_Type__c';
            this.filterOperatorValue = '=';
            this.filterTextValue = 'Manual';
        }
    }
    //Added by Ashwini
    navToListView() {
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
    @wire(getRecord, { recordId: '$patientaccountid', fields: [NAME_FIELD] })
    accName;
    get AccountName() {
        return getFieldValue(this.accName.data,NAME_FIELD);
    }
    navToAccRecord(event) {
        event.preventDefault();
        //your custom navigation here
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
               recordId: this.patientaccountid,
               objectApiName: 'Account',
               actionName: 'view'
            },
        });
        
    }
    //End Ashwini

    handleFilterClickExtend() {
            this.isExpanded = !this.isExpanded;
        }
        //Filter PopUp  Handlers
        /* handleFilter() {
                 this.showFilter = true;
                 this.handleGetFieldOption();
             }*/
        /*  onFilterAddition(event) {

            this.selectedFieldValue = event.detail.fieldValue;
            this.selectedOperatorValue = event.detail.OperatorValue;
            this.selectedTextValue = event.detail.TextValue;
    
            console.log('Inside onFilterAddition 1 : ' + this.selectedFieldValue);
            console.log('Inside onFilterAddition 2 : ' + this.selectedOperatorValue);
            console.log('Inside onFilterAddition 3 : ' + this.selectedTextValue);
        }*/

    /*handleGetFieldOption() {
        getObjectFields()
            .then((result) => {
                //this.facilities = result;
                this.error = undefined;
                for (const [key, value] of Object.entries(result)) {
                    this.fields = [...this.fields, { value: key, label: value }];

                    // console.log(`${key}: ${value}`);
                }
                console.log('Map return Value @@@@@@@@@@' + JSON.stringify(this.fields));
            })
            .catch((error) => {
                this.error = error;
            });

    }
    get fieldOptions() {
        console.log('Inside FieldOption' + this.fields);
        return this.fields;
    }
    handleFieldOption(event) {
        this.selectedField = event.detail.value;
        // console.log('Inside Handle Field' + this.selectedField);

    }
    get operatorOptions() {
        var optionList = [{ value: '=', label: 'Equal to' }, { value: '!=', label: 'Not equals to' }, { value: 'LIKE', label: 'Contains' }, { value: '>', label: 'Greater than' }, { value: '<', label: 'Less than' }, { value: '<=', label: 'Less or equal' }, { value: '>=', label: 'Greater or equal' }];
        return optionList;
    }
    handleOperatorChange(event) {
        this.selectedOperator = event.detail.value;
        //console.log('Inside Handle Operator' + this.selectedOperator);
    }
    handleFieldValue(event) {
        this.selectedTValue = event.detail.value;
        //console.log('Inside Handle Value' + selectedTValue);
    }
    handleApplyFilter() {
        console.log('Inside handle Apply Filter ########');
        this.selectedFieldValue = this.selectedField;
        this.selectedOperatorValue = this.selectedOperator;
        this.selectedTextValue = this.selectedTValue;
        console.log('Inside Handle Apply Filter 1 :  ' + this.selectedFieldValue);
        console.log('Inside Handle Apply Filter 2 :  ' + this.selectedOperatorValue);
        console.log('Inside Handle Apply Filter 3 :  ' + this.selectedTextValue);
        //this.handleFilterDialogClose();
    }

    handleFilterDialogClose() {
        this.showFilter = false;
        // this.handleFilterClearAll();

    }
    handleFilterClearAll() {
        this.selectedField = '';
        this.selectedOperator = '';
        this.selectedTValue = '';

    }*/
}