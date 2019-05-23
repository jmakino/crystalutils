# main.cr
macro read_file_at_compile_time(filename)
  {{ run("./read", filename).stringify }}
end
macro include_file_at_compile_time(filename)
  {{ run("./read", filename)}}
end

puts read_file_at_compile_time("some_file.txt")
include_file_at_compile_time("test.txt")
x= Test.new(1)
p x.a
x.ppp

