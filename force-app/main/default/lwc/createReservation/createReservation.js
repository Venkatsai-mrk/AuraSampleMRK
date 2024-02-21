import { LightningElement, api, track, wire } from 'lwc';
import RESERVATION_OBJECT from '@salesforce/schema/Reservation__c'
import ACCOUNT from '@salesforce/schema/Reservation__c.Account__c';
import START_DATE from '@salesforce/schema/Reservation__c.Start_Date__c';
import END_DATE from '@salesforce/schema/Reservation__c.End_Date__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllBuildings from '@salesforce/apex/CreateReservation.getAllBuildings';
//import getPicklistValues from '@salesforce/apex/CreateReservation.getPicklistValues';
import getAvailableBeds from '@salesforce/apex/CreateReservation.getAvailableBeds';
import saveRecord from '@salesforce/apex/CreateReservation.saveReservationData';
import getAttributes from '@salesforce/apex/CreateReservation.getAttributes';
import overlappingReservation from '@salesforce/apex/CreateReservation.overlappingReservation';
import getColumnsToDisplay from '@salesforce/apex/CreateReservation.getColumnsToDisplay';
import { NavigationMixin } from 'lightning/navigation';
import LightningConfirm from 'lightning/confirm';
import { CurrentPageReference } from 'lightning/navigation';
import getUserDate from '@salesforce/apex/CreateReservation.getUserDate';
import RESERVATION_TYPE_FIELD from '@salesforce/schema/Reservation__c.Reservation_Type__c';
import Reservation_Schedule_Reservation_Type from '@salesforce/label/c.Reservation_Schedule_Reservation_Type';
import Reservation_Reservation_Type_Default from '@salesforce/label/c.Reservation_Reservation_Type_Default';
import { getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi'


export default class CreateReservation extends NavigationMixin(LightningElement) {

    userDate;
    labelValue = Reservation_Schedule_Reservation_Type;
    defaultValue = Reservation_Reservation_Type_Default;

    @track selectedValue = '';
    @track picklistOptions = [];

    

   
   
    async handleConfirmClick() {
        const result = await LightningConfirm.open({
            message: 'This reservation overlaps with an existing reservation. Are you sure you want to create this?',
            variant: 'header',
            label: 'Please confirm',
            theme: 'shade'
        });
        return result;
    }

   

    @track showDialog = false;

    reservationObjectApi = RESERVATION_OBJECT;
    accountField = ACCOUNT;
    startDateField = START_DATE;
    endDateField = END_DATE;
    filterState = true;
    error;
    options = [];
    selectedBuildings = [];
    selectedRoomType = [];
    @track selectedBeds = [];
    privateAccountId;
    showRoom = true;
    showBed = true;
    showSuite = true;
    selectedFeatureValues = [];
    suiteAttributes;
    roomAttributes;
    bedAttributes;

    @api
    get accountId() {
        return this.privateAccountId;
    }

    set accountId(value) {
        this.privateAccountId = value;
    }

    @api isAccountIdPrePopulated;

    startDate;
    minimumStartDate = new Date();
    endDate;

    @track allTableRows = [];
    tableRow = {
        type: '',
        styleClass: '',
        buildingId: '',
        buildingName: '',
        buildingNameBak: '',
        suiteId: '',
        suiteName: '',
        roomId: '',
        roomName: '',
        bedId: '',
        bedName: '',
        features: '',
    }
    // Create a new array to store the common IDs of allTableRows & selectedBeds
    // The selectedBeds array will now contain the selected bed objects from allTableRows
    selectedBedIds = [];
    @track isSaveButtonDisabled = false;
    @track isSaveAndNewButtonDisabled = false;
    isNewReservation = false;


    get areTableRowsAvailable() {
        return this.allTableRows.length > 0;
    }

    loadingRecords = false;

    @wire(CurrentPageReference)
    pageRef;

    onlyFullyAvailableRoomsAndSuites = false;
    onlyFullyAvailableRooms = false;
    onlyFullyAvailableSuites = false;
    
    toggleOnlyFullyAvailableRoomsAndSuites() {
        this.onlyFullyAvailableRoomsAndSuites = !this.onlyFullyAvailableRoomsAndSuites;
        this.refreshSearchResults();
    }
    toggleOnlyFullyAvailableRooms() {
        this.onlyFullyAvailableRooms = !this.onlyFullyAvailableRooms;
        this.refreshSearchResults();
    }

    toggleOnlyFullyAvailableSuites() {
        this.onlyFullyAvailableSuites = !this.onlyFullyAvailableSuites;
        this.refreshSearchResults();
    }

    getColumnsToDisplayInTable() {
        getColumnsToDisplay()
            .then(result => {
                console.log('Columns to display ', result);
                // Hide all Building columns
                if (result.includes('BUILDINGS')) {
                    const hideBuildingTHs = this.template.querySelectorAll('th[data-label="building-col"]');
                    hideBuildingTHs.forEach(th => th.classList.add("slds-hide"));
    
                    const hideBuildingTDs = this.template.querySelectorAll('td[data-label="Building"]');
                    hideBuildingTDs.forEach(td => td.classList.add("slds-hide"));
                }
    
                // Hide all suite columns
                if (result.includes('SUITES')) {
                    const hideSuiteTHs = this.template.querySelectorAll('th[data-label="suite-col"]');
                    hideSuiteTHs.forEach(th => th.classList.add("slds-hide"));
    
                    const hideSuiteTDs = this.template.querySelectorAll('td[data-label="Suite"]');
                    hideSuiteTDs.forEach(td => td.classList.add("slds-hide"));
                }
    
                // Hide all room columns
                if (result.includes('ROOMS')) {
                    const hideRoomTHs = this.template.querySelectorAll('th[data-label="rooms-col"]');
                    hideRoomTHs.forEach(th => th.classList.add("slds-hide"));
    
                    const hideRoomTDs = this.template.querySelectorAll('td[data-label="Room"]');
                    hideRoomTDs.forEach(td => td.classList.add("slds-hide"));
                }
    
                // Hide all bed columns
                if (result.includes('BEDS')) {
                    const hideBedTHs = this.template.querySelectorAll('th[data-label="beds-col"]');
                    hideBedTHs.forEach(th => th.classList.add("slds-hide"));
    
                    const hideBedTDs = this.template.querySelectorAll('td[data-label="Bed"]');
                    hideBedTDs.forEach(td => td.classList.add("slds-hide"));
                }

                // Hide all features columns
                if (result.includes('FEATURES')) {
                    const hideFeaturesHs = this.template.querySelectorAll('th[data-label="features-col"]');
                    hideFeaturesHs.forEach(th => th.classList.add("slds-hide"));
    
                    const hideFeaturesTDs = this.template.querySelectorAll('td[data-label="Features"]');
                    hideFeaturesTDs.forEach(td => td.classList.add("slds-hide"));
                }
    
            })
            .catch(error => {
                this.error = error;
            });
    }
    

    connectedCallback() {
        console.log('helloWorld: ', this.pageRef);
        // this.overlappingReservationState();
       
        this.getBuildingsOptions();
        this.getPicklistValuesForTypes();
        this.callCurrentUserMethod();
        console.log('labelValue', this.labelValue);
        console.log('defaultValue', this.defaultValue);
        
    }
    
    @wire(getObjectInfo, {objectApiName:RESERVATION_OBJECT})
    objectInfo
 

    @wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId', fieldApiName:RESERVATION_TYPE_FIELD})
    wiredPicklistValues({ error, data }) {
        console.log('data of wiredPicklistValues '+JSON.stringify(data));
        console.log('error '+error);
        if (data) {
            this.picklistOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
            this.selectedValue=this.defaultValue;
            console.log('picklistOptions', JSON.stringify(this.picklistOptions));
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }
    callCurrentUserMethod() {
        getUserDate()
            .then(result => {
                console.log('result', result);
                // Handle the result here
                this.userDate = result;
                console.log('today', this.userDate);
            })
            .catch(error => {
                console.error('Error calling Apex method: ' + error.body.message);
            });
    }

    haveOverlappingReservation = false;
    overlappingReservationState() {
        return overlappingReservation({ accountId: this.privateAccountId,
                                startDate: this.startDate,
                                endDate: this.endDate
                                })
            .then((result) => {
                console.log('This account has any overlapping reservation = ', result);
                this.haveOverlappingReservation = result;
            })
            .catch((error) => {
                this.error = error;
            });
    }

    getBuildingsOptions() {
        getAllBuildings()
            .then(result => {
                console.log('Data received = ', result);
                console.log('List length', result.length);
                console.log(result[0].Id)
                if (result) {
                    for (var i = 0; i < result.length; i++) {
                        this.options = [...this.options, { label: result[i].Name, value: result[i].Id }];
                    }
                    console.log('this are the options ', JSON.stringify(this.options));
                }
            })
            .catch(error => {
                this.error = error;
            });
    }
    showList = true;
    valuesArray = [];
    selectedValue = '';
    roomFeatures = [];
    bedFeatures = [];
    suiteFeatures = [];

    getPicklistValuesForTypes() {
        getAttributes()
            .then(result => {
                console.log('These are the expected values for picklist ', JSON.stringify(result));

                this.valuesArray = Object.entries(result)
                    .flatMap(([, value]) => Object.entries(value).map(([value, label]) => ({ value, label })));

                this.bedFeatures = Object.entries(result.bedAttributes).map(([key, label]) => ({ value: key, label }));
                this.roomFeatures = Object.entries(result.roomAttributes).map(([key, label]) => ({ value: key, label }));
                this.suiteFeatures = Object.entries(result.suitesAttributes).map(([key, label]) => ({ value: key, label }));

                console.log('roomFeatures = ', this.roomFeatures);
                console.log('bedFeatures = ', this.bedFeatures);
                console.log('suitesAttributes = ', this.suiteFeatures);
            })
            .catch(error => {
                console.log('This is error ', error)
            })
    }

    selectedLabels = []
    selectedAttributeValues = []

   
    refreshSelectedItems() {
        const roomSelectedElements = this.template.querySelectorAll('.room-selected');
        if (roomSelectedElements) {
            roomSelectedElements.forEach(element => {
                element.classList.remove('room-selected');
            });
        }

        const suiteSelectedElements = this.template.querySelectorAll('.suite-selected');
        if (suiteSelectedElements) {
            suiteSelectedElements.forEach(element => {
                element.classList.remove('suite-selected');
            });
        }

        const bedSelectedElements = this.template.querySelectorAll('.bed-selected');
        if (bedSelectedElements) {
            bedSelectedElements.forEach(element => {
                element.classList.remove('bed-selected');
            });
        }

        this.selectedBeds = [];
    }


    handleRoomSelected(event) {
        const { classList } = event.target;
        console.log('classList ', classList)
        let selectedValue = event.target.dataset.value;

        if(this.partiallyBookedRooms.includes(selectedValue)){

                const evt = new ShowToastEvent({
                    title: 'Info',
                    message: 'This room is partially booked!',
                    variant: 'info',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);

            return;
        }else{
        if (classList.contains('room-selected')) {
            classList.remove('room-selected');
            const result = this.allTableRows.filter(room => room.roomId === selectedValue);
            const suiteIds = result.map(item => item.suiteId);
            const bedIds = result.map(item => item.bedId);
            console.log('this.selectedBeds Before remove ', this.selectedBeds)
            bedIds.forEach(bedId => {
                console.log('bedId', bedId)
                const classOfBeds = this.template.querySelector(`div[data-bed-id="${bedId}"]`).classList;
                if (classOfBeds.contains('bed-selected')) {
                    classOfBeds.remove('bed-selected');
                }
            });
            this.selectedBeds = this.selectedBeds.filter(bed => !bedIds.includes(bed));
            console.log('this.selectedBeds After remove ', this.selectedBeds)
            if (suiteIds) {
                suiteIds.forEach(suiteId => {
                    console.log('Suie id ', suiteId)
                    const classOfsuites = this.template.querySelector(`div[data-value="${suiteId}"]`).classList;
                    if (classOfsuites.contains('suite-selected')) {
                        classOfsuites.remove('suite-selected');
                    }
                });
            }
        }
        else {
            classList.add('room-selected');
            const result = this.allTableRows.filter(room => room.roomId === selectedValue);

            const bedIds = result.map(item => item.bedId);
            console.log('this.selectedBeds Before ', this.selectedBeds)
            bedIds.forEach(bedId => {
                console.log('bedId', bedId)
                const classOfBeds = this.template.querySelector(`div[data-bed-id="${bedId}"]`);
                classOfBeds.classList.add('bed-selected');
                this.selectedBeds.push(bedId);
                console.log('this.selectedBeds After ', this.selectedBeds)
            });
        }
    }
    }

    handleSuiteSelected(event) {
        const { classList } = event.target;
        console.log('classList ', classList)
        let selectedValue = event.target.dataset.value;

        if(this.partiallyBookedSuites.includes(selectedValue)){

            const evt = new ShowToastEvent({
                title: 'Info',
                message: 'This suite is partially booked!',
                variant: 'info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

            return;
        }else{
        if (classList.contains('suite-selected')) {
            classList.remove('suite-selected');
            const result = this.allTableRows.filter(suite => suite.suiteId === selectedValue);

            const roomIds = result.map(item => item.roomId);
            roomIds.forEach(roomId => {
                console.log('roomId', roomId)
                const classOfrooms = this.template.querySelector(`div[data-room-id="${roomId}"]`).classList;
                if (classOfrooms.contains('room-selected')) {
                    classOfrooms.remove('room-selected');
                }
            });

            const bedIds = result.map(item => item.bedId);
            console.log('this.selectedBeds Before remove ', this.selectedBeds)
            bedIds.forEach(bedId => {
                console.log('bedId', bedId)
                const classOfBeds = this.template.querySelector(`div[data-bed-id="${bedId}"]`).classList;
                if (classOfBeds.contains('bed-selected')) {
                    classOfBeds.remove('bed-selected');
                }
            });
            this.selectedBeds = this.selectedBeds.filter(bed => !bedIds.includes(bed));
            console.log('this.selectedBeds After remove ', this.selectedBeds)
        }
        else {
            classList.add('suite-selected');
            const result = this.allTableRows.filter(suite => suite.suiteId === selectedValue);

            const roomIds = result.map(item => item.roomId);
            roomIds.forEach(roomId => {
                console.log('roomId', roomId)
                const classOfBeds = this.template.querySelector(`div[data-room-id="${roomId}"]`);
                classOfBeds.classList.add('room-selected');
            });

            const bedIds = result.map(item => item.bedId);
            console.log('this.selectedBeds Before ', this.selectedBeds)
            bedIds.forEach(bedId => {
                console.log('bedId', bedId)
                const classOfBeds = this.template.querySelector(`div[data-bed-id="${bedId}"]`);
                classOfBeds.classList.add('bed-selected');
                this.selectedBeds.push(bedId);
                console.log('this.selectedBeds After ', this.selectedBeds)
            });
        }
    }
    }

    tempEvtArray = [];
    handleItemClick(event) {
        this.refreshSelectedItems();
        // start show hide tick on click
        let dataValue = event.target.dataset.value;
        this.tempEvtArray.push(dataValue);
        //a[href="https://example.org"]
        let checkIcon = this.template.querySelector(`lightning-icon[data-features-icon="${dataValue}"]`);

        const currentCheckIconDisplay = checkIcon.style.display;
        if (currentCheckIconDisplay != 'none') {
            checkIcon.style.display = 'none';
        }
        else {
            checkIcon.style.display = '';
        }

        // end show hide tick on click

        let selectedValue = event.target.dataset.value;
        console.log('selected value: ', selectedValue);
        const { classList } = event.target;
        console.log('classList', classList)

        if (this.selectedFeatureValues.includes(selectedValue)) {
            this.selectedFeatureValues = this.selectedFeatureValues.filter((value) => value !== selectedValue);
            console.log('inside remove value')
        }
        else {
            this.selectedFeatureValues = [...this.selectedFeatureValues, selectedValue]
        }
        console.log('selectedFeatureValues: ', this.selectedFeatureValues);

        this.suiteAttributes = this.selectedFeatureValues
            .filter(value => value.includes('ElixirSuite__Suite_Attributes__c'))
            .map(value => value.split(' , ')[1].trim())
            .join(';');

        this.roomAttributes = this.selectedFeatureValues
            .filter(value => value.includes('ElixirSuite__Room_Attributes__c'))
            .map(value => value.split(' , ')[1].trim())
            .join(';');

        this.bedAttributes = this.selectedFeatureValues
            .filter(value => value.includes('ElixirSuite__Bed_Attributes__c'))
            .map(value => value.split(' , ')[1].trim())
            .join(';');

        console.log('suiteWhereClause ', this.suiteAttributes);
        console.log('roomWhereClause ', this.roomAttributes);
        console.log('bedWhereClause ', this.bedAttributes);

        this.refreshSearchResults();

    }

    refreshAttributeFilter() {
        if (this.tempEvtArray) {
            this.tempEvtArray.forEach(arr => {
                let checkIcon = this.template.querySelector(`lightning-icon[data-features-icon="${arr}"]`);

                const currentCheckIconDisplay = checkIcon.style.display;
                if (currentCheckIconDisplay != 'none') {
                    checkIcon.style.display = 'none';
                }
            });
            this.selectedFeatureValues = [];
            this.suiteAttributes = '';
            this.roomAttributes = '';
            this.bedAttributes = '';
            this.tempEvtArray = [];
        }
    }
    START_DATE_LESS_THAN_CURRENT_DATE_ERROR = "Start Date can not be less than the Current Date";
    END_DATE_LESS_THAN_START_DATE = "End Date can not be less than the Start Date";


    isStartDateEndDateValid() {
        let isValid = false;
        const startDateErrorElement = this.template.querySelector('.startDateError');

        if (this.startDate) {
            console.log('this.startDate'+ this.startDate);
            const currentStartDate = new Date(this.startDate);
            console.log('currentStartDate'+ currentStartDate);
            // Format the date as "YYYY-MM-DD"
            const startDateYear = currentStartDate.getFullYear();
            const StartDateMonth = String(currentStartDate.getMonth() + 1).padStart(2, '0');
            const startDateday = String(currentStartDate.getDate()).padStart(2, '0');
            const formattedStartDate = `${startDateYear}-${StartDateMonth}-${startDateday}`;

            console.log(formattedStartDate); 
            
            // Get the current date
            /*const currentDate = new Date();

            // Format the date as "YYYY-MM-DD"
            const year = currentDate.getFullYear();
            const month = String(currentDate.getMonth() + 1).padStart(2, '0');
            const day = String(currentDate.getDate()).padStart(2, '0');
            const today = `${year}-${month}-${day}`;*/  
            const today = this.userDate;
            console.log(today); 

            
           
            if (formattedStartDate >= today) {
                startDateErrorElement.innerHTML = "";
                isValid = true;
            }
            else {
                startDateErrorElement.innerHTML = this.START_DATE_LESS_THAN_CURRENT_DATE_ERROR;
                isValid = false;
                return isValid;
            }
        }
        else {
            // this.startDate is mandatory
            isValid = false;
            return isValid;
        }

        const endDateErrorElement = this.template.querySelector('.endDateError');
        if (this.endDate) {
            const currentStartDate = new Date(this.startDate);
            console.log('currentStartDate'+ currentStartDate);
            // Format the date as "YYYY-MM-DD"
            const startDateYear = currentStartDate.getFullYear();
            const StartDateMonth = String(currentStartDate.getMonth() + 1).padStart(2, '0');
            const startDateday = String(currentStartDate.getDate()).padStart(2, '0');
            const formattedStartDate = `${startDateYear}-${StartDateMonth}-${startDateday}`;

            console.log(formattedStartDate);

            const currentEndDate = new Date(this.endDate);
            console.log('currentEndDate'+ currentEndDate);
            // Format the date as "YYYY-MM-DD"
            const endDateYear = currentEndDate.getFullYear();
            const endDateMonth = String(currentEndDate.getMonth() + 1).padStart(2, '0');
            const endDateday = String(currentEndDate.getDate()).padStart(2, '0');
            const formattedEndDate = `${endDateYear}-${endDateMonth}-${endDateday}`;

            console.log(formattedEndDate);

            if (formattedEndDate >= formattedStartDate) {
                endDateErrorElement.innerHTML = "";
                isValid = true;
            }
            else {
                endDateErrorElement.innerHTML = this.END_DATE_LESS_THAN_START_DATE;
                isValid = false;
                return isValid;
            }

        }
        else {
            // this.endDate is mandatory
            isValid = false;
            return isValid;
        }

        return isValid;
    }

    onChangeRecordEditForm(event) {
        switch (event.target.name) {
            case "accountId":
                this.privateAccountId = event.target.value;
                break;

            case "startDate":
                this.startDate = event.target.value;
                break;

            case "endDate":
                this.endDate = event.target.value;
                break;
            default:
                break;
        }
        this.selectedBuildings = []
        this.deselectAll();
        this.refreshSelectedItems();
        this.refreshAttributeFilter();
        this.refreshSearchResults();
    }
    handleChange(event) {
        // Retrieve the selected value
        this.selectedValue = event.detail.value;

        // Perform any additional logic based on the selected value
        console.log('Selected Value:', this.selectedValue);
    }

    refreshSearchResults(getNextOffset = false) {
        const validDateRange = this.isStartDateEndDateValid();

        this.filterState = !validDateRange;

        console.log(`account id: ${this.privateAccountId} start date: ${this.startDate} end date: ${this.endDate}`);

        if (validDateRange && this.privateAccountId) {
            return this.getAvailableBedsJS(getNextOffset);
        }
        else {
            this.allTableRows = [];
            this.roomOffset = 0;
            this.suiteOffset = 0;
            this.roomUnderSuiteOffset = 0;

            return new Promise((resolve) => {
                resolve();
            });
        }
    }


    // parseBedsUnderBuilding(bedsUnderBuilding) {
    //     for (const building of bedsUnderBuilding) {
    //         if (building.ElixirSuite__Beds__r) {
    //             for (const bed of building.ElixirSuite__Beds__r) {
    //                 try {
    //                     let row = Object.create(this.tableRow);
    //                     row.type = 'building';
    //                     row.buildingId = building.Id;
    //                     row.buildingName = building.Name;
    //                     row.bedId = bed.Id;
    //                     row.bedName = bed.Name;
    //                     let features = bed.ElixirSuite__Bed_Attributes__c ? bed.ElixirSuite__Bed_Attributes__c : '';
    //                     if (features) {
    //                         row.features = Array.from(new Set(features.toLowerCase().split(';').sort())).join(', ');
    //                     }
    //                     this.allTableRows.push(row);
    //                 } catch (error) {
    //                     console.log(`parseBedsUnderBuilding: failed to parse bed- ${JSON.stringify(bed)} of building- ${JSON.stringify(building)}. Check if record has proper data.`);
    //                     console.error(error);
    //                 }
    //             }
    //         }
    //     }
    // }

    parseBedsUnderRooms(bedsUnderRooms) {
        for (const room of bedsUnderRooms) {
            if (room.ElixirSuite__Beds_per_room__r) {
                for (const bed of room.ElixirSuite__Beds_per_room__r) {
                    try {
                        let row = Object.create(this.tableRow);
                        row.type = 'room';
                        row.buildingId = room.ElixirSuite__Room__r.Id;
                        row.buildingName = room.ElixirSuite__Room__r.Name;
                        row.buildingNameBak = room.ElixirSuite__Room__r.Name;
                        row.roomId = room.Id;
                        row.roomName = room.Name;
                        row.bedId = bed.Id;
                        row.bedName = bed.Name;

                        let features = [];

                        if (bed.ElixirSuite__Bed_Attributes__c) {
                            features.push(bed.ElixirSuite__Bed_Attributes__c);
                        }
                        if (room.ElixirSuite__Room_Attributes__c) {
                            features.push(room.ElixirSuite__Room_Attributes__c);
                        }

                        features = features.join(';');

                        if (features) {
                            row.features = Array.from(new Set(features.toLowerCase().split(';').sort())).join(', ');
                        }

                        this.allTableRows.push(row);
                    } catch (error) {
                        console.log(`parseBedsUnderRooms: failed to parse bed- ${JSON.stringify(bed)} of room- ${JSON.stringify(room)}. Check if record has proper data.`);
                        console.error(error);
                    }
                }
            }
        }

    }

    parseBedsUnderRoomsWhereRoomsUnderSuites(bedsUnderRoomsWhereRoomsUnderSuites) {
        for (const room of bedsUnderRoomsWhereRoomsUnderSuites) {
            if (room.ElixirSuite__Beds_per_room__r) {
                for (const bed of room.ElixirSuite__Beds_per_room__r) {
                    try {
                        let row = Object.create(this.tableRow);
                        row.type = 'room_suite';
                        row.buildingId = room.ElixirSuite__RoomtoSuite__r.ElixirSuite__Suite__r.Id;
                        row.buildingName = room.ElixirSuite__RoomtoSuite__r.ElixirSuite__Suite__r.Name;
                        row.buildingNameBak = room.ElixirSuite__RoomtoSuite__r.ElixirSuite__Suite__r.Name;
                        row.roomId = room.Id;
                        row.roomName = room.Name;
                        row.suiteId = room.ElixirSuite__RoomtoSuite__r.Id;
                        row.suiteName = room.ElixirSuite__RoomtoSuite__r.Name;
                        row.bedId = bed.Id;
                        row.bedName = bed.Name;

                        let features = [];

                        if (bed.ElixirSuite__Bed_Attributes__c) {
                            features.push(bed.ElixirSuite__Bed_Attributes__c);
                        }

                        if (room.ElixirSuite__Room_Attributes__c) {
                            features.push(room.ElixirSuite__Room_Attributes__c);
                        }

                        if (room.ElixirSuite__RoomtoSuite__r.ElixirSuite__Suite_Attributes__c) {
                            features.push(room.ElixirSuite__RoomtoSuite__r.ElixirSuite__Suite_Attributes__c);
                        }

                        features = features.join(';');

                        if (features) {
                            row.features = Array.from(new Set(features.toLowerCase().split(';').sort())).join(', ');
                        }

                        this.allTableRows.push(row);
                    } catch (error) {
                        console.log(`parseBedsUnderRoomsWhereRoomsUnderSuites: failed to parse bed- ${JSON.stringify(bed)} of room- ${JSON.stringify(room)}. Check if record has proper data.`);
                        console.error(error);
                    }

                }
            }
        }
    }

    parseBedsUnderSuites(bedsUnderSuites) {
        for (const suite of bedsUnderSuites) {
            if (suite.ElixirSuite__Beds_per_suite__r) {
                for (const bed of suite.ElixirSuite__Beds_per_suite__r) {
                    try {
                        let row = Object.create(this.tableRow);
                        row.type = 'suite';
                        row.buildingId = suite.ElixirSuite__Suite__r.Id;
                        row.buildingName = suite.ElixirSuite__Suite__r.Name;
                        row.buildingNameBak = suite.ElixirSuite__Suite__r.Name;
                        row.suiteId = suite.Id;
                        row.suiteName = suite.Name;
                        row.bedId = bed.Id;
                        row.bedName = bed.Name;

                        let features = [];

                        if (bed.ElixirSuite__Bed_Attributes__c) {
                            features.push(bed.ElixirSuite__Bed_Attributes__c);
                        }
                        if (suite.ElixirSuite__Suite_Attributes__c) {
                            features.push(suite.ElixirSuite__Suite_Attributes__c);
                        }

                        features = features.join(';');

                        if (features) {
                            row.features = Array.from(new Set(features.toLowerCase().split(';').sort())).join(', ');
                        }

                        this.allTableRows.push(row);
                    } catch (error) {
                        console.log(`parseBedsUnderSuites: failed to parse bed- ${JSON.stringify(bed)} of suite- ${JSON.stringify(suite)}. Check if record has proper data.`);
                        console.error(error);
                    }
                }
            }
        }
    }

    compareTableRows(tableRowA, tableRowB) {
        return tableRowA.buildingNameBak < tableRowB.buildingNameBak ? -1 : 1;
    }



    onlyKeepFirstOccurence() {
        let alreadySeenLocation = [];
        this.allTableRows.forEach(function (i) {
            // handle building occurence
            if (i.buildingId) {
                if (alreadySeenLocation.includes(i.buildingId)) {
                    i.buildingName = '';
                }
                else {
                    alreadySeenLocation.push(i.buildingId);
                    i.styleClass += ' firstUniqueBuilding ';
                }
            }

            //handle suite occurence
            if (i.suiteId) {
                if (alreadySeenLocation.includes(i.suiteId)) {
                    i.suiteName = '';
                }
                else {
                    alreadySeenLocation.push(i.suiteId);
                    i.styleClass += ' firstUniqueSuite ';
                }
            }

            //handle room occurence
            if (i.roomId) {
                if (alreadySeenLocation.includes(i.roomId)) {
                    i.roomName = '';
                }
                else {
                    alreadySeenLocation.push(i.roomId);
                    i.styleClass += ' firstUniqueRoom ';
                }
            }
        });
    }

    bedsUnderBuildings = [];
    bedsUnderSuites = [];
    bedsUnderRooms = [];
    bedsUnderRoomsWhereRoomsUnderSuites = [];
    partiallyBookedSuites = [];
    partiallyBookedRooms = [];

    roomOffset = 0;
    suiteOffset = 0;
    roomUnderSuiteOffset = 0;

    getAvailableBedsJS(getNextOffset = false) {

        if (this.allTableRows.length == 0) {
            // now that we currently don't have any records, we don't want to ignore any while querying as well
            this.roomOffset = 0;
            this.suiteOffset = 0;
            this.roomUnderSuiteOffset = 0;
        }
        

        return getAvailableBeds({
            startDateTime: this.startDate,
            endDateTime: this.endDate,
            buildings: this.selectedBuildings,
            onlyFullyAvailableRoomsAndSuites: this.onlyFullyAvailableRoomsAndSuites,
            onlyFullyAvailableRooms: this.onlyFullyAvailableRooms,
            onlyFullyAvailableSuites: this.onlyFullyAvailableSuites,
            roomAttributes: this.roomAttributes,
            suiteAttributes: this.suiteAttributes,
            bedAttributes: this.bedAttributes,
            roomOffset: this.roomOffset,
            suiteOffset: this.suiteOffset,
            roomUnderSuiteOffset: this.roomUnderSuiteOffset,
            getNextOffset: getNextOffset
        })
            .then((result) => {
                try {
                    console.log('getAvailableBedsJS: ', result);

                    if (getNextOffset) {
                        this.bedsUnderBuildings.push(...result.bedsUnderBuildings);
                        this.bedsUnderSuites.push(...result.bedsUnderSuites);
                        this.bedsUnderRooms.push(...result.bedsUnderRooms);
                        this.bedsUnderRoomsWhereRoomsUnderSuites.push(...result.bedsUnderRoomsWhereRoomsUnderSuites);
                        this.partiallyBookedSuites.push(...result.partiallyBookedSuites);
                        this.partiallyBookedRooms.push(...result.partiallyBookedRooms);
                        
                        //this.parseBedsUnderBuilding(result.bedsUnderBuildings);
                        this.parseBedsUnderRooms(result.bedsUnderRooms);
                        this.parseBedsUnderSuites(result.bedsUnderSuites);
                        this.parseBedsUnderRoomsWhereRoomsUnderSuites(result.bedsUnderRoomsWhereRoomsUnderSuites);
                    }
                    else {
                        this.allTableRows = [];

                        this.bedsUnderBuildings = result.bedsUnderBuildings;
                        this.bedsUnderSuites = result.bedsUnderSuites;
                        this.bedsUnderRooms = result.bedsUnderRooms;
                        this.bedsUnderRoomsWhereRoomsUnderSuites = result.bedsUnderRoomsWhereRoomsUnderSuites;
                        this.partiallyBookedSuites = result.partiallyBookedSuites;
                        this.partiallyBookedRooms = result.partiallyBookedRooms;

                        //this.parseBedsUnderBuilding(this.bedsUnderBuildings);
                        this.parseBedsUnderRooms(this.bedsUnderRooms);
                        this.parseBedsUnderSuites(this.bedsUnderSuites);
                        this.parseBedsUnderRoomsWhereRoomsUnderSuites(this.bedsUnderRoomsWhereRoomsUnderSuites);
                    }

                    this.roomOffset = result.roomOffset;
                    this.suiteOffset = result.suiteOffset;
                    this.roomUnderSuiteOffset = result.roomUnderSuiteOffset;

                    // if(this.partiallyBookedSuites){
                    //     this.partiallyBookedSuites.forEach(suite => {
                    //         const classOfSuites = this.template.querySelector(`div[data-value="${suite}"]`).classList;
                    //         classOfSuites.add('disabledCss');
                    //     });
                    // }

                    // if(this.partiallyBookedRooms){
                    //     this.partiallyBookedRooms.forEach(room => {
                    //         const classOfRooms = this.template.querySelector(`div[data-value="${room}"]`).classList;
                    //         classOfRooms.add('disabledCss');
                    //     });
                    // }


                    this.getColumnsToDisplayInTable();
                    this.allTableRows.sort(this.compareTableRows);
                    this.onlyKeepFirstOccurence();
                } catch (error) {
                    console.log('getAvailableBedsJS Error:');
                    console.error(error);
                }
            })
            .catch((error) => {
                this.showErrorToast("Failed to fetch available beds");
                console.log("ERROR: failed to fetch available beds-");
                console.error(error);
            });
    }

    handleToggleSectionGuarantor() {
        console.log('Himanshu');
    }

    checkdates() {
        if (this.startDate != undefined && this.endDate != undefined) {
            this.filterState = false;
        }
        else {
            this.filterState = true;
        }
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
    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }



    options2 = [
        {
            label: 'Suite',
            value: 'suite'
        },
        {
            label: 'Room',
            value: 'room'
        }
    ];



    handleChangeForBuilding(event) {
        this.refreshSelectedItems();
        let selectedOptions = [];
        for (var i in event.detail) {
            for (const [key, value] of Object.entries(event.detail[i])) {
                console.log(`${key}: ${value}`);
                if (key == 'value') {
                    selectedOptions.push(value);
                }
                // this.selectedBuildings.push(value)
            }
        }
        this.selectedBuildings = selectedOptions;
        console.log('ids = ', this.selectedBuildings)
        this.refreshSearchResults();

    }

    handleChangeForRoomType(event) {
        this.refreshSelectedItems();
        this.refreshAttributeFilter();
        this.refreshSearchResults()
            .then(() => {
                let selectedOptions = [];
                console.log('length of room type ', event.detail.length)
                if (event.detail.length == 0) {
                    selectedOptions = ['suite', 'room'];
                }
                for (var i in event.detail) {
                    for (const [key, value] of Object.entries(event.detail[i])) {
                        console.log(`${key} : ${value}`);
                        if (key == 'value') {
                            selectedOptions.push(value);
                        }
                    }
                }

                this.allTableRows = [];
                //this.parseBedsUnderBuilding(this.bedsUnderBuildings);

                if (selectedOptions.includes('room')) {
                    this.parseBedsUnderRooms(this.bedsUnderRooms);
                    this.showSuite = false;
                }
                if (selectedOptions.includes('suite')) {
                    this.parseBedsUnderSuites(this.bedsUnderSuites);
                    this.parseBedsUnderRoomsWhereRoomsUnderSuites(this.bedsUnderRoomsWhereRoomsUnderSuites);
                    this.showRoom = false;
                }
                if (selectedOptions.includes('room') && selectedOptions.includes('suite')) {
                    this.showRoom = true;
                    this.showSuite = true;
                }
                this.allTableRows.sort(this.compareTableRows);
                this.onlyKeepFirstOccurence();

            });
    }

    toggleBedColor(event) {
        try {
            // const { classList, id: bedId } = event.target;
            const { classList } = event.target;
            const bedId = event.target.id.split('-')[0]; // Extract the desired part before the hyphen

            if (classList.contains('bed-selected')) {
                classList.remove('bed-selected');
                this.selectedBeds = this.selectedBeds.filter((bed) => bed !== bedId);

                const result = this.allTableRows.filter(bed => bed.bedId === bedId);
                console.log('This is the bed row ', result)

                const roomId = result.map(item => item.roomId);
                const suiteId = result.map(item => item.suiteId);

                if (roomId) {
                    console.log('roomId', roomId)
                    const classOfrooms = this.template.querySelector(`div[data-room-id="${roomId}"]`).classList;
                    if (classOfrooms.contains('room-selected')) {
                        classOfrooms.remove('room-selected');
                    }
                }
                if (suiteId) {
                    console.log('Suie id ', suiteId)
                    const classOfsuites = this.template.querySelector(`div[data-value="${suiteId}"]`).classList;
                    if (classOfsuites.contains('suite-selected')) {
                        classOfsuites.remove('suite-selected');
                    }
                }
            } else {
                classList.add('bed-selected');
                this.selectedBeds.push(bedId);
            }

            console.log('selected Bed Ids' + this.selectedBeds);

        }
        catch (error) {
            console.log('Toggle Css' + error);
        }

    }

    handleSave() {
        this.handleSelectedBeds();
        console.log(this.privateAccountId, ' private account id')
        if (this.privateAccountId == undefined || this.privateAccountId == '') {
            console.log('should show toast');
            this.showErrorToast('Please select a patient to continue');
            return;
        }
        if (this.startDate == undefined || this.startDate == '') {
            console.log('should show toast');
            this.showErrorToast('Please select a startDate to continue');
            return;
        }
        if (this.endDate == undefined || this.endDate == '') {
            console.log('should show toast');
            this.showErrorToast('Please select a endDate to continue');
            return;
        }
        if (this.selectedBedIds.length === 0) {
            console.log('should show toast');
            this.showErrorToast('Please select at least one bed');
            return;
        }
        
        console.log('selectedBeds' + this.selectedBedIds);
        console.log('selectedBeds-JSON' + JSON.stringify(this.selectedBedIds));
        

        this.overlappingReservationState()
            .then(() => {
                if (this.haveOverlappingReservation) {
                    this.handleConfirmClick()
                        .then(result => {
                            if (result) {
                                this.saveReservation();
                            }
                        })
                        .catch(error => {
                            this.error = error;
                        })
                } else {
                    this.saveReservation();
                }
            });

    }

    closeReviewAndOpenCreate(){
        this.startDate = '';
        this.endDate = '';
        this.selectedBedIds = [];
        this.allTableRows = [];
        this.selectedBeds = [];
        this.selectedBuildings = []
        this.refreshSelectedItems();
        this.refreshSearchResults();
        this.createRes = "slds-card slds-show"
        this.reviewRes = "slds-hide"; 
        this.showReviewScreen = false

    }

    saveReservation() {
        //Call the Apex method to save the reservation
        
        saveRecord({
            accountId: this.privateAccountId,
            startDate: this.startDate,
            endDate: this.endDate,
            selectedBeds: JSON.stringify(this.selectedBedIds)
        })
            .then(result => {
                // Handle the success case
                console.log('Record saved successfully:', result);
                this.showSuccessToast('Reservation has been successfully created');
                // Reset the form or perform any additional actions
                // this.startDate = '';
                // this.endDate = '';
                // this.selectedBedIds = [];
                // this.allTableRows = [];
                // this.selectedBeds = [];
                // this.onlyFullyAvailableRooms = false;
                // this.onlyFullyAvailableSuites = false;
                // this.selectedBuildings = []
                // this.refreshSelectedItems();
                // this.refreshSearchResults();
                if (this.isNewReservation === true) {
                    this.navigateToNewReservation();

                    console.log('isNewReservation =', this.isNewReservation);
                } else {
                    // this.isSaveButtonDisabled = true; // Disable the Save button
                    this.handleCancel();
                }

            })
            .catch(error => {
                // Handle the error case
                console.error('Error saving record:', error);
                this.showErrorToast(error.body.message);

            });
    }
    
    updateMessage(event) {
        console.log(event.detail.message);
        this.handleCancel();
        
    }

    afterSave() {
        this.startDate = '';
        this.endDate = '';
        this.selectedBedIds = [];
        this.allTableRows = [];
        this.selectedBeds = [];
        this.onlyFullyAvailableRooms = false;
        this.onlyFullyAvailableSuites = false;
        this.selectedBuildings = []
        this.refreshSelectedItems();
        this.refreshSearchResults();
    }

    handleSaveAndNew() {
        this.isNewReservation = true;
        this.handleSave();
    }
    handleSelectedBeds() {
        // Create a temporary array to store the matching bed objects
        let matchingBeds = [];
        // Iterate over selectedBeds
        this.selectedBeds.forEach(id => {
            // Find the index of the matching bed object in allTableRows
            const idx = this.allTableRows.findIndex(obj => obj.bedId === id);

            // Check if a matching bed object is found
            if (idx !== -1) {
                // Push the bed object into the selectedBeds array
                matchingBeds.push(this.allTableRows[idx]);
            }
        });


        // Assign the temporary array back to selectedBeds
        this.selectedBedIds = matchingBeds;
        // The selectedBeds array will now contain the selected bed objects from allTableRows
    }
    handleCancel() {
        this.startDate = '';
        this.endDate = '';
        this.selectedBedIds = [];
        this.allTableRows = [];
        this.selectedBeds = [];
        this.selectedBuildings = []
        this.refreshSelectedItems();
        this.refreshSearchResults();
        const event = new CustomEvent('myCustomEvent', {
            detail: { message: 'Hello from LWC!',
            accId:this.privateAccountId }
        });
        this.dispatchEvent(event);
    }



    navigateToNewReservation() {
        // Use the appropriate navigation method to open the "New Reservation" screen
        // and pass any necessary parameters
        /*try {
            let inContextOfRefValue = this.pageRef.state.inContextOfRef;
            console.log('inContextOfRefValue: ', inContextOfRefValue);
    
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'ElixirSuite__Reservation__c',
                    actionName: 'new'
                },
                state: {
                        inContextOfRef: `${inContextOfRefValue}`
                }
            });   
        } catch (error) {
            console.log('navigateToNewReservation error: ');
            console.error(error);
        }*/
        this.isNewReservation = false;
    }

    deselectAll() {
        const multiSelectComboBox = this.template.querySelector(".multi-select-combobox");
        const multiSelectRoomType = this.template.querySelector(".multi-select-roomType");
        multiSelectComboBox.deselectAll();
        multiSelectRoomType.deselectAll();
    }

    loadingMoreRecords = false;
    handleTableScroll(event) {
        // Only proceed if we are not already loading more records
        if (!this.loadingMoreRecords && this.allTableRows.length > 0) {
            //console.log(`scrollTop: ${event.target.scrollTop} scrollHeight: ${event.target.scrollHeight} offsetHeight: ${event.target.offsetHeight}`);
            this.loadingMoreRecords = ((event.target.scrollHeight - event.target.offsetHeight) - event.target.scrollTop) < 1;
            //console.log(' this.loadingMoreRecords: ',  this.loadingMoreRecords);

            if (this.loadingMoreRecords) {
                // scrolled to botoom first time
                console.log("calling getAvailableBedsJS");
                this.refreshSearchResults(true)
                    .then(() => {
                        this.loadingMoreRecords = false;
                    });
                console.log("done calling getAvailableBedsJS");
            }
        }
    }

    billableEntity;
    arrayExample;
    handleNextButton() {
        this.billableEntity = new Set();
        try {
            this.handleSelectedBeds();

            console.log(this.privateAccountId, ' private account id')
            if (this.privateAccountId == undefined || this.privateAccountId == '') {
                console.log('should show toast');
                this.showErrorToast('Please select a patient to continue');
                return;
            }
            if (this.startDate == undefined || this.startDate == '') {
                console.log('should show toast');
                this.showErrorToast('Please select a startDate to continue');
                return;
            }
            if (this.endDate == undefined || this.endDate == '') {
                console.log('should show toast');
                this.showErrorToast('Please select a endDate to continue');
                return;
            }
            if (this.selectedBedIds.length === 0) {
                console.log('should show toast');
                this.showErrorToast('Please select at least one bed');
                return;
            }
            if (this.selectedValue == undefined || this.selectedValue == '') {
                console.log('should show toast');
                this.showErrorToast('Please select a ' + this.labelValue + ' to continue');
                return;
            }
            

            console.log('selectedBeds' + this.selectedBedIds);
            console.log('selectedBeds-JSON' + JSON.stringify(this.selectedBedIds));
            const rowToBeSaved = this.selectedBedIds;
            console.log('rowToBeSaved', JSON.stringify(rowToBeSaved));
            console.log('selectedValue' + this.selectedValue);

            for (let i = 0; i < rowToBeSaved.length; i++) {
                if (rowToBeSaved[i].suiteId) {
                    let suiteSelected = false;
                    this.template.querySelectorAll(`div[data-value="${rowToBeSaved[i].suiteId}"]`).forEach(element => {
                        if (element.classList.contains('suite-selected')) {
                            this.billableEntity.add(rowToBeSaved[i].suiteId);
                            suiteSelected = true;
                        }
                    });
                    if (suiteSelected) {
                        continue;
                    }
                }
                if (rowToBeSaved[i].roomId) {
                    let roomSelected = false;
                    this.template.querySelectorAll(`div[data-value="${rowToBeSaved[i].roomId}"]`).forEach(element => {
                        if (element.classList.contains('room-selected')) {
                            this.billableEntity.add(rowToBeSaved[i].roomId);
                            roomSelected = true;
                        }
                    });
                    if (roomSelected) {
                        continue;
                    }

                }
                if (rowToBeSaved[i].bedId) {
                    // let bedSelected = false;
                    this.template.querySelectorAll(`div[data-bed-id="${rowToBeSaved[i].bedId}"]`).forEach(element => {
                        if (element.classList.contains('bed-selected')) {
                            this.billableEntity.add(rowToBeSaved[i].bedId);
                        }
                    });

                }

            }


            console.log('this.billableEntity ===', this.billableEntity)
            this.arrayExample = Array.from(this.billableEntity);
            console.log('arrayExample ', this.arrayExample)

            this.overlappingReservationState()
                .then(() => {
                    if (this.haveOverlappingReservation) {
                        this.handleConfirmClick()
                            .then(result => {
                                if (result) {
                                    // this.saveReservation();
                                    this.createRes = "slds-card slds-hide"
                                    this.reviewRes = "slds-show";
                                    this.showReviewScreen = true;
                                }
                            })
                            .catch(error => {
                                this.error = error;
                            })
                    } else {
                        // this.saveReservation();
                        this.createRes = "slds-card slds-hide"
                        this.reviewRes = "slds-show";
                        this.showReviewScreen = true;
                    }
                });
        } catch (error) {
            console.error(error);
        }

    }

    modifyReservation(){
        this.createRes = "slds-card slds-show"
        this.reviewRes = "slds-hide";
        this.showReviewScreen = false
    }

    createRes = "slds-card slds-show"
    reviewRes = "slds-hide";
    showReviewScreen = false

}