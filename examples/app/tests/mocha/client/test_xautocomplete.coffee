backup = null
MochaWeb?.testOnly ->
  describe "test xautocomplete.", ->
    beforeEach window.waitForRouter
    before ->
      backup = Meteor.call
    after ->
      Meteor.call = backup
    it "should show xpopover.", (done)->
      Meteor.call = (call, query, func)->
        func null, [{_id:'0', name: 'Richard', surname:'Dawkins'}]

      el = $('input').first()
      el.val('D')
      e = $.Event('keyup')
      el.trigger(e)
      Meteor.setTimeout ->
        x = el.siblings('.xpopover').first()
        x = x.find('tr').length
        chai.assert.equal x, 1
        done()




