# Xema
[![Build Status](https://travis-ci.org/hrzndhrn/xema.svg?branch=master)](https://travis-ci.org/hrzndhrn/xema)
[![Coverage Status](https://coveralls.io/repos/github/hrzndhrn/xema/badge.svg?branch=master)](https://coveralls.io/github/hrzndhrn/xema?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/xema.svg)](https://hex.pm/packages/xema)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Xema is a schema validator inspired by [JSON Schema](http://json-schema.org).

Xema allows you to annotate and validate elixir data structures.

Xema is in early beta. If you try it and has an issue, report them.

## Installation

First, add Xema to your `mix.exs` dependencies:

```elixir
def deps do
  [{:xema, "~> 0.2"}]
end
```

Then, update your dependencies:

```Shell
$ mix deps.get
```

## Usage

Xema supported the following types to validate data structures.

* [Type any](#any)
* [Type nil](#nil)
* [Type boolean](#boolean)
* [Type string](#string)
  * [Length](#length)
  * [Regular Expression](#regex)
* [Types number, integer and float](#number)
  * [Multiples](#multi)
  * [Range](#range)
* [Type list](#list)
  * [Items](#items)
  * [Additional Items](#additional_items)
  * [Length](#list_length)
  * [Uniqueness](#unique)
* [Type map](#map)
  * [Keys](#keys)
  * [Properties](#properties)
  * [Required Properties](#required_properties)
  * [Additional Properties](#additional_properties)
  * [Pattern Properties](#pattern_properties)
  * [Size](#map_size)
* [Enumerations](#enum)

### <a name="any"></a> Type any

The schema any will accept any data.

```elixir
iex> schema = Xema.new :any
%Xema{content: %Xema.Schema{type: :any, as: :any}}
iex> Xema.validate schema, 42
:ok
iex> Xema.validate schema, "foo"
:ok
iex> Xema.validate schema, nil
:ok
```

### <a name="nil"></a> Type nil

The nil type matches only `nil`.

```elixir
iex> schema = Xema.new :nil
%Xema{content: %Xema.Schema{type: :nil, as: :nil}}
iex> Xema.validate schema, nil
:ok
iex> Xema.validate schema, 0
{:error, %{type: :nil, value: 0}}
```

### <a name="boolean"></a> Type boolean

The boolean type matches only `true` and `false`.
```Elixir
iex> schema = Xema.new :boolean
%Xema{content: %Xema.Schema{type: :boolean, as: :boolean}}
iex> Xema.validate schema, true
:ok
iex> Xema.is_valid? schema, false
true
iex> Xema.validate schema, 0
{:error, %{type: :boolean, value: 0}}
iex> Xema.is_valid? schema, nil
false
```

### <a name="string"></a> Type string

The string type is used for strings.

```elixir
iex> schema = Xema.new :string
%Xema{content: %Xema.Schema{type: :string, as: :string}}
iex> Xema.validate schema, "José"
:ok
iex> Xema.validate schema, 42
{:error, %{type: :string, value: 42}}
iex> Xema.is_valid? schema, "José"
true
iex> Xema.is_valid? schema, 42
false
```

#### <a name="length"></a> Length

The length of a string can be constrained using the `min_length` and `max_length`
keywords. For both keywords, the value must be a non-negative number.

```elixir
iex> schema = Xema.new :string, min_length: 2, max_length: 3
%Xema{content:
  %Xema.Schema{min_length: 2, max_length: 3, type: :string, as: :string}
}
iex> Xema.validate schema, "a"
{:error, %{value: "a", min_length: 2}}
iex> Xema.validate schema, "ab"
:ok
iex> Xema.validate schema, "abc"
:ok
iex> Xema.validate schema, "abcd"
{:error, %{value: "abcd", max_length: 3}}
```

#### <a name="regex"></a> Regular Expression

The `pattern` keyword is used to restrict a string to a particular regular
expression.

```Elixir
iex> schema = Xema.new :string, pattern: ~r/[0-9]-[A-B]+/
%Xema{content: %Xema.Schema{type: :string, as: :string, pattern: ~r/[0-9]-[A-B]+/}}
iex> Xema.validate schema, "1-AB"
:ok
iex> Xema.validate schema, "foo"
{:error, %{value: "foo", pattern: ~r/[0-9]-[A-B]+/}}
```

### <a name="number"></a> Types number, integer and float
There are three numeric types in Xema: `number`, `integer` and `float`. They
share the same validation keywords.

The `number` type is used for numbers.
```Elixir
iex> schema = Xema.new :number
%Xema{content: %Xema.Schema{type: :number, as: :number}}
iex> Xema.validate schema, 42
:ok
iex> Xema.validate schema, 21.5
:ok
iex> Xema.validate schema, "foo"
{:error, %{type: :number, value: "foo"}}
```

The `integer` type is used for integral numbers.
```Elixir
iex> schema = Xema.new :integer
%Xema{content: %Xema.Schema{type: :integer, as: :integer}}
iex> Xema.validate schema, 42
:ok
iex> Xema.validate schema, 21.5
{:error, %{type: :integer, value: 21.5}}
```

The `float` type is used for floating point numbers.
```Elixir
iex> schema = Xema.new :float
%Xema{content: %Xema.Schema{type: :float, as: :float}}
iex> Xema.validate schema, 42
{:error, %{type: :float, value: 42}}
iex> Xema.validate schema, 21.5
:ok
```

#### <a name="multi"></a> Multiples
Numbers can be restricted to a multiple of a given number, using the
`multiple_of` keyword. It may be set to any positive number.

```Elixir
iex> schema = Xema.new :number, multiple_of: 2
%Xema{content: %Xema.Schema{type: :number, as: :number, multiple_of: 2}}
iex> Xema.validate schema, 8
:ok
iex> Xema.validate schema, 7
{:error, %{value: 7, multiple_of: 2}}
iex> Xema.is_valid? schema, 8.0
true
```

#### <a name="range"></a> Range
Ranges of numbers are specified using a combination of the `minimum`, `maximum`,
`exclusive_minimum` and `exclusive_maximum` keywords.
* `minimum` specifies a minimum numeric value.
* `exclusive_minimum` is a boolean. When true, it indicates that the range
   excludes the minimum value, i.e., x > minx > min. When false (or not included),
   it indicates that the range includes the minimum value, i.e., x≥minx≥min.
* `maximum` specifies a maximum numeric value.
* `exclusive_maximum` is a boolean. When true, it indicates that the range
   excludes the maximum value, i.e., x < maxx < max. When false (or not
   included), it indicates that the range includes the maximum value, i.e., x ≤
   maxx ≤ max.

```Elixir
iex> schema = Xema.new :float, minimum: 1.2, maximum: 1.4, exclusive_maximum: true
%Xema{content: %Xema.Schema{
  type: :float,
  as: :float,
  minimum: 1.2,
  maximum: 1.4,
  exclusive_maximum: true
}}
iex> Xema.validate schema, 1.1
{:error, %{value: 1.1, minimum: 1.2}}
iex> Xema.validate schema, 1.2
:ok
iex> Xema.is_valid? schema, 1.3
true
iex> Xema.validate schema, 1.4
{:error, %{value: 1.4, maximum: 1.4, exclusive_maximum: true}}
iex> Xema.validate schema, 1.5
{:error, %{value: 1.5, maximum: 1.4, exclusive_maximum: true}}
```

### <a name="list"></a> Type list
List are used for ordered elements, each element may be of a different type.

```Elixir
iex> schema = Xema.new :list
%Xema{content: %Xema.Schema{type: :list, as: :list}}
iex> Xema.is_valid? schema, [1, "two", 3.0]
true
iex> Xema.validate schema, 9
{:error, %{type: :list, value: 9}}
```

#### <a name="items"></a> Items
The `items` keyword will be used to validate all items of a list to a single
schema.

```Elixir
iex> schema = Xema.new :list, items: :string
%Xema{content: %Xema.Schema{
  type: :list,
  as: :list,
  items: %Xema.Schema{type: :string, as: :string}
}}
iex> Xema.is_valid? schema, ["a", "b", "abc"]
true
iex> Xema.validate schema, ["a", 1]
{:error, [{1, %{type: :string, value: 1}}]}
```

The next example shows how to add keywords to the items schema.

```Elixir
iex> schema = Xema.new :list, items: {:integer, minimum: 1, maximum: 10}
%Xema{content: %Xema.Schema{
  type: :list,
  as: :list,
  items: %Xema.Schema{type: :integer, as: :integer, minimum: 1, maximum: 10}
}}
iex> Xema.validate schema, [1, 2, 3]
:ok
iex> Xema.validate schema, [3, 2, 1, 0]
{:error, [{3, %{value: 0, minimum: 1}}]}
```

`items` can also be used to give each item a specific schema.

```Elixir
iex> schema = Xema.new :list,
...>   items: [:integer, {:string, min_length: 5}]
%Xema{content: %Xema.Schema{
  type: :list,
  as: :list,
  items: [
    %Xema.Schema{type: :integer, as: :integer},
    %Xema.Schema{type: :string, as: :string, min_length: 5}
  ]
}}
iex> Xema.is_valid? schema, [1, "hello"]
true
iex> Xema.validate schema, [1, "five"]
{
  :error,
  [{1, %{value: "five", min_length: 5}}]
}
# It’s okay to not provide all of the items:
iex> Xema.validate schema, [1]
:ok
# And, by default, it’s also okay to add additional items to end:
iex> Xema.validate schema, [1, "hello", "foo"]
:ok
```

#### <a name="additional_items"></a> Additional Items

The `additional_items` keyword controls whether it is valid to have additional
items in the array beyond what is defined in the schema.

```Elixir
iex> schema = Xema.new :list,
...>   items: [:integer, {:string, min_length: 5}],
...>   additional_items: false
%Xema{content: %Xema.Schema{
  type: :list,
  as: :list,
  items: [
    %Xema.Schema{type: :integer, as: :integer},
    %Xema.Schema{type: :string, as: :string, min_length: 5}
  ],
  additional_items: false
}}
# It’s okay to not provide all of the items:
iex> Xema.validate schema, [1]
:ok
# But, since additionalItems is false, we can’t provide extra items:
iex> Xema.validate schema, [1, "hello", "foo"]
{:error, [{2, %{additional_items: false}}]}
iex> Xema.validate schema, [1, "hello", "foo", "bar"]
{:error, [
  {2, %{additional_items: false}},
  {3, %{additional_items: false}}
]}
```

The keyword can also contain a schema to specify the type of additional items.
```Elixir
iex> schema = Xema.new :list,
...>   items: [:integer, {:string, min_length: 3}],
...>   additional_items: :integer
%Xema{content: %Xema.Schema{
  type: :list,
  as: :list,
  items: [
    %Xema.Schema{type: :integer, as: :integer},
    %Xema.Schema{type: :string, as: :string, min_length: 3}
  ],
  additional_items: %Xema.Schema{type: :integer, as: :integer}
}}
iex> Xema.is_valid? schema, [1, "two", 3, 4]
true
iex> Xema.validate schema, [1, "two", 3, "four"]
{:error, [{3, %{type: :integer, value: "four"}}]}
```

#### <a name="list_length"></a> Length

The length of the array can be specified using the `min_items` and `max_items`
keywords. The value of each keyword must be a non-negative number.

```Elixir
iex> schema = Xema.new :list, min_items: 2, max_items: 3
%Xema{content: %Xema.Schema{min_items: 2, max_items: 3, type: :list, as: :list}}
iex> Xema.validate schema, [1]
{:error, %{value: [1], min_items: 2}}
iex> Xema.validate schema, [1, 2]
:ok
iex> Xema.validate schema, [1, 2, 3]
:ok
iex> Xema.validate schema, [1, 2, 3, 4]
{:error, %{value: [1, 2, 3, 4], max_items: 3}}
```

#### <a name="unique"></a> Uniqueness

A schema can ensure that each of the items in an array is unique.

```Elixir
iex> schema = Xema.new :list, unique_items: true
%Xema{content: %Xema.Schema{type: :list, as: :list, unique_items: true}}
iex> Xema.is_valid? schema, [1, 2, 3]
true
iex> Xema.validate schema, [1, 2, 3, 2, 1]
{:error, %{value: [1, 2, 3, 2, 1], unique_items: true}}
```

### <a name="map"></a> Type map

Whenever you need a key-value store, maps are the “go to” data structure in
Elixir. Each of these pairs is conventionally referred to as a “property”.

```Elixir
iex> schema = Xema.new :map
%Xema{content: %Xema.Schema{type: :map, as: :map}}
iex> Xema.is_valid? schema, %{"foo" => "bar"}
true
iex> Xema.validate schema, "bar"
{:error, %{type: :map, value: "bar"}}
# Using non-strings as keys are also valid:
iex> Xema.is_valid? schema, %{foo: "bar"}
true
iex> Xema.is_valid? schema, %{1 => "bar"}
true
```

#### <a name="keys"></a> Keys

The keyword `keys` can restrict the keys to atoms or strings.

Atoms as keys:
```Elixir
iex> schema = Xema.new :map, keys: :atoms
%Xema{content: %Xema.Schema{type: :map, as: :map, keys: :atoms}}
iex> Xema.is_valid? schema, %{"foo" => "bar"}
false
iex> Xema.is_valid? schema, %{foo: "bar"}
true
iex> Xema.is_valid? schema, %{1 => "bar"}
false
```

Strings as keys:
```Elixir
iex> schema = Xema.new :map, keys: :strings
%Xema{content: %Xema.Schema{type: :map, as: :map, keys: :strings}}
iex> Xema.is_valid? schema, %{"foo" => "bar"}
true
iex> Xema.is_valid? schema, %{foo: "bar"}
false
iex> Xema.is_valid? schema, %{1 => "bar"}
false
```

#### <a name="properties"></a> Properties

The properties on a map are defined using the `properties` keyword. The value
of properties is a map, where each key is the name of a property and each
value is a schema used to validate that property.

```Elixir
iex> schema = Xema.new :map,
...>   properties: %{
...>     a: :integer,
...>     b: {:string, min_length: 5}
...>   }
%Xema{content: %Xema.Schema{
  type: :map,
  as: :map,
  properties: %{
    a: %Xema.Schema{type: :integer, as: :integer},
    b: %Xema.Schema{type: :string, as: :string, min_length: 5}
  }
}}
iex> Xema.is_valid? schema, %{a: 5, b: "hello"}
true
iex> Xema.validate schema, %{a: 5, b: "ups"}
{:error, %{properties: %{
  b: %{
    value: "ups",
    min_length: 5
  }
}}}
# Additinonal properties are allowed by default:
iex> Xema.is_valid? schema, %{a: 5, b: "hello", add: :prop}
true
```

#### <a name="required_properties"></a> Required Properties

By default, the properties defined by the properties keyword are not required.
However, one can provide a list of `required` properties using the required
keyword.

```Elixir
iex> schema = Xema.new :map, properties: %{foo: :string}, required: [:foo]
%Xema{
  content: %Xema.Schema{
    type: :map,
    as: :map,
    properties: %{
      foo: %Xema.Schema{type: :string, as: :string}
    },
    required: MapSet.new([:foo])
  }
}
iex> Xema.validate schema, %{foo: "bar"}
:ok
iex> Xema.validate schema, %{bar: "foo"}
{:error, %{foo: :required}}
```

#### <a name="additional_properties"></a> Additional Properties

The `additional_properties` keyword is used to control the handling of extra
stuff, that is, properties whose names are not listed in the properties keyword.
By default any additional properties are allowed.

The `additional_properties` keyword may be either a boolean or an schema. If
`additional_properties` is a boolean and set to false, no additional properties
will be allowed.

```Elixir
iex> schema = Xema.new :map,
...>   properties: %{foo: :string},
...>   required: [:foo],
...>   additional_properties: false
%Xema{
  content: %Xema.Schema{
    type: :map,
    as: :map,
    properties: %{foo: %Xema.Schema{type: :string, as: :string}},
    required: MapSet.new([:foo]),
    additional_properties: false
  }
}
iex> Xema.validate schema, %{foo: "bar"}
:ok
iex> Xema.validate schema, %{foo: "bar", bar: "foo"}
{:error, %{
  bar: %{additional_properties: false}
}}
```

`additional_properties` can also contain a schema to specify the type of
additional properites.

```Elixir
iex> schema = Xema.new :map,
...>   properties: %{foo: :string},
...>   additional_properties: :integer
%Xema{
  content: %Xema.Schema{
    type: :map,
    as: :map,
    properties: %{foo: %Xema.Schema{type: :string, as: :string}},
    additional_properties: %Xema.Schema{type: :integer, as: :integer}
  }
}
iex> Xema.is_valid? schema, %{foo: "foo", add: 1}
true
iex> Xema.validate schema, %{foo: "foo", add: "one"}
{:error, %{
  add: %{type: :integer, value: "one"}
}}
```

#### <a name="pattern_properties"></a> Pattern Properties

The keyword `pattern_properties` defined additional properties by regular
expressions.

```Eixir
iex> schema = Xema.new :map,
...> additional_properties: false,
...> pattern_properties: %{
...>   ~r/^s_/ => :string,
...>   ~r/^i_/ => :integer
...> }
%Xema{content: %Xema.Schema{
  type: :map,
  as: :map,
  additional_properties: false,
  pattern_properties: %{
    ~r/^s_/ => %Xema.Schema{type: :string, as: :string},
    ~r/^i_/ => %Xema.Schema{type: :integer, as: :integer}
  }
}}
iex> Xema.is_valid? schema, %{"s_0" => "foo", "i_1" => 6}
true
iex> Xema.is_valid? schema, %{s_0: "foo", i_1: 6}
true
iex> Xema.validate schema, %{s_0: "foo", f_1: 6.6}
{:error, %{
  f_1: %{additional_properties: false}
}}
```

#### <a name="map_size"></a> Size

The number of properties on an object can be restricted using the
`min_properties` and `max_properties` keywords.

```Elixir
iex> schema = Xema.new :map,
...>   min_properties: 2,
...>   max_properties: 3
%Xema{content: %Xema.Schema{
  type: :map,
  as: :map,
  min_properties: 2,
  max_properties: 3
}}
iex> Xema.is_valid? schema, %{a: 1, b: 2}
true
iex> Xema.validate schema, %{}
{:error, %{min_properties: 2}}
iex> Xema.validate schema, %{a: 1, b: 2, c: 3, d: 4}
{:error, %{max_properties: 3}}
```

#### <a name="dependencies"></a> Dependencies

The `dependencies` keyword allows the schema of the object to change based on
the presence of certain special properties.

```Elixir
iex> schema = Xema.new :map,
...>   properties: %{
...>     a: :number,
...>     b: :number,
...>     c: :number
...>   },
...>   dependencies: %{
...>     b: [:c]
...>   }
%Xema{content: %Xema.Schema{
  type: :map,
  as: :map,
  properties: %{
    a: %Xema.Schema{type: :number, as: :number},
    b: %Xema.Schema{type: :number, as: :number},
    c: %Xema.Schema{type: :number, as: :number}
  },
  dependencies: %{b: [:c]}
}}
iex> Xema.is_valid? schema, %{a: 5}
true
iex> Xema.is_valid? schema, %{c: 9}
true
iex> Xema.is_valid? schema, %{b: 1}
false
iex> Xema.is_valid? schema, %{b: 1, c: 7}
true
```

### <a name="enum"></a> Enumerations

The `enum` keyword is used to restrict a value to a fixed set of values. It must
be an array with at least one element, where each element is unique.

```Elixir
iex> schema = Xema.new :any, enum: [1, "foo", :bar]
%Xema{content: %Xema.Schema{enum: [1, "foo", :bar], type: :any, as: :any}}
iex> Xema.is_valid? schema, :bar
true
iex> Xema.is_valid? schema, 42
false
```

## References

The home of JSON Schema: http://json-schema.org/

Specification:

* [JSON Schema core](http://json-schema.org/latest/json-schema-core.html)
defines the basic foundation of JSON Schema
* [JSON Schema Validation](http://json-schema.org/latest/json-schema-validation.html)
defines the validation keywords of JSON Schema


[Understanding JSON Schema](https://spacetelescope.github.io/understanding-json-schema/index.html)
a great tutorial for JSON Schema authors and a template for the description of
Xema.
