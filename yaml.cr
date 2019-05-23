s = <<-END
data:
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

q = YAML.parse(File.read("./foo.yml"))
p q


