xautocomplete
=============

An autocomplete widget. This package is used by [afwrap-xautocomplete](https://github.com/miguelalarcos/afwrap-xautocomplete).

In the examples folder you have a working example and a battery of tests with ```Jasmine```.

Example:

```html
{{#with this.data}}
    Simple xautocomplete: {{> xautocomplete formid='1' name='surname' valuefunction='valueAuthor' renderfunction='renderAuthors' call='authors'}}
<br>
    Reference xautocomplete: {{> xautocomplete   reference='authors' formid='1' name='authorId' valuefunction='valueAuthor' renderfunction='renderAuthors' call='authors'}}
<br>
    Multiple xautocomplete: {{> xautocomplete xmultiple='true' formid='1' name='surnames' valuefunction='valueAuthor' renderfunction='renderAuthors' call='authors'}}
<br>
    Multiple reference xautocomplete: {{> xautocomplete  xmultiple='true' reference='authors' formid='1' name='authorsId' valuefunction='valueAuthor' renderfunction='renderAuthors' call='authors'}}
<br>
...
{{/with}}
```

The pair *formid* and *name* has to be unique in the whole app. The *name* attribute is the object attribute you are displaying.

Let's see *valuefunction* and *renderfunction*:

```coffee
@renderAuthors = (x) -> Blaze.toHTMLWithData(Template.authors, x)
@valueAuthor = (x) -> x.surname + ', ' + x.name
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

*valuefunction* is used to make the string that will be stored in the input. Normally it will be just the key that you are using to search items.
*renderfunction* is used to render a template in the popover for each item you get from the search as you are typing.

If you don't want to define a *valuefunction* or a *renderfunction*, you have the *valuekey* and *renderkey* to specify simply the object attribute to be used.

There's a *callbackfunction* attribute that if defined, will be called after selecting an item. When you are using the widget in reference mode, you have to specify the collection you are referencing: reference='authors'.
When you are using the widget in multiple mode, you have to specify this way: xmultiple='true' (note the 'x', this is because *multiple* is a reserved word of *html*.)
Last we have the *call* attribute, which is the Meteor method you are using to fetch items.

