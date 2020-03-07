# Neo4j translations

This is plug-and-play i18n-like translations for Neo4j.

## Installation

```
gem "neo4j-translations"
```

## Usage

Setup in your Neo4j ActiveNode class:

```ruby
class Article
  include Neo4j::ActiveNode
  include Neo4j::Translations

  # List attributes that should be translated
  translates :name, :description
end
```

Then use it:

```ruby
a = Article.find(1)
a.name # => "Some article"

I18n.locale = :da
a.name # => "En artikel"
a.update name: "En anden artikel"

I18n.locale = :en
a.name # => "Some article"
```

It's also possible to list all the translations independently for sending to translators and others.

```ruby
t = Neo4j::Translations::Translation.first
t.en # => "Some article"
t.da # => "En anden artikel"
```
