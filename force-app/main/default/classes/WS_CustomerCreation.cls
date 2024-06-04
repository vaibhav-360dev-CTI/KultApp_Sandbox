@RestResource(urlMapping='/CustomerCreation')
global class WS_CustomerCreation {
    
    public class OMSToSFDCAccount {

        public String uuid;
        public String phone_number;
        public String email_id;
        public String name;
        public boolean is_deleted;
	
    }
    global class ResponseBody {
        public String status;
        public String message;
        public String accountId;
    }
	@Httppost
        global static List<ResponseBody> createAccount(){
            RestRequest req = RestContext.request;
            RestResponse response = RestContext.response;
            List<ResponseBody> respBodyList = new List<ResponseBody>();
            String jsonResponse = '';
            
            try{
                List<OMSToSFDCAccount> requestBody = (List<OMSToSFDCAccount>)JSON.deserialize(req.requestBody.toString(), List<OMSToSFDCAccount>.class);
                Map<String,OMSToSFDCAccount> cxDetailsByUUID = new Map<String,OMSToSFDCAccount>();
                Map<String,String> AccIdByUUID = new Map<String,String>();
                Set<String> uuidSet = new Set<String>();
                List<Account> accListToUpsert = new List<Account>();

                if(!requestBody.isEmpty()){
                    for(OMSToSFDCAccount accDetRec : requestBody){
                        uuidSet.add(accDetRec.uuid);
                        cxDetailsByUUID.put(accDetRec.uuid, accDetRec);
                    }
                    if(!uuidSet.isEmpty()){
                        List<Account> existingAccountList = [SELECT Id, Name, Phone, Email__c, UUID__c FROM Account WHERE UUID__c IN: uuidSet];
                        if(!existingAccountList.isEmpty()){
                            for(Account accRec : existingAccountList){
                                AccIdByUUID.put(accRec.UUID__c, accRec.Id);
                            }
                        }
                    }
                    for(String mapKey : cxDetailsByUUID.keySet()){
                        Account accRecord = new Account();
                        if(cxDetailsByUUID.get(mapKey).uuid != null){
                            accRecord.UUID__c = cxDetailsByUUID.get(mapKey).uuid;
                        }
                        if(AccIdByUUID.containsKey(mapKey)){
                            accRecord.Id = AccIdByUUID.get(mapKey);
                        }
                        accRecord.Name = cxDetailsByUUID.get(mapKey).name != null ? cxDetailsByUUID.get(mapKey).name : 'New - ' + cxDetailsByUUID.get(mapKey).phone_number;
                        accRecord.Phone = cxDetailsByUUID.get(mapKey).phone_number != null ? cxDetailsByUUID.get(mapKey).phone_number : '';
                        accRecord.Email__c = cxDetailsByUUID.get(mapKey).email_id != null ? cxDetailsByUUID.get(mapKey).email_id: '';
                        accRecord.Is_Deleted__c = cxDetailsByUUID.get(mapKey).is_deleted != null ? cxDetailsByUUID.get(mapKey).is_deleted : false;
                        accListToUpsert.add(accRecord);
                    }
                    Database.UpsertResult[] upsertResults = Database.upsert(accListToUpsert,Account.Id, true);
                for(Integer i = 0; i < upsertResults.size(); i++) {
                    Database.UpsertResult result = upsertResults[i];
                    Account upsertedAccount = accListToUpsert[i];
                    
                    if(result.isSuccess()) {
                        ResponseBody res = new ResponseBody();
                        res.status = 'Success';
                        res.message = 'User created/updated successfully';
                        res.accountId = upsertedAccount.Id;
                        respBodyList.add(res);
                    } else {
                        for(Database.Error error : result.getErrors()) {
                            System.debug('Error message: ' + error.getMessage());
                            ResponseBody res = new ResponseBody();
                        res.status = 'Error';
                        res.message = 'Failed to create user. ' + error.getMessage();
                        res.accountId = upsertedAccount.Id;
                        respBodyList.add(res);
                        }
                        RestContext.response.statusCode = 400;
                    }

                }
                
            }
        }
            catch (Exception e) {
                ResponseBody res = new ResponseBody();
                res.status = 'Error';
                res.message = 'Failed to create user. ' + e.getMessage();
                respBodyList.add(res);
                RestContext.response.statusCode = 400;
            }
              return respBodyList;            
        }

}