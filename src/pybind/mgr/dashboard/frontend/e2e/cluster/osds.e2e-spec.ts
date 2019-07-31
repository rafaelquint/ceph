import { $$, browser, by, element } from 'protractor';
import { Helper } from '../helper.po';

describe('OSDs page', () => {
  let osds: Helper['osds'];

  beforeAll(() => {
    osds = new Helper().osds;
  });

  afterEach(() => {
    Helper.checkConsole();
  });

  describe('breadcrumb and tab tests', () => {
    beforeAll(() => {
      osds.navigateTo();
    });

    it('should open and show breadcrumb', () => {
      expect(osds.getBreadcrumbText()).toEqual('OSDs');
    });

    it('should show two tabs', () => {
      expect(osds.getTabsCount()).toEqual(2);
    });

    it('should show OSDs list tab at first', () => {
      expect(osds.getTabText(0)).toEqual('OSDs List');
    });

    it('should show overall performance as a second tab', () => {
      expect(osds.getTabText(1)).toEqual('Overall Performance');
    });
  });

    describe('check existence of fields on OSD page', () => {
      it('should check that number of rows and count in footer match', () => {
        osds.navigateTo();
        osds.getTableCount().getText().then((tableCount) => {
          tableCount = tableCount.slice(13, -6); // Grabs number of hosts from table footer
          expect(osds.getTableRows().count()).toMatch(tableCount);
        });
      });
      it('should verify that selected footer increases when an entry is clicked', () => {
        osds.navigateTo();
        $$('.datatable-body-cell-label')
          .first()
          .click(); // clicks first osd
        osds.getTableCount().getText().then((tableCount) => {
          tableCount = tableCount.substring(0, 1); // Grabs number of hosts from table footer
          expect(tableCount).toMatch('1');
        });
      });
      it('should verify that buttons exist', () => {
        osds.navigateTo();
        expect(element(by.cssContainingText('button', 'Scrub')).isPresent()).toBe(true);
        expect(element(by.cssContainingText('button', 'Cluster-wide configuration')).isPresent()).toBe(true);
      });
      it('should check the number of tabs when selecting an osd is correct', () => {
        osds.navigateTo();
        $$('.datatable-body-cell-label')
          .first()
          .click(); // clicks first osd
        expect(osds.getTabsCount()).toEqual(7); // includes tabs at the top of the page
      });
      it('should show the correct text for the tab labels', () => {
        expect(osds.getTabText(2)).toEqual('Attributes (OSD map)');
        expect(osds.getTabText(3)).toEqual('Metadata');
        expect(osds.getTabText(4)).toEqual('Performance counter');
        expect(osds.getTabText(5)).toEqual('Histogram');
        expect(osds.getTabText(6)).toEqual('Performance Details');
      });
  });
});
