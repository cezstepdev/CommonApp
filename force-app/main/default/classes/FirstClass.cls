public with sharing class FirstClass {
    public FirstClass() {
        System.debug('hi');
    }

    @AuraEnabled(cacheable=true)
    public static List<Contact> getOpps( String searchKey, String sortBy, String sortDirection) {
        
        String query = 'SELECT Id, Name FROM Contact';
        system.debug('query---'+query);
        if ( searchKey != null && searchKey != '' ) {
            String key = '%' + searchKey + '%';
            query += ' WHERE Name LIKE :key';
        }
        if ( sortBy != null && sortDirection != null ) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        return Database.query( query );
    }

    @AuraEnabled
    public static Id addCall(CallObject myCall) {
        System.debug(myCall);
        Call__c call = new Call__c();
        call.Call_Date__c = myCall.callDate;
        call.Type__c = myCall.callType;
        insert call;

        List<CallMember__c> callMembers = new List<CallMember__c>();
        if(myCall.accountId != null) {
            for (Contact contact : [SELECT Id FROM Contact WHERE AccountId = :myCall.accountId]) {
                CallMember__c callMember = new CallMember__c();
                callMember.Contact__c = contact.Id;
                callMember.Call__c = call.Id;
                callMembers.add(callMember);
            }
        }
        else {
            for (String member : myCall.members) {
                CallMember__c callMember = new CallMember__c();
                callMember.Contact__c = member;
                callMember.Call__c = call.Id;
                callMembers.add(callMember);
            }
        }

        insert callMembers;
        return call.Id;
    }

    @AuraEnabled(cacheable=true)
    public static List<CallMember__c> getCallMembersList(Id callId){
            try {
                return [
                    SELECT Id, Call__c, Contact__r.Name
                    FROM CallMember__c
                    WHERE Call__r.Id =: callId
                ];
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    class CallObject {
        public CallObject() {

        }

        @AuraEnabled
        public String accountId {get; set;}
        @AuraEnabled
        public Datetime callDate {get; set;}
        @AuraEnabled 
        public List<String> members {get; set;}
        @AuraEnabled
        public String callType {get; set;}
    }
}
