global class ChangeShowTimes implements Schedulable {

    public static List<Profile> allProfiles;
    public static List<Id> allUsers;
    public static List<Id> allRecordOwners;
    
    public static void searchAllProfiles() {
        
        allProfiles = [SELECT Id FROM Profile WHERE Name != 'System Administrator'];
    }
    
    public static void searchAllUsers() {
        
        allUsers = new List<Id>();
        
        for (Profile eachProfile: allProfiles) {
            
            allUsers.add(eachProfile.Id);
        }
    }
    
    public static void searchAllRecordOwners() {
        
        allRecordOwners = new List<Id>();
        
        for (User eachUser: [SELECT Id FROM User WHERE ProfileId IN :allUsers]) {
            
            allRecordOwners.add(eachUSer.Id);
        }
    }
    
    public static void deleteMovies() {
        
        integer recordCount = 0;
        
        List<Movie__c> moviesToBeDeleted = new List<Movie__c>();
        
        for (Movie__c eachMovie: [SELECT Name FROM Movie__c WHERE OwnerId IN :allRecordOwners]) {
            
            moviesToBeDeleted.add(eachMovie);
            
            recordCount++;
        }
        
        if (recordCount > 0) {
            
            delete moviesToBeDeleted;
        }
    }
    
    public static void deleteCinemas() {
        
        integer recordCount = 0;
        
        List<Cinema__c> cinemasToBeDeleted = new List<Cinema__c>();
        
        for (Cinema__c eachCinema: [SELECT Name FROM Cinema__c WHERE OwnerId IN :allRecordOwners]) {
            
            cinemasToBeDeleted.add(eachCinema);
            
            recordCount++;
        }
        
        if (recordCount > 0) {
            
            delete cinemasToBeDeleted;
        }
    }    
    
    global static void execute(SchedulableContext runSchedule) {
        
        searchAllProfiles();
        searchAllUsers();
        searchAllRecordOwners();
        
        deleteMovies();
        deleteCinemas();        
    }
}
