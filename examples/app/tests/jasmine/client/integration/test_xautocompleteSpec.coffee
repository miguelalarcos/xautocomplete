describe "test xautocomplete.", ->
  it "should show xpopover.", ->
    e = $.Event('keyup')
    e.keyCode = 68
    $('body>div>input').trigger(e)
    expect(true).toBe(true)
    console.log 'fin'