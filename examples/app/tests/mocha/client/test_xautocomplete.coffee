MochaWeb?.testOnly ->
  describe "test xautocomplete.", ->
    beforeEach window.waitForRouter
    it "should show xpopover.", ->
      el = $($('input')[0])
      el.val('D')
      e = $.Event('keyup')
      el.trigger(e)
      console.log el[0]
      x = el.siblings('.xpopover')
      console.log x[0]
      #expect(true).toBe(true)

