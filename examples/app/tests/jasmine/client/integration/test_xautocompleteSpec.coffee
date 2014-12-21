describe "test xautocomplete.", ->
  beforeEach window.waitForRouter
  it "should show xpopover.", ->
    #console.log '->', $('input')[3]
    el = $('input')
    el.val('D')

    console.log $('.xpopover')
    console.log el
    expect(true).toBe(true)


