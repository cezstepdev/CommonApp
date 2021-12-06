public with sharing class AccountTriggerHandler extends TriggerHandler {
    private List<Account> newList;
    private List<Account> oldList;
    private Map<Id, Account> newMap;
    private Map<Id, Account> oldMap;

    public AccountTriggerHandler () {
        this.newList = Trigger.new;
        this.oldList = Trigger.old;
        this.newMap = (Map<Id, Account>)Trigger.newMap;
        this.oldMap = (Map<Id, Account>)Trigger.oldMap;
    }

    public override void beforeInsert() {
        System.debug('TEST');
    }
}