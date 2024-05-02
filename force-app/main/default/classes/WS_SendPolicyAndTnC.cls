@RestResource(urlMapping='/PoilcyAndTnCFetch')
global class WS_SendPolicyAndTnC {

    global class SFDCtoMobileApp {
        public String tnc;
        public String privacy_policy;	
        public String status;
        public String message;
    }

    @HttpGet
    global static SFDCtoMobileApp sendData(){
        SFDCtoMobileApp data = new SFDCtoMobileApp();
        data.tnc = '';
        data.privacy_policy = '';

        try{
            List<App_Data__c> appDataList = [SELECT Id, Name, Privacy_Policy__c, Terms_and_Conditions__c FROM App_Data__c ORDER BY LastModifiedDate DESC LIMIT 1];
            if(!appDataList.isEmpty()){
                data.tnc = appDataList[0].Terms_and_Conditions__c;
                data.privacy_policy = appDataList[0].Privacy_Policy__c;
            }
        }catch(exception e){
            data.status = 'Error';
            data.message = e.getMessage();
        }
        return data;
    }

}