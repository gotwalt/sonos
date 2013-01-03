VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :fakeweb
end
