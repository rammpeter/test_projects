class OracleTestController < ApplicationController
  def bind
  end

  def bind_array
    exec_code('where with Array', %{Hugo.where(["Name = ? ", 'Name 3']).all})
  end

  def bind_hash
    exec_code('where with Hash', %{Hugo.where({ name: 'Name 3' }).all})
  end

  def bind_array_collection
    exec_code('where with IN and Array with Collection', %{Hugo.where(["Name IN (?) ", ['Name 1', 'Name 2', 'Name 3']]).all})
  end

  def bind_hash_collection
    exec_code('where with IN and Hash with Collection', %{Hugo.where({name: ['Name 1', 'Name 2', 'Name 3']}).all})
  end

  def bind_freeform
    exec_code('Free Ruby code', params[:freeform])
  end

  def find_each_array
    exec_code('Find each', %{Hugo.find_each(start: 0, batch_size: 1000)})
  end

  def find_by_sql_array
    exec_code('find_by_sql Array', %{Hugo.find_by_sql(["SELECT * FROM Hugo WHERE Name = ?", 'Name 2'])})
  end

  def find_by_sql_hash
    exec_code('find_by_sql Hash', %{Hugo.find_by_sql(["SELECT * FROM Hugo WHERE Name = :name", {name: 'Name 2'}])})
  end

  def find_by_sql_bind_separate_string
    exec_code('find_by_sql bind separate', %{Hugo.find_by_sql("SELECT * FROM Hugo WHERE Name = :name", [ActiveRecord::Relation::QueryAttribute.new(':name', 'Name 2', ActiveRecord::Type::Value.new)])})
  end

  def find_by_sql_bind_separate_integer
    exec_code('find_by_sql bind separate', %{Hugo.find_by_sql("SELECT * FROM Hugo WHERE ID = :id", [ActiveRecord::Relation::QueryAttribute.new(':id', 2, ActiveRecord::Type::Value.new)])})
  end

  def find_by_sql_bind_separate_string_collection
    exec_code('find_by_sql bind separate', %{Hugo.find_by_sql("SELECT * FROM Hugo WHERE Name IN (:name1, :name2)", [ActiveRecord::Relation::QueryAttribute.new(':name', 'Name 1', ActiveRecord::Type::Value.new), ActiveRecord::Relation::QueryAttribute.new(':name', 'Name 2', ActiveRecord::Type::Value.new)])})
  end

  def find_by_sql_easy
    exec_code('find_by_sql_easy (Own method at class ApplicationRecord)', %{Hugo.find_by_sql_easy("SELECT * FROM Hugo WHERE ID = ? AND Name = ?", [2, 'Name 2'])})
  end

  def find_by_sql_easy_collection
    exec_code('find_by_sql_easy with collections (Own method at class ApplicationRecord)', %{Hugo.find_by_sql_easy("SELECT * FROM Hugo WHERE ID IN (?) OR Name = ?", [[1, 2, 3], 'Name 2'])})
  end

  def exec_query_array
    # Syntax starting with Rails 4.2
    # @sql_param = [ ActiveRecord::ConnectionAdapters::Column.new(':name', nil, ActiveRecord::Type::Value.new),'SYSTEM' ]
    # Syntax starting with Rails 5
    # @sql_param = [ActiveRecord::Relation::QueryAttribute.new(':name', 'SYSTEM', ActiveRecord::Type::Value.new)]

    exec_code('exec_query Array', %{ActiveRecord::Base.connection.exec_query("SELECT * FROM Hugo WHERE Name = :name", 'My own SQL', [ActiveRecord::Relation::QueryAttribute.new(':name', 'Name 2', ActiveRecord::Type::Value.new)])})
  end

private
  def exec_code(runmode, code)

    @runmode = runmode
    @code = code

    begin
      ActiveRecord::Base.connection.exec_update("DROP TABLE Hugo")
    rescue Exception
    end

    ActiveRecord::Base.connection.exec_update("CREATE TABLE Hugo (ID NUMBER(8) PRIMARY KEY, Name VARCHAR2(200))")
    ActiveRecord::Base.connection.exec_update("INSERT INTO Hugo SELECT Level, 'Name '||Level FROM DUAL CONNECT BY Level <= 10")


    ts = eval(@code)
    @res = ts.inspect                                                         # Ensure first execution of Select

    ActiveRecord::Base.connection.clear_query_cache

    @result = eval(@code)
    @res = @result.inspect                                                    # Ensure second execution of Select

    @plans = ActiveRecord::Base.connection.exec_query("SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR(NULL, 0, 'TYPICAL, PEEKED_BINDS'))")

    ActiveRecord::Base.connection.exec_update("DROP TABLE Hugo")
    render 'oracle_test/bind_xy_result'
  end

end
