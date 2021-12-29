public with sharing class CallController1 {
    public CallController1() {

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
        updateTasks(call.Id);
        return call.Id;
    }

    public static void updateTasks(String callId) {
        List<MemberTask__c> tasks = [
            SELECT Id, Call__c
            FROM MemberTask__c
            WHERE Task_End__c = null
        ];

        List<MemberTask__c> memberTasks = new List<MemberTask__c>();
        
        for(MemberTask__c task : tasks) {
            task.Call__c = callId;
            memberTasks.add(task);
        }

        update memberTasks;
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
