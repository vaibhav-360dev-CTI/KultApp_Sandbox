@IsTest
public class getCountryAndStatePicklistsTest {
    
    @IsTest
    static void testGetCountries() {
        Test.setMock(HttpCalloutMock.class, new CountryCalloutMock());

        List<getCountryAndStatePicklists.Country> countries = getCountryAndStatePicklists.getCountries();
        
        System.assertEquals(2, countries.size());
        System.assertEquals('United States', countries[0].label);
        System.assertEquals('US', countries[0].value);
        System.assertEquals('Canada', countries[1].label);
        System.assertEquals('CA', countries[1].value);
    }
    
    @IsTest
    static void testGetStates() {
        Test.setMock(HttpCalloutMock.class, new StateCalloutMock());

        List<getCountryAndStatePicklists.State> states = getCountryAndStatePicklists.getStates();
        
    }
    
    @IsTest
    static void testGetAddressSettings() {
        Test.setMock(HttpCalloutMock.class, new CombinedCalloutMock());

        Map<String, List<Object>> addressSettings = getCountryAndStatePicklists.getAddressSettings();
        
        List<getCountryAndStatePicklists.Country> countries = (List<getCountryAndStatePicklists.Country>) addressSettings.get('countries');
        System.assertNotEquals(null, countries);
        System.assertEquals(2, countries.size());
        System.assertEquals('United States', countries[0].label);
        System.assertEquals('US', countries[0].value);
        System.assertEquals('Canada', countries[1].label);
        System.assertEquals('CA', countries[1].value);

        List<getCountryAndStatePicklists.State> states = (List<getCountryAndStatePicklists.State>) addressSettings.get('states');
        System.assertNotEquals(null, states);
        System.assertEquals(2, states.size());
        System.assertEquals('California', states[0].label);
        System.assertEquals('CA', states[0].value);
        System.assertEquals('US', states[0].dependingOn);
        System.assertEquals('Ontario', states[1].label);
        System.assertEquals('ON', states[1].value);
        System.assertEquals('CA', states[1].dependingOn);
    }

    private class CountryCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"values":[{"label":"United States","value":"US"},{"label":"Canada","value":"CA"}]}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class StateCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"values":[{"label":"California","value":"CA","validFor":[0]},{"label":"Ontario","value":"ON","validFor":[1]}],"controllerValues":{"US":0,"CA":1}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class CombinedCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('BillingCountryCode')) {
                res.setBody('{"values":[{"label":"United States","value":"US"},{"label":"Canada","value":"CA"}]}');
            } else if (req.getEndpoint().contains('BillingStateCode')) {
                res.setBody('{"values":[{"label":"California","value":"CA","validFor":[0]},{"label":"Ontario","value":"ON","validFor":[1]}],"controllerValues":{"US":0,"CA":1}}');
            }
            res.setStatusCode(200);
            return res;
        }
    }
}