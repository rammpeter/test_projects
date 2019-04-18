class OracleTestController < ApplicationController
  def bind
  end

  def bind_array
    @runmode = 'Array'
    @sql_param = ["Tablespace_Name = ? ", 'SYSTEM']
    bind_xy_result
  end

  def bind_hash
    @runmode = 'Hash'
    @sql_param = { tablespace_name: 'SYSTEM' }
    bind_xy_result
  end

  def bind_array_in
    @runmode = 'Array with IN'
    @sql_param = ["Tablespace_Name IN (?) ", ['SYSTEM', 'SYSAUX', 'TEMP']]
    bind_xy_result
  end

  def bind_freeform
    @runmode = 'Free form'
    @sql_param = eval(params[:freeform])
    bind_xy_result
  end

  def bind_xy_result
    ts = DbaTablespace.where(@sql_param).all   # Load structure
    @length = ts.length       # Ensure execution of Select
    @result = DbaTablespace.where(@sql_param).all
    @length = @result.length       # Ensure execution of Select
    render_result
  end

  def find_by_sql_array
    @runmode = 'find_by_sql Array'
    @sql_param = ["SELECT * FROM DBA_Tablespaces WHERE TableSpace_Name = ?", 'SYSTEM']

    ts = DbaTablespace.find_by_sql(@sql_param)
    @length = ts.length       # Ensure execution of Select
    @result = DbaTablespace.find_by_sql(@sql_param)
    @length = @result.length       # Ensure execution of Select
    render_result
  end

  def exec_query_array
    @runmode = 'exec_query Array'
    @sql = "SELECT * FROM DBA_Tablespaces WHERE TableSpace_Name = :name"

    # Syntax starting with Rails 4.2
    # @sql_param = [ ActiveRecord::ConnectionAdapters::Column.new(':name', nil, ActiveRecord::Type::Value.new),'SYSTEM' ]
    # Syntax starting with Rails 5
    @sql_param = [ActiveRecord::Relation::QueryAttribute.new(':name', 'SYSTEM', ActiveRecord::Type::Value.new)]

    ts = ActiveRecord::Base.connection.exec_query(@sql, 'MySQL', @sql_param)
    @length = ts.length       # Ensure execution of Select
    @result = ActiveRecord::Base.connection.exec_query(@sql, 'MySQL', @sql_param)
    @length = @result.length       # Ensure execution of Select
    render_result
  end


private
  def render_result
    @plans = ActiveRecord::Base.connection.exec_query("SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR)")
    render 'oracle_test/bind_xy_result'
  end
end
