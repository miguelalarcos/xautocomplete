xautocomplete
=============

An autocomplete widget. Values can be strings, array of strings or reference _ids.
This package is used by [afwrap-xautocomplete](https://github.com/miguelalarcos/afwrap-xautocomplete).

Explanation
-----------

Example:

```html
<template name="hello">
    {{#with this.data}}
        Simple autocomplete: {{> xautocomplete formid='2' name='surname' settings='settings1'}}
    <br>
        Reference: {{> xautocomplete formid='3' name='authorId' settings='settings2'}}
    <br>
        Multiple: {{> xautocomplete xmultiple='true' formid='4' name='surnames' fieldref='surname' renderfunction='renderAuthors' call='authors' callbackfunction="myCallback"}}
    <br>
        Multiple reference: {{> xautocomplete  xmultiple='true' reference='authors' formid='5' name='authorsId' fieldref='surname' renderfunction='renderAuthors' call='authors'}}
    <br>
    <button id="button">click to log</button>
    {{/with}}
</template>
{{/with}}
```

The pair *formid* and *name* has to be unique in the whole app. The *name* attribute is the object attribute you are displaying.

You can pass a *setting* attribute with a definition like this:
```coffee
@settings1 =
  renderKey : 'surname'
  fieldref : 'surname'
  call : 'authors'
  callbackFunction : myCallback

@settings2 =
  renderFunction: renderAuthors
  reference : 'authors'
  fieldref: 'surname'
  call : 'authors'
```

The other way is passing all the attributes in the *html template*, what means to have lots of globals functions. Please, notice that if you pass, for example, the render function in the *html*, it is *renderfunction*, and if you are passing it in a *setting*, it is renderFunction.

*fieldref* is the field in the reference collection that you are using.

Let's see *renderfunction*:

```coffee
@renderAuthors = (x) -> Blaze.toHTMLWithData(Template.authors, x)
```

```html
<template name="authors">
    <td>{{this.name}} <b>{{this.surname}}</b></td>
</template>
```

The *renderfunction* can be more complex, like this:

```coffee
@renderAuthors = (x, query) ->
  txt = '<td>' +x.name + ' ' + x.surname+ '</td>'
  txt.replace(query, "<b>$&</b>")
```

*renderfunction* is used to render a template in the popover for each item you get from the search as you are typing. If you just set a *renderKey*, then a default render will happen.

There's a *callbackfunction* attribute that if defined, will be called after selecting an item.

When you are using the widget in reference mode, you have to specify the collection you are referencing: reference='authors'.
When you are using the widget in multiple mode, you have to specify this way: xmultiple='true' (note the 'x', this is because *multiple* is a reserved word of *html*.)
And we have the *call* attribute, which is the Meteor method you are using to fetch items. An example can be:

```coffee
Meteor.methods
  authors: (query)->
    if query != ''
      authors.find(surname: {$regex: '^.*'+query+'.*$'}).fetch()
    else
      []
```

When you are using the simple mode (no multiple, no reference), you can use an extra attribute *strict*. If *strict* is true and the value displayed is not an available option, $(xwidget).val() will return null.

Last, I recommend to use the package *publishComposite* and avoid publishing a full collection. Example:

```coffee
Meteor.publishComposite 'bookById', (_id)->
  find: -> books.find _id: _id
  children: [find: (book) ->
               authors.find _id: book.authorId
             find: (book) ->
               authors.find({_id: {$in: book.authorsId}})
            ]
```

In the examples folder you have a working example and a battery of tests with ```Jasmine```.