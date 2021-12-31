public with sharing class CallController {

    @AuraEnabled
    public static List<CallWrapper> getIncomingCalls(){
        try {
            List<CallWrapper> wrapperList = new List<CallWrapper>();
       for(Call__c call :[SELECT Id,Name,Account__c,Type__c,Call_date__c FROM Call__c ORDER BY Call_date__c DESC LIMIT 10]){
                CallWrapper wrapper = new CallWrapper();
                wrapper.Id = call.Id;
                wrapper.Name = call.Name;
                wrapper.type = call.Type__c;
                wrapper.callDate = call.Call_date__c;
                wrapper.account = call.Account__c == null ? null : [SELECT Id,Name FROM Account WHERE Id =: call.Account__c LIMIT 1];
                wrapperList.add(wrapper);
            }
            return wrapperList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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
        call.Account__c = myCall.accountId;
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
        List<String> callMembersId = new List<String>();
        List<CallMember__c> callMembers = [
            SELECT Contact__c 
            FROM CallMember__c 
            WHERE Call__c = :callId
        ];

        for(CallMember__c callMember : callMembers) {
            callMembersId.add(callMember.Contact__c);
        }

        List<MemberTask__c> tasks = [
            SELECT Id, Call__c
            FROM MemberTask__c
            WHERE Task_End__c = null
            AND Contact__c IN :callMembersId
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

    class CallWrapper{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public DateTime callDate;
        @AuraEnabled
        public Account account;

        CallWrapper(){}
    }
}
