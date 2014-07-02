public with sharing class QuickCreateToolbarCon {

/*
    Type:       Controller
    Purpose:    Controls the quick access toolbar

    Used By:    QuickCreateToolbar component
    ---------------------------------------------------------------
    History:

    23-Dec-2011 J.Pe (Davanti Consulting)    Created

*/
    public static String NO_RECORD_TYPE_SO_VALUE {get{return 'XXXXXXXX';}}
    
    /* CURRENT RECORD - PROPERTIES */
    public Id currentRecordId {
        get ;
        set{
            if(value != currentRecordId){
                currentRecordId = value;
                resetRecords();
                if(value != null ){
                    setUpRecords();
                }
            }
        }
    }
    public Account      currentAccount          {get;private set;}
    public Contact      currentContact          {get;private set;}
    public Case         currentCase             {get;private set;}
    public Opportunity  currentOpportunity      {get;private set;}
    public Asset        currentAsset            {get;private set;}
    public Contract     currentContract         {get;private set;}
    
    public Schema.SObjectType currentObjectType {
        get {
            if (currentRecordId != null && currentObjectType == null) {
                currentObjectType = getSObjectType(currentRecordId);
            }
            return currentObjectType;
        }
        private set;
    }
    private void setUpRecords(){
        if(currentObjectType!=null){
            if(currentObjectType == Account.sObjectType){
                setUpAccountWithCurrentId();
            }
            if(currentObjectType == Contact.sObjectType){
                setUpContactWithCurrentId();
            }
            if(currentObjectType == Case.sObjectType){
                setUpCaseWithCurrentId();
            }
            if(currentObjectType == Opportunity.sObjectType){
                setUpOpportunityWithCurrentId();
            }
            if(currentObjectType == Asset.sObjectType){
                setUpAssetWithCurrentId();
            }
            if(currentObjectType == Contract.sObjectType){
                setUpContractWithCurrentId();
            }
        }
    }
    
    /* CURRENT RECORD - METHODS */
    private void resetRecords(){
        currentAccount = null;
        currentContact = null;
        currentCase = null;
        currentOpportunity = null;
        currentAsset = null;
        currentContract = null;
        currentObjectType = null;
    }
    private void setUpContactWithCurrentId(){
        currentContact = [Select id, Name, Account.Id, Account.Name from Contact where id = :currentRecordId];
        currentAccount = currentContact.Account;
    }
    private void setUpAccountWithCurrentId(){
        currentAccount = [Select id, Name from Account where id = :currentRecordId];
    }
    private void setUpCaseWithCurrentId(){
        currentCase = [Select Id, CaseNumber, Account.Id, Account.Name, Contact.Id, Contact.Name from Case where id = :currentRecordId];
        currentContact = currentCase.Contact;
        currentAccount = currentCase.Account;
    }
    private void setUpOpportunityWithCurrentId(){
        currentOpportunity = [Select Id, Name, Account.Id, Account.Name, (Select ContactId, IsPrimary, IsDeleted From OpportunityContactRoles where IsDeleted = false and IsPrimary = true) from Opportunity where id = :currentRecordId];
        currentAccount = currentOpportunity.Account;
        List<OpportunityContactRole> oppContactRoles = currentOpportunity.getSObjects('OpportunityContactRoles');
        if(oppContactRoles != null && !oppContactRoles.isEmpty()){
            currentContact = [Select Id, Name from Contact where id = : oppContactRoles[0].ContactId];
        }
    }
    private void setUpAssetWithCurrentId(){
        currentAsset = [Select Id, Name, Account.Id, Account.Name, Contact.Id, Contact.Name from Asset where id = :currentRecordId];
        currentContact = currentAsset.Contact;
        currentAccount = currentAsset.Account;
    }
    private void setUpContractWithCurrentId(){
        currentContract = [Select Id, ContractNumber, Account.Id, Account.Name, CustomerSigned.Id, CustomerSigned.Name from Contract where id = :currentRecordId];
        currentContact = currentContract.CustomerSigned;
        currentAccount = currentContract.Account;
    }
    private static Map<String, Schema.SObjectType> globalDescribeMapByKeyPrefix{
        get{
            if(globalDescribeMapByKeyPrefix == null){
                globalDescribeMapByKeyPrefix = new Map<String, Schema.SObjectType>();
                Map<String, Schema.SObjectType> tempMap = Schema.getGlobalDescribe();
                for(Schema.SObjectType sObjType: tempMap.values()){
                    globalDescribeMapByKeyPrefix.put(sObjType.getDescribe().getKeyPrefix(),sObjType);
                }
            }
            return globalDescribeMapByKeyPrefix;
        }set;
    }
    
    /* CREATE - CASES */
    public SObjectRTypeInfoContainer caseRTypeInfoContainer{
        get{
            if(caseRTypeInfoContainer==null){
                caseRTypeInfoContainer = new SObjectRTypeInfoContainer(Case.sObjectType.getDescribe());
            }return caseRTypeInfoContainer;
        }private set;
    }
    
    public String stdCaseURLPrefix{
        get{
            PageReference pageRef = initStdPageRef(Case.sObjectType.getDescribe());
            addStdCaseParameters(pageRef);
            return pageRef.getURL();
        }
    }
    public String vfCaseURLSuffix{
        get{
            PageReference pageRefSuffixOnly = new PageReference('');
            addStdPageRefParameters(pageRefSuffixOnly, Case.sObjectType.getDescribe());
            addStdCaseParameters(pageRefSuffixOnly);
            return getURLParamSuffix(pageRefSuffixOnly);
        }
    }
    public String parentCaseParamURLSuffix{
        get{
            if(currentCase!=null){
                PageReference pageRefSuffixOnly = new PageReference('');
                pageRefSuffixOnly.getParameters().put('def_parent_id',currentCase.Id);
                String temp = getURLParamSuffix(pageRefSuffixOnly);
                return '&'+temp.substring(1,temp.length());
            }
            return '';
        }
    }
    private void addStdCaseParameters(PageReference pageRef){
        if(currentAccount!=null){
            pageRef.getParameters().put('def_account_id',currentAccount.Id);
        }
        if(currentContact!=null){
            pageRef.getParameters().put('def_contact_id',currentContact.Id);
        }
        if(currentAsset!=null){
            pageRef.getParameters().put('def_asset_id',currentAsset.Id);
        }
    } 
    
    /* CREATE - OPPORTUNITIES */
    public SObjectRTypeInfoContainer opportunityRTypeInfoContainer{
        get{
            if(opportunityRTypeInfoContainer==null){
                opportunityRTypeInfoContainer = new SObjectRTypeInfoContainer(Opportunity.sObjectType.getDescribe());
            }return opportunityRTypeInfoContainer;
        }private set;
    }
    
    public String stdOpportunityURLPrefix{
        get{
            PageReference pageRef = initStdPageRef(Opportunity.sObjectType.getDescribe());
            addStdOpportunityParameters(pageRef);
            return pageRef.getURL();
        }
    }
    public String vfOpportunityURLSuffix{
        get{
            PageReference pageRefSuffixOnly = new PageReference('');
            addStdPageRefParameters(pageRefSuffixOnly, Opportunity.sObjectType.getDescribe());
            addStdOpportunityParameters(pageRefSuffixOnly);
            return getURLParamSuffix(pageRefSuffixOnly);
        }
    }
    private void addStdOpportunityParameters(PageReference pageRef){
        if(currentAccount!=null){
            pageRef.getParameters().put('accid',currentAccount.Id);
        }
        if(currentContact!=null){
            pageRef.getParameters().put('conid',currentContact.Id);
        }
    }
    
    /* CREATE - ASSETS */
    public SObjectRTypeInfoContainer assetRTypeInfoContainer{
        get{
            if(assetRTypeInfoContainer==null){
                assetRTypeInfoContainer = new SObjectRTypeInfoContainer(Asset.sObjectType.getDescribe());
            }return assetRTypeInfoContainer;
        }private set;
    }
    
    public String stdAssetURLPrefix{
        get{
            PageReference pageRef = initStdPageRef(Asset.sObjectType.getDescribe());
            addStdAssetParameters(pageRef);
            return pageRef.getURL();
        }
    }
    public String vfAssetURLSuffix{
        get{
            PageReference pageRefSuffixOnly = new PageReference('');
            addStdPageRefParameters(pageRefSuffixOnly, Asset.sObjectType.getDescribe());
            addStdAssetParameters(pageRefSuffixOnly);
            return getURLParamSuffix(pageRefSuffixOnly);
        }
    }
    private void addStdAssetParameters(PageReference pageRef){
        if(currentAccount!=null){
            pageRef.getParameters().put('acc_id',currentAccount.Id);
        }
        if(currentContact!=null){
            pageRef.getParameters().put('cntc_id',currentContact.Id);
        }
    }
    
    /* CREATE - CONTRACTS */
    public SObjectRTypeInfoContainer contractRTypeInfoContainer{
        get{
            if(contractRTypeInfoContainer==null){
                contractRTypeInfoContainer = new SObjectRTypeInfoContainer(Contract.sObjectType.getDescribe());
            }return contractRTypeInfoContainer;
        }private set;
    }
    
    public String stdContractURLPrefix{
        get{
            PageReference pageRef = initStdPageRef(Contract.sObjectType.getDescribe());
            addStdContractParameters(pageRef);
            return pageRef.getURL();
        }
    }
    public String vfContractURLSuffix{
        get{
            PageReference pageRefSuffixOnly = new PageReference('');
            addStdPageRefParameters(pageRefSuffixOnly, Contract.sObjectType.getDescribe());
            addStdContractParameters(pageRefSuffixOnly);
            return getURLParamSuffix(pageRefSuffixOnly);
        }
    }
    private void addStdContractParameters(PageReference pageRef){
        if(currentAccount!=null){
            pageRef.getParameters().put('accid',currentAccount.Id);
        }
        /*
        if(currentContact!=null){
            pageRef.getParameters().put('cntc_id',currentContact.Id);
        }
        */
    }
    
    /* CREATE - ALL STANDARD OBJECTS */
    public String vfURLPrefix{
        get{
            return new PageReference('/apex/').getURL();
        }
    }
    private PageReference initStdPageRef(DescribeSObjectResult sObjectDescribe){
        PageReference pageRef = new PageReference('/'+sObjectDescribe.getKeyPrefix()+'/e');
        addStdPageRefParameters(pageRef, sObjectDescribe);
        return pageRef;
    }
    private void addStdPageRefParameters(PageReference pageRef, DescribeSObjectResult sObjectDescribe){
        pageRef.getParameters().put('retURL','/'+currentRecordId);
        pageRef.getParameters().put('ent',sObjectDescribe.getName());
    }
    
    
    /* STATIC UTIL METHODS */
    private static Schema.SObjectType getSObjectType(Id recordId){
        if (recordId == null) return null;
        String recordKeyPrefix = ((String)recordId).substring(0,3);
        return globalDescribeMapByKeyPrefix.get(recordKeyPrefix);
    }
    
    private static String getSObjectTypeNameIfMatch(DescribeSObjectResult sObjectDescribe, Id recordId){
        if (((String)recordId).startsWith(sObjectDescribe.getKeyPrefix())) {
            return sObjectDescribe.getName();
        }return null;
    }
    private static String getURLParamSuffix(PageReference pageRefSuffixOnly){
        String urlParameterSuffix = pageRefSuffixOnly.getURL();
        return urlParameterSuffix.substring(urlParameterSuffix.indexOf('?'), urlParameterSuffix.length());
    }
    
    /* UTIL INNER CLASSES */
    public class SObjectRTypeInfoContainer {
        public List<SelectOption> rTypeInfoSOs{
            get{
                List<SelectOption> temp = new List<SelectOption>();
                temp.add(new SelectOption('', 'Select One...'));
                if(noOfRTypes==0){
                    temp.add(new SelectOption(NO_RECORD_TYPE_SO_VALUE,'New '+sObjectLabel));
                }else{
                    if(isDefaultFirstInList && defaultRTypeInfo != null && noOfRTypes > 1){
                        temp.add(new SelectOption(defaultRTypeInfo.recordTypeId,defaultRTypeInfo.name));
                        temp.add(new SelectOption('','------'));
                    }
                    for(RecordTypeInfo rti: rTypeInfosOrderedbyName){
                        if('Master'.equals(rti.name)){
                            if(noOfRTypes==1){
                                temp.add(new SelectOption(NO_RECORD_TYPE_SO_VALUE,'New '+sObjectLabel));
                            }
                        }else{
                            temp.add(new SelectOption(rti.recordTypeId,rti.name));
                        }
                    }
                }
                for(Integer i = 0 ; i < temp.size();i++){
                    if(rTypeVFPageMapping.containsKey(temp[i].getLabel())){
                        temp[i] = rTypeVFPageMapping.get(temp[i].getLabel());
                    }
                }
                if(!VFPageListWithoutRTypes.isEmpty()){
                    if(temp.size()>1) temp.add(new SelectOption('','------'));
                    for(SelectOption so: VFPageListWithoutRTypes){
                        temp.add(so);
                    }
                }
                return temp;
            }
        }
        public boolean isDefaultFirstInList{
            get{
                if(isDefaultFirstInList == null){
                    isDefaultFirstInList = false;
                }return isDefaultFirstInList;
            }set;
        }
        public Map<String, SelectOption> rTypeVFPageMapping{
            get{
                if(rTypeVFPageMapping == null){
                    rTypeVFPageMapping = new Map<String, SelectOption>();
                    List<QuickCreateToolbarVFOverride__c> vfOverrides = [Select SObjectType__c, RecordTypeName__c, LabelOverride__c, VFPage__c, IsActive__c from QuickCreateToolbarVFOverride__c where SObjectType__c = :sObjectName and RecordTypeName__c <> null order by Order__c ASC];
                    if(vfOverrides!=null && !vfOverrides.isEmpty()){
                        for(QuickCreateToolbarVFOverride__c vfo: vfOverrides){
                            if(vfo.IsActive__c){
                                rTypeVFPageMapping.put(vfo.RecordTypeName__c, new SelectOption(vfo.VFPage__c, ((vfo.LabelOverride__c==null || ''.equals(vfo.LabelOverride__c.trim()))?(vfo.RecordTypeName__c):(vfo.LabelOverride__c))));
                            }
                        }
                    }
                }return rTypeVFPageMapping;
            }private set;
        }
        
        public List<SelectOption> vfPageListWithoutRTypes{
            get{
                if(vfPageListWithoutRTypes == null){
                    vfPageListWithoutRTypes = new List<SelectOption>();
                    List<QuickCreateToolbarVFOverride__c> vfOverrides = [Select SObjectType__c, RecordTypeName__c, LabelOverride__c, VFPage__c, IsActive__c from QuickCreateToolbarVFOverride__c where SObjectType__c = :sObjectName and RecordTypeName__c = null order by Order__c ASC];
                    if(vfOverrides!=null && !vfOverrides.isEmpty()){
                        for(QuickCreateToolbarVFOverride__c vfo: vfOverrides){
                            if(vfo.IsActive__c){
                                vfPageListWithoutRTypes.add(new SelectOption(vfo.VFPage__c, vfo.LabelOverride__c));
                            }
                        }
                    }
                }return vfPageListWithoutRTypes;
            }private set;
        }
        
        public List<RecordTypeInfo> rTypeInfosOrderedbyName {get; private set;}
        public RecordTypeInfo defaultRTypeInfo {get;private set;}
        public Integer noOfRTypes {
            get{
                if(rTypeInfosOrderedbyName == null || rTypeInfosOrderedbyName.isEmpty()) return 0;
                return rTypeInfosOrderedbyName.size();
            }
        }
        public String sObjectLabel {get;private set;}
        public String sObjectName {get;private set;}
        
        public SObjectRTypeInfoContainer(DescribeSObjectResult sObjectDescribe){
            sObjectLabel = sObjectDescribe.getLabel();
            sObjectName = sObjectDescribe.getName();
            Map<String, Schema.RecordTypeInfo> rTypeInfosMap = sObjectDescribe.getRecordTypeInfosByName();
            if(rTypeInfosMap!= null && !rTypeInfosMap.isEmpty()){
                List<String> orderedRecordTypeNames = new List<String>(rTypeInfosMap.keySet());
                orderedRecordTypeNames.sort();
                rTypeInfosOrderedbyName = new List<RecordTypeInfo>();
                for(String rtName: orderedRecordTypeNames){
                    RecordTypeInfo rti = new RecordTypeInfo(rTypeInfosMap.get(rtName));
                    if(rti.isAvailable){
                        rTypeInfosOrderedbyName.add(rti);
                    }
                    if(rti.isDefaultRecordTypeMapping){
                        defaultRTypeInfo = rti;
                    }
                }
            }
        }
    }
    
    public class RecordTypeInfo {
        public Id recordTypeId {get;private set;}
        public String name {get; private set;}
        public boolean isAvailable {get; private set;}
        public boolean isDefaultRecordTypeMapping {get; private set;}
        public RecordTypeInfo(Schema.RecordTypeInfo rti){
            recordTypeId = rti.getRecordTypeId();
            name = rti.getName();
            isAvailable = rti.isAvailable();
            isDefaultRecordTypeMapping = rti.isDefaultRecordTypeMapping();
        }
    }
    
    /* TEST METHOD */
    public static testmethod void test_QuickCreateToolbarCon(){
        // create test data
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = 'x';
        contact.Email = 'x@x.com';
        insert contact;
        
        Case caseRec = new Case();
        caseRec.AccountId = account.id;
        caseRec.ContactId = contact.id;
        insert caseRec;
        
        Opportunity oppRec = new Opportunity();
        oppRec.Name = 'test';
        oppRec.AccountId = account.id;
        oppRec.StageName = 'test';
        oppRec.CloseDate = Date.today();
        insert oppRec;
        OpportunityContactRole oppContactRoleRec = new OpportunityContactRole();
        oppContactRoleRec.OpportunityId = oppRec.id;
        oppContactRoleRec.ContactId = contact.id;
        oppContactRoleRec.IsPrimary = true;
        insert oppContactRoleRec;
        
        Asset assetRec = new Asset();
        assetRec.Name = 'test';
        assetRec.AccountId = account.id;
        assetRec.ContactId = contact.id;
        insert assetRec;
        
        Contract contractRec = new Contract();
        contractRec.AccountId = account.id;
        contractRec.CustomerSignedId = contact.id;
        insert contractRec;
        
        delete [select id from QuickCreateToolbarVFOverride__c];
        
        QuickCreateToolbarVFOverride__c vfOverride1 = new QuickCreateToolbarVFOverride__c();
        vfOverride1.Name = 'test1';
        vfOverride1.Order__c = 1;
        vfOverride1.SobjectType__c = 'Case';
        vfOverride1.RecordTypeName__c = 'Test';
        vfOverride1.VFPage__c = 'TestABC';
        vfOverride1.LabelOverride__c = 'TestABC';
        vfOverride1.IsActive__c = true;
        insert vfOverride1;
        QuickCreateToolbarVFOverride__c vfOverride2 = new QuickCreateToolbarVFOverride__c();
        vfOverride2.Name = 'test2';
        vfOverride2.Order__c = 2;
        vfOverride2.SobjectType__c = 'Case';
        vfOverride2.VFPage__c = 'TestDEF';
        vfOverride2.LabelOverride__c = 'TestDEF';
        vfOverride2.IsActive__c = true;
        insert vfOverride2;
        QuickCreateToolbarVFOverride__c vfOverride3 = new QuickCreateToolbarVFOverride__c();
        vfOverride3.Name = 'test3';
        vfOverride3.Order__c = 3;
        vfOverride3.SobjectType__c = 'Asset';
        vfOverride3.RecordTypeName__c = 'New Asset';
        vfOverride3.VFPage__c = 'TestGHI';
        vfOverride3.LabelOverride__c = 'TestGHI';
        vfOverride3.IsActive__c = true;
        insert vfOverride3;
        
        Test.startTest();
        QuickCreateToolbarCon con = new QuickCreateToolbarCon();
        System.debug([Select id from Account where id = :account.id]);
        con.currentRecordId = account.id;
        con.currentRecordId = contact.id;
        con.currentRecordId = oppRec.id;
        con.currentRecordId = contractRec.id;
        con.currentRecordId = caseRec.id;
        List<SelectOption> tempSOs = con.caseRTypeInfoContainer.rTypeInfoSOs;
        tempSOs = con.opportunityRTypeInfoContainer.rTypeInfoSOs;
        tempSOs = con.assetRTypeInfoContainer.rTypeInfoSOs;
        tempSOs = con.contractRTypeInfoContainer.rTypeInfoSOs;
        String tempStr = con.stdCaseURLPrefix;
        tempStr = con.parentCaseParamURLSuffix;
        con.currentRecordId = assetRec.id;
        tempStr = con.parentCaseParamURLSuffix;
        tempStr = con.vfCaseURLSuffix;
        tempStr = con.stdOpportunityURLPrefix;
        tempStr = con.vfOpportunityURLSuffix;
        tempStr = con.stdAssetURLPrefix;
        tempStr = con.vfAssetURLSuffix;
        tempStr = con.stdContractURLPrefix;
        tempStr = con.vfContractURLSuffix;
        tempStr = con.vfURLPrefix;
    }
}