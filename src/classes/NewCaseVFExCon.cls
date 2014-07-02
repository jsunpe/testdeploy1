public class NewCaseVFExCon {
	
	private ApexPages.StandardController stdCon;
	private Case currentCase{
		get{
			return (Case) stdCon.getRecord();
		}
	}

    public NewCaseVFExCon(ApexPages.StandardController controller) {
    	this.stdCon = controller;
    	String accountIdStr = ApexPages.currentPage().getParameters().get('def_account_id');
    	if(accountIdStr != null)currentCase.AccountId = (Id)accountIdStr;
    	String contactIdStr = ApexPages.currentPage().getParameters().get('def_contact_id');
    	if(contactIdStr != null)currentCase.ContactId = (Id)contactIdStr;
    }

}