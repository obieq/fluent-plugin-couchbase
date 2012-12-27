module Helpers

  def generate_document_key(min=1, max=999)
    "spec_pk_#{Random.rand(min..max)}"
  end

  def write(driver)
    key1 = generate_document_key(1, 500)
    key2 = generate_document_key(501, 999) # must be greater than the first key
    tag1 = "spec test1"
    tag2 = "spec test2"
    time1 = Time.now.to_i
    time2 = time1 + 2

    record1 = {:key => key1, :tag => tag1, :time => time1, :a => 10, :b => 'Tesla'}
    record2 = {:key => key2, :tag => tag2, :time => time2, :a => 20, :b => 'Edison'}

    # store both records in an array to aid with verification
    test_records = [record1, record2]

    test_records.each do |rec|
      driver.emit(rec)
    end
    driver.run # persists to couchbase

    # query couchbase to verify data was correctly persisted
    db_records = driver.instance.connection.get(key1, key2)

    db_records.count.should eq(test_records.count)
    db_records.each_with_index do |db_record, idx| # records should be sorted by row_key asc
      test_record = test_records[idx]
      db_record['tag'].should eq(test_record[:tag])
      db_record['time'].should eq(test_record[:time])
      db_record['a'].should eq(test_record[:a])
      db_record['b'].should eq(test_record[:b])
      if driver.instance.include_ttl
        db_record['ttl'].should_not be_nil
      else
        db_record['ttl'].should be_nil
      end
    end

  end # def write

end # module Helpers
