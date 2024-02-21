public with sharing class CreateReservation {
    /**
    * @description AvailableBedsWrapper
    */
    public class AvailableBedsWrapper {
        @AuraEnabled public List<ElixirSuite__Location__c> bedsUnderBuildings;
        @AuraEnabled public List<ElixirSuite__Location__c> bedsUnderRooms;
        @AuraEnabled public List<ElixirSuite__Location__c> bedsUnderSuites;
        @AuraEnabled public List<ElixirSuite__Location__c> bedsUnderRoomsWhereRoomsUnderSuites;
        @AuraEnabled public Integer roomOffset;
        @AuraEnabled public Integer suiteOffset;
        @AuraEnabled public Integer roomUnderSuiteOffset;
        @AuraEnabled public List<Id> partiallyBookedSuites;
        @AuraEnabled public List<Id> partiallyBookedRooms;
    }
    /**
    * @description TableRow
    */

    public class TableRow{
        @AuraEnabled public String type;
        @AuraEnabled public String styleClass;
        @AuraEnabled public String buildingId;
        @AuraEnabled public String buildingName;
        @AuraEnabled public String buildingNameBak;
        @AuraEnabled public String suiteId;
        @AuraEnabled public String suiteName;
        @AuraEnabled public String roomId;
        @AuraEnabled public String roomName;
        @AuraEnabled public String bedId;
        @AuraEnabled public String bedName;
        @AuraEnabled public String features;
    }
    
    public class BillableEntity {
        public List<ElixirSuite__Actual_Price__c> actualPrices;
        public List<ElixirSuite__Contracted_Price__c> contractPrices;
        public String locationId;
        public String locationName;
        public String recordTypeName;
        public Integer index;
        public List<Option> options;
        public Decimal price;
        public String selectedDiscountType;
        public String selectedDiscountValue;
        public String netPrice;
    }
    
    public class Option {
        public String label;
        public String value;
    }
    
    @AuraEnabled
    public static List<String> getColumnsToDisplay(){
        ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
        List<String> columns = settings.ElixirSuite__Reservation_Columns__c.split(',');
        return columns;
    }

    @AuraEnabled
     /**
    * @description getAllBuildings
    * @return List of Location__c objects representing all buildings
    */
    public static List<Location__c> getAllBuildings(){
        Id recordTypeId = Schema.SObjectType.ElixirSuite__Location__c.getRecordTypeInfosByDeveloperName().get('Building').getRecordTypeId();
        List<Location__c> allBuildings = [SELECT Id, Name
                                          FROM Location__c
                                          WHERE recordTypeId =:recordTypeId
                                          WITH SECURITY_ENFORCED];
        return allBuildings;
    }
    
    @AuraEnabled
     /**
    * @description getAttributes
     * @return MyWrapper representing wrpr
    */
    public static MyWrapper getAttributes(){
        Map<String, String> rooms = new Map<String, String>();
        Map<String, String> beds = new Map<String, String>();
        Map<String, String> suites = new Map<String, String>();
        
        MyWrapper wrpr = new MyWrapper();
        
        Schema.DescribeFieldResult fieldResultForRooms = Location__c.Bed_Attributes__c.getDescribe(); 
        String fieldAPI = fieldResultForRooms.getName();
       
        List<Schema.PicklistEntry> ple = fieldResultForRooms.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            String mapKey = fieldAPI + ' , ' + pickListVal.getValue();
            beds.put(mapKey, pickListVal.getValue());
                    }            
        
        Schema.DescribeFieldResult fieldResultForBeds = Location__c.Room_Attributes__c.getDescribe();        
        List<Schema.PicklistEntry> ple2 = fieldResultForBeds.getPicklistValues();
        String fieldAPI2 = fieldResultForBeds.getName();
       
        for(Schema.PicklistEntry pickListVal : ple2){
            String mapKey = fieldAPI2 + ' , ' + pickListVal.getValue();
            rooms.put(mapKey, pickListVal.getValue());
                }        
        
        Schema.DescribeFieldResult fieldResultForSuites = Location__c.Suite_Attributes__c.getDescribe();
		String fieldAPI3 = fieldResultForSuites.getName();
             
        List<Schema.PicklistEntry> ple3 = fieldResultForSuites.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple3){
            String mapKey = fieldAPI3 + ' , ' + pickListVal.getValue();
            suites.put(mapKey, pickListVal.getValue());
        }
        
        wrpr.roomAttributes = rooms;
        wrpr.bedAttributes = beds;
        wrpr.suitesAttributes = suites;
        
        return wrpr;
    }
     /**
    * @description MyWrapper
    */
    
    public class MyWrapper{
        @AuraEnabled public Map<String, String> roomAttributes; 
        @AuraEnabled public Map<String, String> bedAttributes;
        @AuraEnabled public Map<String, String> suitesAttributes;
    }


    @AuraEnabled
     /**
    * @description getAvailableBeds
    * @param startDateTime The start date and time of the reservation. (Required)
    * @param endDateTime The end date and time of the reservation. (Required)
    * @param buildings A list of building names to filter the available beds. (Required)
    * @param onlyFullyAvailableRoomsAndSuites If set to true, only fully available rooms and suites will be considered. (Required)
    * @param onlyFullyAvailableRooms If set to true, only fully available rooms will be considered. (Required)
    * @param onlyFullyAvailableSuites If set to true, only fully available suites will be considered. (Required)
    * @param roomAttributes A comma-separated string representing room attributes to filter the available beds. (Required)
    * @param suiteAttributes A comma-separated string representing suite attributes to filter the available beds. (Required)
    * @param bedAttributes A comma-separated string representing bed attributes to filter the available beds. (Required)
    * @param roomOffset The offset value for rooms to retrieve the next set of available beds. (Required)
    * @param suiteOffset The offset value for suites to retrieve the next set of available beds. (Required)
    * @param roomUnderSuiteOffset The offset value for room under suites to retrieve the next set of available beds. (Required)
    * @param getNextOffset If set to true, indicates the need to retrieve the next set of available beds. (Required)
     * @return AvailableBedsWrapper representing bedsToReturn
    */
    public static AvailableBedsWrapper getAvailableBeds(Datetime startDateTime, Datetime endDateTime, List<String> buildings, Boolean onlyFullyAvailableRoomsAndSuites,Boolean onlyFullyAvailableRooms, Boolean onlyFullyAvailableSuites, String roomAttributes, String suiteAttributes, String bedAttributes, Integer roomOffset, Integer suiteOffset, Integer roomUnderSuiteOffset, Boolean getNextOffset){
        try {
        ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
     
       
        Decimal startHours = settings.ElixirSuite__Default_Reservation_Start_Hours__c;
        Integer defaultStartHours = startHours.intValue();
        Decimal startMinutes = settings.ElixirSuite__Default_Reservation_Start_Minutes__c;
        Integer defaultStartMinutes = startMinutes.intValue();

        Decimal  endHours = settings.ElixirSuite__Default_Reservation_End_Hours__c;
        Integer defaultEndHours = endHours.intValue();
        Decimal  endMinutes = settings.ElixirSuite__Default_Reservation_End_Minutes__c;
        Integer defaultEndMinutes = endMinutes.intValue();

        integer seconds=0;

        // Update the start and end dates with the custom settings' hours and minutes
        startDateTime = Datetime.newInstance(Date.valueOf(startDateTime), Time.newInstance(defaultStartHours, defaultStartMinutes, 0, 0));
        endDateTime = Datetime.newInstance(Date.valueOf(endDateTime), Time.newInstance(defaultEndHours, defaultEndMinutes, 0, 0));

            // We will take 3 lists now, [buildings->beds], [rooms->beds], [suites->beds]
            List<ElixirSuite__Location__c> bedsUnderBuildings = new List<ElixirSuite__Location__c>();
            List<ElixirSuite__Location__c> bedsUnderRooms = new List<ElixirSuite__Location__c>();
            List<ElixirSuite__Location__c> bedsUnderSuites = new List<ElixirSuite__Location__c>();
            List<ElixirSuite__Location__c> bedsUnderRoomsWhereRoomsUnderSuites = new List<ElixirSuite__Location__c>();
            List<Id> allBeds = new List<Id>();

            String bedsUnderBuildingsQuery =
                'SELECT Id, Name, ElixirSuite__Building__c, '
               +'(SELECT Id, name FROM  ElixirSuite__Beds__r WHERE RecordType.DeveloperName = \'Bed\') '
               +'FROM ElixirSuite__Location__c WHERE RecordType.DeveloperName = \'Building\' ';

            if(buildings!=null && buildings.size()>0){
                bedsUnderBuildingsQuery += 'AND Id IN :buildings';
            }

            for (ElixirSuite__Location__c i : Database.query(bedsUnderBuildingsQuery)) {
                allBeds.addAll((new Map<Id,ElixirSuite__Location__c>(i.ElixirSuite__Beds__r)).keySet());
            }

            String bedsUnderRoomsQuery =
                'SELECT Id, Name, ElixirSuite__Room__c, '
               +'(SELECT Id, name FROM ElixirSuite__Beds_per_room__r WHERE RecordType.DeveloperName = \'Bed\') '
               +'FROM ElixirSuite__Location__c WHERE RecordType.DeveloperName = \'Room\' ';

            if(buildings!=null && buildings.size()>0){
                bedsUnderRoomsQuery+= 'AND Room__c IN :buildings'; 
            }
            
            for (ElixirSuite__Location__c i : Database.query(bedsUnderRoomsQuery)) {
                allBeds.addAll((new Map<Id,ElixirSuite__Location__c>(i.ElixirSuite__Beds_per_room__r)).keySet());
            }
            
            String bedsUnderSuitesQuery =
                'SELECT Id, Name, ElixirSuite__suite__c, ' 
               +'(SELECT Id, name FROM ElixirSuite__Beds_per_suite__r WHERE RecordType.DeveloperName = \'Bed\') '
               +'FROM ElixirSuite__Location__c WHERE RecordType.DeveloperName = \'Suite\' ';
            
            if(buildings!=null && buildings.size()>0){
                bedsUnderSuitesQuery+= 'AND Suite__c IN :buildings'; 
            }

            for (ElixirSuite__Location__c i : Database.query(bedsUnderSuitesQuery)) {
                allBeds.addAll((new Map<Id,ElixirSuite__Location__c>(i.ElixirSuite__Beds_per_suite__r)).keySet());
            }         


            List<ElixirSuite__Reservation_Line_Item__c> reservationLineItemsInGivenStartEndDate = new List<ElixirSuite__Reservation_Line_Item__c>();
            reservationLineItemsInGivenStartEndDate = [
                SELECT
                    Id, ElixirSuite__Bed__c, ElixirSuite__Room__c, ElixirSuite__Suite__c
                FROM
                    ElixirSuite__Reservation_Line_Item__c
                WHERE
                    ElixirSuite__Bed__c IN :allBeds
                AND
                    (ElixirSuite__Bed_Status__c IN ('Active', 'Scheduled', 'Pending', 'Confirmed')
                AND
                    (NOT((ElixirSuite__Start_Date__c > :startDateTime AND ElixirSuite__Start_Date__c >= :endDateTime) OR (ElixirSuite__End_Date__c <= :startDateTime AND ElixirSuite__End_Date__c < :endDateTime))))
                WITH SECURITY_ENFORCED];
            // if startDate is less than reservationStartDate, then endDate should also be less than or equal to reservationStartDate
            // else if startDate is greaterThan or equal to reservationEndDate, then endDate should also be greater than reservationEndDate

           
            Set<Id> roomsWithBookedBeds = new Set<Id>(); 
            Set<Id> suitesWithBookedBeds = new Set<Id>();
            Set<Id> roomsAndSuitesWithBookedBeds = new Set<Id>();
            List<Id> partiallyBookedSuitesLst = new List<Id>();
            List<Id> partiallyBookedRoomsLst = new List<Id>();
            

            for (ElixirSuite__Reservation_Line_Item__c i : reservationLineItemsInGivenStartEndDate) {
                Id bedId = i.ElixirSuite__Bed__c;
                Integer bedIndex = allBeds.indexOf(bedId);
                if (bedId != null && bedIndex != -1) {
                    allBeds.remove(bedIndex);                    
                }
                
                if (i.ElixirSuite__Suite__c != null) {
                        partiallyBookedSuitesLst.add(i.ElixirSuite__Suite__c);
                    }
                if (i.ElixirSuite__Room__c != null ) {
                        partiallyBookedRoomsLst.add(i.ElixirSuite__Room__c);
                    }

                /*if (onlyFullyAvailableRoomsAndSuites) {
                    if (i.ElixirSuite__Room__c != null) {
                        roomsAndSuitesWithBookedBeds.add(i.ElixirSuite__Room__c);
                    }
    
                    if (i.ElixirSuite__Suite__c != null) {
                        roomsAndSuitesWithBookedBeds.add(i.ElixirSuite__Suite__c);
                    }
                }*/
                if (onlyFullyAvailableRooms) {
                    if (i.ElixirSuite__Room__c != null ) {
                        roomsWithBookedBeds.add(i.ElixirSuite__Room__c);
                    }
    
                 }
                if (onlyFullyAvailableSuites) {
                    if (i.ElixirSuite__Suite__c != null) {
                        suitesWithBookedBeds.add(i.ElixirSuite__Suite__c);
                    }
                    if(i.ElixirSuite__Suite__c != null){
                        roomsAndSuitesWithBookedBeds.add(i.ElixirSuite__Suite__c);
                    }
                }
            }   

            bedsUnderBuildings = [
                SELECT
                    Id, Name,
                    (SELECT
                        Id, name, ElixirSuite__Bed_Attributes__c
                    FROM
                        ElixirSuite__Beds__r
                    WHERE
                        RecordType.DeveloperName = 'Bed'
                    AND
                        Id IN :allBeds)
                FROM
                    ElixirSuite__Location__c
                WHERE
                    RecordType.DeveloperName = 'Building' WITH SECURITY_ENFORCED];
            Date startDate;
			Date endDate;
            startDate = startDateTime.date();
            endDate = endDateTime.date();

            bedsUnderRoomsQuery =
                'SELECT Id, Name, ElixirSuite__Room__r.Id, ElixirSuite__Room__r.Name, ElixirSuite__Room_Attributes__c, '
                + '(SELECT Id, name, ElixirSuite__Bed_Attributes__c FROM ElixirSuite__Beds_per_room__r WHERE RecordType.DeveloperName = \'Bed\' AND Id IN :allBeds ' 
                + 'AND ElixirSuite__Status__c!=\'Temporary Hold\' '
                + 'AND ElixirSuite__Status__c!=\'Out of Order\' '
                + 'AND (ElixirSuite__Out_of_Order_Date__c = null OR (NOT(ElixirSuite__Out_of_Order_Date__c >= :startDate AND ElixirSuite__Out_of_Order_Date__c <= :endDate))) ';
            
            if (String.isNotBlank(bedAttributes)) {
                bedsUnderRoomsQuery += ' AND ElixirSuite__Bed_Attributes__c includes (:bedAttributes) ';
            }
            
            bedsUnderRoomsQuery += ' ORDER BY Name, Id) FROM ElixirSuite__Location__c WHERE RecordType.DeveloperName = \'Room\' AND ElixirSuite__RoomtoSuite__c = null '
            + 'AND ElixirSuite__Status__c!=\'Needs Cleaning\' '
            + 'AND ElixirSuite__Status__c!=\'Temporary Hold\' '
            + 'AND ElixirSuite__Status__c!=\'Out of Order\' '
            + 'AND (ElixirSuite__Out_of_Order_Date__c = null OR (NOT(ElixirSuite__Out_of_Order_Date__c >= :startDate AND ElixirSuite__Out_of_Order_Date__c <= :endDate))) '
            + 'AND Id NOT IN :roomsWithBookedBeds ';
                
            if (String.isNotBlank(roomAttributes)) {
                bedsUnderRoomsQuery += ' AND ElixirSuite__Room_Attributes__c includes (:roomAttributes) ';
            }

            bedsUnderRoomsQuery += ' ORDER BY Name, Id LIMIT 10 ';

            if (getNextOffset) {
                bedsUnderRoomsQuery += ' OFFSET :roomOffset ';
            }
                   
            bedsUnderRooms = Database.query(bedsUnderRoomsQuery);

            String bedsUnderRoomsWhereRoomsUnderSuitesQuery = 
                  'SELECT Id,  Name, ElixirSuite__RoomtoSuite__r.ElixirSuite__Suite__r.Id, ElixirSuite__RoomtoSuite__r.ElixirSuite__Suite__r.Name,ElixirSuite__RoomtoSuite__r.Id, ElixirSuite__RoomtoSuite__r.Name, ElixirSuite__RoomtoSuite__r.ElixirSuite__Suite_Attributes__c, ElixirSuite__Room_Attributes__c, '
                + '(SELECT Id, name, ElixirSuite__Bed_Attributes__c FROM ElixirSuite__Beds_per_room__r WHERE RecordType.DeveloperName = \'Bed\' AND Id IN :allBeds '
                + 'AND ElixirSuite__Status__c!=\'Temporary Hold\' '
                + 'AND ElixirSuite__Status__c!=\'Out of Order\' '
                + 'AND (ElixirSuite__Out_of_Order_Date__c = null OR (NOT(ElixirSuite__Out_of_Order_Date__c >= :startDate AND ElixirSuite__Out_of_Order_Date__c <= :endDate))) ';
            if (String.isNotBlank(bedAttributes)) {
                bedsUnderRoomsWhereRoomsUnderSuitesQuery += ' AND ElixirSuite__Bed_Attributes__c includes (:bedAttributes) ';
            }
                bedsUnderRoomsWhereRoomsUnderSuitesQuery += ' ORDER BY Name, Id) FROM ElixirSuite__Location__c '
                + 'WHERE RecordType.DeveloperName = \'Room\' '
                + 'AND ElixirSuite__RoomtoSuite__c != null '
                + 'AND ElixirSuite__Status__c!=\'Needs Cleaning\' '
                + 'AND ElixirSuite__Status__c!=\'Temporary Hold\' '
                + 'AND ElixirSuite__Status__c!=\'Out of Order\' '
                + 'AND (ElixirSuite__RoomtoSuite__r.ElixirSuite__Out_of_Order_Date__c = null OR (NOT(ElixirSuite__RoomtoSuite__r.ElixirSuite__Out_of_Order_Date__c >= :startDate AND ElixirSuite__RoomtoSuite__r.ElixirSuite__Out_of_Order_Date__c <= :endDate))) '
                + 'AND Id NOT IN :roomsWithBookedBeds AND ElixirSuite__RoomtoSuite__r.Id NOT IN :roomsAndSuitesWithBookedBeds ';
            
            if (String.isNotBlank(roomAttributes)) {
                bedsUnderRoomsWhereRoomsUnderSuitesQuery += ' AND ElixirSuite__Room_Attributes__c includes (:roomAttributes) ';
            }
            if(String.isNotBlank(suiteAttributes)){
                bedsUnderRoomsWhereRoomsUnderSuitesQuery += ' AND ElixirSuite__RoomtoSuite__r.ElixirSuite__Suite_Attributes__c includes (:suiteAttributes)';
            }
            // seperating where clause it is needed later
            List<String> bedsUnderRoomsWhereRoomsUnderSuitesQuerySplit = bedsUnderRoomsWhereRoomsUnderSuitesQuery.split('FROM ElixirSuite__Location__c WHERE ');
            bedsUnderRoomsWhereRoomsUnderSuitesQuery += ' ORDER BY ElixirSuite__RoomtoSuite__r.Name, ElixirSuite__RoomtoSuite__r.Id, Name, Id  LIMIT 10 ';

            if (getNextOffset) {
                bedsUnderRoomsWhereRoomsUnderSuitesQuery += ' OFFSET :roomUnderSuiteOffset ';
            }

            bedsUnderRoomsWhereRoomsUnderSuites = Database.query(bedsUnderRoomsWhereRoomsUnderSuitesQuery);

            // find how many rooms are queried in suites
            Map<Id, List<Id>> suiteToQueriedRoomsMap = new Map<Id, List<Id>>();
            for (ElixirSuite__Location__c room : bedsUnderRoomsWhereRoomsUnderSuites) {
                if (suiteToQueriedRoomsMap.containsKey(room.ElixirSuite__RoomtoSuite__r.Id)) {
                    List<Id> i = suiteToQueriedRoomsMap.get(room.ElixirSuite__RoomtoSuite__r.Id);
                    i.add(room.Id);
                    suiteToQueriedRoomsMap.put(room.ElixirSuite__RoomtoSuite__r.Id, i);
                }
                else {
                    suiteToQueriedRoomsMap.put(room.ElixirSuite__RoomtoSuite__r.Id, new List<Id>{room.Id});
                }
            }
                        
            // find all rooms under suites which were not included in query
            Set<Id> parentSuiteIds = suiteToQueriedRoomsMap.keySet();
            Set<Id> roomsAlreadyQueried = (new Map<Id,ElixirSuite__Location__c>(bedsUnderRoomsWhereRoomsUnderSuites)).keySet();
            String countRoomsUnderSuitesQuery = 'SELECT Id, ElixirSuite__RoomtoSuite__r.Id FROM ElixirSuite__Location__c WHERE ID NOT IN :roomsAlreadyQueried AND ElixirSuite__RoomtoSuite__r.Id IN :parentSuiteIds AND ';

            // taking the 'WHERE Cluase' from bedsUnderRoomsWhereRoomsUnderSuitesQuery
            countRoomsUnderSuitesQuery += bedsUnderRoomsWhereRoomsUnderSuitesQuerySplit[1];
 
            List<ElixirSuite__Location__c> countRoomsUnderSuites = Database.query(countRoomsUnderSuitesQuery);
            
            // query rooms with id in roomsToAdd
            if (countRoomsUnderSuites != null && countRoomsUnderSuites.size() > 0) {
                Set<Id> roomsToAdd;
                roomsToAdd = (new Map<Id,ElixirSuite__Location__c>(countRoomsUnderSuites)).keySet();
                String roomsToAddQuery = bedsUnderRoomsWhereRoomsUnderSuitesQuerySplit[0] + ' FROM ElixirSuite__Location__c WHERE Id IN :roomsToAdd AND ' + bedsUnderRoomsWhereRoomsUnderSuitesQuerySplit[1];
                List<ElixirSuite__Location__c> roomsToAddSobjList = Database.query(roomsToAddQuery);
                bedsUnderRoomsWhereRoomsUnderSuites.addAll(roomsToAddSobjList);
            }

            bedsUnderSuitesQuery =
                'SELECT Id, Name, ElixirSuite__Suite__r.Id, ElixirSuite__Suite__r.Name, ElixirSuite__Suite_Attributes__c, '
              + '(SELECT Id, name, ElixirSuite__Bed_Attributes__c FROM ElixirSuite__Beds_per_suite__r WHERE RecordType.DeveloperName = \'Bed\' AND Id IN :allBeds '
              + 'AND ElixirSuite__Status__c!=\'Temporary Hold\' '
              + 'AND ElixirSuite__Status__c!=\'Out of Order\' '
              + 'AND (ElixirSuite__Out_of_Order_Date__c = null OR (NOT(ElixirSuite__Out_of_Order_Date__c >= :startDate AND ElixirSuite__Out_of_Order_Date__c <= :endDate))) ';
            if (String.isNotBlank(bedAttributes)) {
                bedsUnderSuitesQuery += ' AND ElixirSuite__Bed_Attributes__c includes (:bedAttributes)';
            }
              bedsUnderSuitesQuery += ' ORDER BY Name, Id) FROM ElixirSuite__Location__c WHERE RecordType.DeveloperName = \'Suite\' '
              + 'AND Id NOT IN :suitesWithBookedBeds '
              + 'AND ElixirSuite__Status__c!=\'Needs Cleaning\' '
              + 'AND ElixirSuite__Status__c!=\'Temporary Hold\' '
              + 'AND ElixirSuite__Status__c!=\'Out of Order\' '
              + 'AND (ElixirSuite__Out_of_Order_Date__c = null OR (NOT(ElixirSuite__Out_of_Order_Date__c >= :startDate AND ElixirSuite__Out_of_Order_Date__c <= :endDate))) ';
            

            if(String.isNotBlank(suiteAttributes)){
                bedsUnderSuitesQuery += ' AND ElixirSuite__Suite_Attributes__c includes (:suiteAttributes)';
			}


            bedsUnderSuitesQuery += ' ORDER BY Name, Id LIMIT 10 ';

            if (getNextOffset) {
                bedsUnderSuitesQuery += ' OFFSET :suiteOffset ';
            }
            
            bedsUnderSuites = Database.query(bedsUnderSuitesQuery);
            
            AvailableBedsWrapper bedsToReturn = new AvailableBedsWrapper();
            bedsToReturn.bedsUnderBuildings = bedsUnderBuildings;
            bedsToReturn.bedsUnderRooms = bedsUnderRooms;
            bedsToReturn.bedsUnderSuites = bedsUnderSuites;
            bedsToReturn.bedsUnderRoomsWhereRoomsUnderSuites = bedsUnderRoomsWhereRoomsUnderSuites;
            bedsToReturn.partiallyBookedSuites = partiallyBookedSuitesLst;
            bedsToReturn.partiallyBookedRooms = partiallyBookedRoomsLst;

            if (getNextOffset || (roomOffset == 0 && suiteOffset == 0 && roomUnderSuiteOffset == 0)) {
                bedsToReturn.roomOffset = roomOffset + bedsUnderRooms.size(); 
                bedsToReturn.suiteOffset = suiteOffset + bedsUnderSuites.size();
                bedsToReturn.roomUnderSuiteOffset = roomUnderSuiteOffset + bedsUnderRoomsWhereRoomsUnderSuites.size(); 
            }
            else {
                bedsToReturn.roomOffset = roomOffset;
                bedsToReturn.suiteOffset = suiteOffset;
                bedsToReturn.roomUnderSuiteOffset = roomUnderSuiteOffset;
            }
            

            return bedsToReturn;            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
     /**
    * @description assertThatTheseBedsAreAvailable
    * @param  bedIds List of String representing the IDs of beds to check availability.
    * @param startDateTime Datetime representing the start of the time range to check availability.
    * @param endDateTime Datetime representing the end of the time range to check availability. 
    */
    public static void assertThatTheseBedsAreAvailable(List<String> bedIds, Datetime startDateTime, Datetime endDateTime){
        // query all reservation line items with given bed Ids, lying between given startDate-endDate
        List<ElixirSuite__Reservation_Line_Item__c> alreadyBookedBedsInBedIds = new List<ElixirSuite__Reservation_Line_Item__c>();
        alreadyBookedBedsInBedIds = [
            SELECT
                Id, ElixirSuite__Bed__r.Name
            FROM
                ElixirSuite__Reservation_Line_Item__c
            WHERE
                ElixirSuite__Bed__c IN :bedIds
            AND 
                ElixirSuite__Bed_Status__c IN ('Active', 'Scheduled', 'Pending', 'Confirmed')
            AND 
                (NOT(
                    (
                        ElixirSuite__Start_Date__c > :startDateTime 
                    AND
                        ElixirSuite__Start_Date__c >= :endDateTime
                    )

                OR 
                    (
                        ElixirSuite__End_Date__c <= :startDateTime 
                    AND 
                        ElixirSuite__End_Date__c < :endDateTime
                    )
                ))
            WITH SECURITY_ENFORCED];

        if (alreadyBookedBedsInBedIds.size() > 0) {
            List<String> bookedBedsName = new List<String>();
            for (ElixirSuite__Reservation_Line_Item__c i : alreadyBookedBedsInBedIds) {
                bookedBedsName.add(i.ElixirSuite__Bed__r.Name);
            }
            throw new AuraHandledException('Selected beds: ' + String.join(bookedBedsName, ', ') + ' are no longer available for booking. Please select different beds');
        }
    }
    
    @AuraEnabled
     /**
    * @description overlappingReservation
    * @return Boolean representing isOverlapping
    * @param accountId The Id of the Account for which the reservation data is to be saved. 
    * @param startDate The start date of the reservation. 
    * @param endDate The end date of the reservation. 
    */
    public static Boolean overlappingReservation(String accountId, Datetime startDate, Datetime endDate){
        Boolean isOverlapping = false;

        ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
     
       
        Decimal startHours = settings.ElixirSuite__Default_Reservation_Start_Hours__c;
        Integer defaultStartHours = startHours.intValue();
        Decimal startMinutes = settings.ElixirSuite__Default_Reservation_Start_Minutes__c;
        Integer defaultStartMinutes = startMinutes.intValue();

        Decimal  endHours = settings.ElixirSuite__Default_Reservation_End_Hours__c;
        Integer defaultEndHours = endHours.intValue();
        Decimal  endMinutes = settings.ElixirSuite__Default_Reservation_End_Minutes__c;
        Integer defaultEndMinutes = endMinutes.intValue();

        integer seconds=0;

        // Update the start and end dates with the custom settings' hours and minutes
        startDate = Datetime.newInstance(Date.valueOf(startDate), Time.newInstance(defaultStartHours, defaultStartMinutes, 0, 0));
        endDate = Datetime.newInstance(Date.valueOf(endDate), Time.newInstance(defaultEndHours, defaultEndMinutes, 0, 0));
        List<ElixirSuite__Reservation__c> reservations = [
                SELECT
                    Id
                FROM
                    ElixirSuite__Reservation__c
                WHERE
                    ElixirSuite__Account__c =:accountId
                AND
                    (ElixirSuite__Status__c IN ('Active','Confirmed', 'Scheduled', 'Pending')
                AND
                    (NOT((ElixirSuite__Start_Date__c > :startDate AND ElixirSuite__Start_Date__c >= :endDate) OR (ElixirSuite__End_Date__c <= :startDate AND ElixirSuite__End_Date__c < :endDate))))
                WITH SECURITY_ENFORCED];
        if(reservations!=null && reservations.size()>0){
            isOverlapping = true;
        }        
        return isOverlapping;
    }
    
    @AuraEnabled
     /**
    * @description saveReservationData
    * @param accountId The Id of the Account for which the reservation data is to be saved. 
    * @param startDate The start date of the reservation. 
    * @param endDate The end date of the reservation. 
    * @param selectedBeds A comma-separated string representing the selected beds for the reservation. 
    */
    public static void saveReservationData(String accountId, Datetime startDate, Datetime endDate, String selectedBeds, String billableEntity, String totalPrice, String totalNetPrice, String reservationType) {
        List<TableRow> deserializedTableRows = (List<TableRow>) JSON.deserializeStrict(selectedBeds, List<TableRow>.class);
        
        List<BillableEntity> deserializedBillable = (List<BillableEntity>) JSON.deserializeStrict(billableEntity, List<BillableEntity>.class);
        
        List<String> bedsToBook = new List<String>();
        
        for (TableRow wrap : deserializedTableRows) {
            bedsToBook.add(wrap.bedId);
        }


        ElixirSuite__Elixir_Custom_Setting__c settings = ElixirSuite__Elixir_Custom_Setting__c.getOrgDefaults();
     
       
        Decimal startHours = settings.ElixirSuite__Default_Reservation_Start_Hours__c;
        Integer defaultStartHours = startHours.intValue();
        Decimal startMinutes = settings.ElixirSuite__Default_Reservation_Start_Minutes__c;
        Integer defaultStartMinutes = startMinutes.intValue();

        Decimal  endHours = settings.ElixirSuite__Default_Reservation_End_Hours__c;
        Integer defaultEndHours = endHours.intValue();
        Decimal  endMinutes = settings.ElixirSuite__Default_Reservation_End_Minutes__c;
        Integer defaultEndMinutes = endMinutes.intValue();

        integer seconds=0;

        // Update the start and end dates with the custom settings' hours and minutes
        startDate = Datetime.newInstance(Date.valueOf(startDate), Time.newInstance(defaultStartHours, defaultStartMinutes, 0, 0));
        endDate = Datetime.newInstance(Date.valueOf(endDate), Time.newInstance(defaultEndHours, defaultEndMinutes, 0, 0));

        assertThatTheseBedsAreAvailable(bedsToBook, startDate, endDate);

        //Insert Reservation record 
        ElixirSuite__Reservation__c res=new ElixirSuite__Reservation__c();
        res.ElixirSuite__Account__c	=accountId;
        res.ElixirSuite__Start_Date__c=startDate;
        res.ElixirSuite__End_Date__c=endDate;
        res.ElixirSuite__Status__c='Pending';
        res.ElixirSuite__Total_price__c=Decimal.valueOf(totalPrice);
        res.ElixirSuite__Total_net_price__c=Decimal.valueOf(totalNetPrice);
        res.ElixirSuite__Reservation_Type__c=reservationType;
        
       /* string latestActiveCareEpisodeId = getLatestActiveCareEpisode(accountId);
        
        if (String.isNotBlank(latestActiveCareEpisodeId)) {
            res.ElixirSuite__Visit__c = latestActiveCareEpisodeId;
        }*/
        
        DMLManager.insertAsUser(res);
        
         // Insert reservation line items based on selected beds

        List<ElixirSuite__Reservation_Line_Item__c> resLineItems = new List<ElixirSuite__Reservation_Line_Item__c>();
        for (TableRow wrap : deserializedTableRows) {
            switch on wrap.type  {
                when 'building' {
                Reservation_Line_Item__c lineItemBuilding = new Reservation_Line_Item__c();
                    lineItemBuilding.ElixirSuite__Reservation__c = res.Id;
                    lineItemBuilding.ElixirSuite__Start_Date__c = startDate;
                    lineItemBuilding.ElixirSuite__End_Date__c = endDate;
                    lineItemBuilding.ElixirSuite__Bed__c = wrap.bedId;
                    lineItemBuilding.ElixirSuite__Building__c = wrap.buildingId;
                    lineItemBuilding.ElixirSuite__Bed_Status__c='Pending';
                    resLineItems.add(lineItemBuilding);
                }
                when 'room'{
                    Reservation_Line_Item__c lineItemRoom = new Reservation_Line_Item__c();
                    lineItemRoom.ElixirSuite__Reservation__c = res.Id;
                    lineItemRoom.ElixirSuite__Start_Date__c = startDate;
                    lineItemRoom.ElixirSuite__End_Date__c = endDate;
                    lineItemRoom.ElixirSuite__Bed__c = wrap.bedId;
                    lineItemRoom.ElixirSuite__Room__c = wrap.roomId;
                    lineItemRoom.ElixirSuite__Building__c = wrap.buildingId;
                    lineItemRoom.ElixirSuite__Bed_Status__c='Pending';
                    resLineItems.add(lineItemRoom);
                }
                when 'room_suite'{
                    Reservation_Line_Item__c lineItemRoomSuite = new Reservation_Line_Item__c();
                    lineItemRoomSuite.ElixirSuite__Reservation__c = res.Id;
                    lineItemRoomSuite.ElixirSuite__Start_Date__c = startDate;
                    lineItemRoomSuite.ElixirSuite__End_Date__c = endDate;
                    lineItemRoomSuite.ElixirSuite__Bed__c = wrap.bedId;
                    lineItemRoomSuite.ElixirSuite__Room__c = wrap.roomId;
                    lineItemRoomSuite.ElixirSuite__Suite__c = wrap.suiteId;
                    lineItemRoomSuite.ElixirSuite__Building__c = wrap.buildingId;
                    lineItemRoomSuite.ElixirSuite__Bed_Status__c='Pending';
                    resLineItems.add(lineItemRoomSuite);
                }
                when 'suite'{
                    Reservation_Line_Item__c lineItemSuite = new Reservation_Line_Item__c();
                    lineItemSuite.ElixirSuite__Reservation__c = res.Id;
                    lineItemSuite.ElixirSuite__Start_Date__c = startDate;
                    lineItemSuite.ElixirSuite__End_Date__c = endDate;
                    lineItemSuite.ElixirSuite__Bed__c = wrap.bedId;
                    lineItemSuite.ElixirSuite__Suite__c = wrap.suiteId;
                    lineItemSuite.ElixirSuite__Building__c = wrap.buildingId;
                    lineItemSuite.ElixirSuite__Bed_Status__c='Pending';
                    resLineItems.add(lineItemSuite);
                }

        }
        }
        List<Reservation_Line_Item__c> billableLineItem = new List<Reservation_Line_Item__c>();
        
        for(BillableEntity b : deserializedBillable){
            switch on b.recordTypeName {
                when 'Suite' {
                    Reservation_Line_Item__c item = new Reservation_Line_Item__c();
                    item.ElixirSuite__Reservation__c = res.Id;
                    item.ElixirSuite__Start_Date__c = startDate;
                    item.ElixirSuite__End_Date__c = endDate;
                    item.ElixirSuite__Suite__c = b.locationId;
                    if(b.selectedDiscountType == '%'){
                        item.ElixirSuite__Discount_type__c = 'percent';
                    }
                    if(b.selectedDiscountType == '$'){
                        item.ElixirSuite__Discount_type__c = 'flat';
                    }
                    item.ElixirSuite__isBillable__c = 'True';
                    item.ElixirSuite__Bed_Status__c='Pending';
                    item.ElixirSuite__Net_price__c = Decimal.valueOf(b.netPrice);
                    Date date1 = startDate.date();
                    Date date2 = endDate.date();
                    Integer daysDifference = date1.daysBetween(date2);
                    item.ElixirSuite__Unit_Price__c = b.price/daysDifference;
                    item.ElixirSuite__Total_price__c = b.price;
                    item.ElixirSuite__Discount__c = Decimal.valueOf(b.selectedDiscountValue);
                    billableLineItem.add(item);
                    
                }
                when 'Room' {
                    Reservation_Line_Item__c item = new Reservation_Line_Item__c();
                    item.ElixirSuite__Reservation__c = res.Id;
                    item.ElixirSuite__Start_Date__c = startDate;
                    item.ElixirSuite__End_Date__c = endDate;
                    item.ElixirSuite__Room__c = b.locationId;
                    if(b.selectedDiscountType == '%'){
                        item.ElixirSuite__Discount_type__c = 'percent';
                    }
                    if(b.selectedDiscountType == '$'){
                        item.ElixirSuite__Discount_type__c = 'flat';
                    }
                    item.ElixirSuite__isBillable__c = 'True';
                    item.ElixirSuite__Bed_Status__c='Pending';
                    item.ElixirSuite__Net_price__c = Decimal.valueOf(b.netPrice);
                    Date date1 = startDate.date();
                    Date date2 = endDate.date();
                    Integer daysDifference = date1.daysBetween(date2);
                    item.ElixirSuite__Unit_Price__c = b.price/daysDifference;
                    item.ElixirSuite__Total_price__c = b.price;
                    item.ElixirSuite__Discount__c = Decimal.valueOf(b.selectedDiscountValue);
                    billableLineItem.add(item);
                    
                }
                when 'Bed' {
                    Reservation_Line_Item__c item = new Reservation_Line_Item__c();
                    item.ElixirSuite__Reservation__c = res.Id;
                    item.ElixirSuite__Start_Date__c = startDate;
                    item.ElixirSuite__End_Date__c = endDate;
                    item.ElixirSuite__Bed__c = b.locationId;
                    if(b.selectedDiscountType == '%'){
                        item.ElixirSuite__Discount_type__c = 'percent';
                    }
                    if(b.selectedDiscountType == '$'){
                        item.ElixirSuite__Discount_type__c = 'flat';
                    }
                    item.ElixirSuite__isBillable__c = 'True';
                    item.ElixirSuite__Bed_Status__c='Pending';
                    item.ElixirSuite__Net_price__c = Decimal.valueOf(b.netPrice);
                    Date date1 = startDate.date();
                    Date date2 = endDate.date();
                    Integer daysDifference = date1.daysBetween(date2);
                    item.ElixirSuite__Unit_Price__c = b.price/daysDifference;
                    item.ElixirSuite__Total_price__c = b.price;
                    item.ElixirSuite__Discount__c = Decimal.valueOf(b.selectedDiscountValue);
                    billableLineItem.add(item);
                    
                }
            }
        }
        DMLManager.insertAsUser(resLineItems);
        DMLManager.insertAsUser(billableLineItem);
        Map<Id, Reservation__c> reservationMap = new Map<Id, Reservation__c>([Select Id, Account__c, Status__c from Reservation__c where Id=:res.Id]);
        ReservationDashboardHelper.createResercationDashboard(reservationMap);
        
    }
     /**
    * @description updateTime
    * @return Datetime representing dateTimeValue
    * @param dateTimeValue The dateTime value (GMT) for the updated DateTime. 
    * @param yearValue The year value (GMT) for the updated DateTime. 
    * @param monthValue The month value (GMT) for the updated DateTime.
    * @param dateValue The day of the month (GMT) for the updated DateTime. 
    * @param hourValue The hour value (GMT) for the updated DateTime. 
    * @param minuteValue The minute value (GMT) for the updated DateTime.
    * @param secondValue The second value (GMT) for the updated DateTime.
    */
    public static Datetime updateTime(Datetime dateTimeValue,Integer yearValue, Integer monthValue, Integer dateValue, Integer hourValue, Integer minuteValue, Integer secondValue) {
        
        
        if (dateTimeValue != null) {
            // Create a new Datetime with the same date as the original and updated time
            //dateTimeValue = Datetime.newInstanceGmt(yearValue, monthValue, dateValue, hourValue,minuteValue,secondValue );
           dateTimeValue = Datetime.newInstance(yearValue, monthValue, dateValue, hourValue,minuteValue,secondValue );
        }
        return dateTimeValue;
    }
    @AuraEnabled
     /**
    * @description getURL
    * @return string representing url
    * @param accountId The Id of the Account for which the related ElixirSuite__Reservation__c record URL is needed.
    */
    public static string getURL(String accountId){
        
        String url =system.URL.getSalesforceBaseUrl().toExternalForm() ;
        
        url = url + '/'+'lightning/r/'+accountId+'/'+'related/ElixirSuite__Reservation__c/view';
        return url;

    }

    @AuraEnabled
     /**
    * @description getLatestActiveCareEpisode
    * @return string representing ''
    * @param accountId The Id of the Account.
    */
    public static string getLatestActiveCareEpisode(String accountId){
        try {
            List<Visits__c> careEpisodes = new List<Visits__c>();
            careEpisodes = [
                SELECT 
                    Id
                FROM
                    Visits__c
                WHERE
                    ElixirSuite__Account__c = :accountId
                AND
                    ElixirSuite__Status__c = 'Active'
                WITH 
                    SECURITY_ENFORCED
                ORDER BY
                    CreatedDate DESC
                LIMIT 
                    1 ];

            if (careEpisodes.size() > 0) {
                return careEpisodes[0].Id;
            }
            return '';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String getUserDate() {
        String currentUserDate='';
         // Get the user's time zone as a System.TimeZone object
         TimeZone userTimeZone = UserInfo.getTimeZone();

         // Get the current date and time in GMT (GMT is the default time zone for DateTime)
         Datetime userDateTimeGmt = Datetime.now();
         
         // Set the time zone for the userDateTimeGmt
         userDateTimeGmt = userDateTimeGmt.addSeconds(userTimeZone.getOffset(userDateTimeGmt) / 1000);
         
         // Format the Datetime as a date string in 'yyyy-MM-dd' format
         String userDate = userDateTimeGmt.format('yyyy-MM-dd');
         System.debug('userDate'+userDate);
		if(String.isNotBlank(userDate)){
         currentUserDate =userDate;
         }
        return currentUserDate;
       
    }
    
}