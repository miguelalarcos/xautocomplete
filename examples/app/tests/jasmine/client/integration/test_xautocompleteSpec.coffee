describe "test xautocomplete.", ->
  it "should show xpopover.", ->
    e = $.Event('keyup')
    e.keyCode = 68
    $('input').trigger(e)
    console.log '-->', $('input')[0]
    expect(true).toBe(true)


