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
    @ts = DbaTablespace.where(@sql_param).all   # Load structure
    @length = @ts.length       # Ensure execution of Select
    @ts = DbaTablespace.where(@sql_param).all
    @length = @ts.length       # Ensure execution of Select
    @plans = ActiveRecord::Base.connection.exec_query("SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR)")

    render 'oracle_test/bind_xy_result'
  end

end
