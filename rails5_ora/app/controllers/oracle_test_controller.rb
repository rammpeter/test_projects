class OracleTestController < ApplicationController
  def bind
  end

  def bind_array
    exec_code('where with Array', %{DbaTablespace.where(["Tablespace_Name = ? ", 'SYSTEM']).all})
  end

  def bind_hash
    exec_code('where with Hash', %{DbaTablespace.where({ tablespace_name: 'SYSTEM' }).all})
  end

  def bind_array_collection
    exec_code('where with IN and Array with Collection', %{DbaTablespace.where(["Tablespace_Name IN (?) ", ['SYSTEM', 'SYSAUX', 'TEMP']]).all})
  end

  def bind_hash_collection
    exec_code('where with IN and Hash with Collection', %{DbaTablespace.where({tablespace_name: ['SYSTEM', 'SYSAUX', 'TEMP']}).all})
  end

  def bind_freeform
    exec_code('where with free form parameter', %{DbaTablespace.where(#{params[:freeform]}).all})
  end

  def find_each_array
    @code = %{DbaDataFile.find_each(start: 0, batch_size: 1000)}

    @length = 0
    eval(@code) do |o|
      @length += 1
      @result = o
    end

    ActiveRecord::Base.connection.clear_query_cache

    @length = 0
    eval(@code) do |o|
      @length += 1
      @result = o
    end

    render_result
  end

  def find_by_sql_array
    exec_code('find_by_sql Array', %{DbaTablespace.find_by_sql(["SELECT * FROM DBA_Tablespaces WHERE TableSpace_Name = ?", 'SYSTEM'])})
  end

  def find_by_sql_hash
    exec_code('find_by_sql Hash', %{DbaTablespace.find_by_sql(["SELECT * FROM DBA_Tablespaces WHERE TableSpace_Name = :name", {name: 'SYSTEM'}])})
  end

  def find_by_sql_bind_separate_string
    exec_code('find_by_sql bind separate', %{DbaTablespace.find_by_sql("SELECT * FROM DBA_Tablespaces WHERE TableSpace_Name = :name", [ActiveRecord::Relation::QueryAttribute.new(':name', 'SYSTEM', ActiveRecord::Type::Value.new)])})
  end

  def find_by_sql_bind_separate_integer
    exec_code('find_by_sql bind separate', %{DbaDataFile.find_by_sql("SELECT * FROM DBA_Data_Files WHERE File_ID = :file_id", [ActiveRecord::Relation::QueryAttribute.new(':file_id', 1, ActiveRecord::Type::Value.new)])})
  end

  def find_by_sql_bind_separate_string_collection
    exec_code('find_by_sql bind separate', %{DbaTablespace.find_by_sql("SELECT * FROM DBA_Tablespaces WHERE TableSpace_Name IN (:name1, :name2)", [ActiveRecord::Relation::QueryAttribute.new(':name', 'SYSTEM', ActiveRecord::Type::Value.new), ActiveRecord::Relation::QueryAttribute.new(':name', 'SYSAUX', ActiveRecord::Type::Value.new)])})
  end

  def exec_query_array
    # Syntax starting with Rails 4.2
    # @sql_param = [ ActiveRecord::ConnectionAdapters::Column.new(':name', nil, ActiveRecord::Type::Value.new),'SYSTEM' ]
    # Syntax starting with Rails 5
    # @sql_param = [ActiveRecord::Relation::QueryAttribute.new(':name', 'SYSTEM', ActiveRecord::Type::Value.new)]

    exec_code('exec_query Array', %{ActiveRecord::Base.connection.exec_query("SELECT * FROM DBA_Tablespaces WHERE TableSpace_Name = :name", 'My own SQL', [ActiveRecord::Relation::QueryAttribute.new(':name', 'SYSTEM', ActiveRecord::Type::Value.new)])})
  end


private
  def exec_code(runmode, code)
    @runmode = runmode
    @code = code

    ts = eval(@code)
    @length = ts.length                                                         # Ensure first execution of Select

    ActiveRecord::Base.connection.clear_query_cache

    @result = eval(@code)
    @length = @result.length                                                    # Ensure second execution of Select

    render_result
  end

  def render_result
    @plans = ActiveRecord::Base.connection.exec_query("SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR(NULL, 0, 'TYPICAL, PEEKED_BINDS'))")
    render 'oracle_test/bind_xy_result'
  end
end
