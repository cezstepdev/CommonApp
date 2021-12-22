public with sharing class ContactTriggerHandler extends TriggerHandler {
    private List<Account> newList;
    private List<Account> oldList;
    private Map<Id, Account> newMap;
    private Map<Id, Account> oldMap;

    public ContactTriggerHandler () {
        this.newList = Trigger.new;
        this.oldList = Trigger.old;
        this.newMap = (Map<Id, Account>)Trigger.newMap;
        this.oldMap = (Map<Id, Account>)Trigger.oldMap;
    }

    public override void afterInsert() {
        Account account = [SELECT Name FROM Contact WHERE Id =: newList.get(0).AccountId];
        for(Contact contact : newList){
            account.Name += ' i '+contact.FirstName;
        }
        update account;
    }
}
