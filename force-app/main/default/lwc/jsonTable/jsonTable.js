import { LightningElement,api } from 'lwc';

export default class JsonTable extends LightningElement {
     @api jsonData;
getSerialNumber(index) {
        return index + 1;
    }
}