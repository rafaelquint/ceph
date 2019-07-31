import { $, $$, browser, by, element } from 'protractor';
import { PageHelper } from '../page-helper.po';

export class OSDsPageHelper extends PageHelper {
  pages = { index: '/#/osd' };

  getTableRows() {
    return element.all(by.css('datatable-row-wrapper'));
  }
}
