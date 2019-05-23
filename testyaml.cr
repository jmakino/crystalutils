s = <<-END
  string: "foobar"
  array:
    - John
    - Sarah
  hash: {key: value}
  paragraph: |
    foo
    bar
END
require "yaml"

q = YAML.parse(s)
p q


