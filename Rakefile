desc "default"
task :default do
  `make qemu`
  pid = `ps -ef | grep rake`.split.second
  system "kill -9 #{pid}"
end

task :qemu do
  system "make qemu"
end

task "qemu-gdb" do
  system "make qemu-gdb"
end

task "gdb" do
  system "make gdb"
end