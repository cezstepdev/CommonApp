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
