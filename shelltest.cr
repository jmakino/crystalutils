macro echo_as_string(s)
  {{ run("./echo", s).stringify }}
end
macro echo(s)
  {{ run("./echo", s)}}
end
puts echo_as_string(
<<-END
  a=1
  b=2
  c=3
END
)


