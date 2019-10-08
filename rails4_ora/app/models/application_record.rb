class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true


  # Allow traditional syntax with ? as placeholder for bind variable and array with corresponding binds
  # Trivial example:          find_by_sql_easy("SELECT * FROM Hugo WHERE ID = ? AND Name = ?", [id, name])
  # Example with collections: find_by_sql_easy("SELECT * FROM Hugo WHERE ID IN (?) OR Name = ?", [[1, 2, 3], 'Name 2'])
  def self.find_by_sql_easy(sql, binds = [])
    local_sql   = sql.clone
    local_binds = []
    bind_count = 0
    while local_sql['?']
      bind_count += 1
      bind_alias = ":A#{bind_count}"
      local_sql.sub!(/\?/, bind_alias)                                          # Replace ? with :Ax
      raise "Bound parameter missing in binds Array for position #{bind_alias} for SQL:\n#{local_sql}" if binds.count < bind_count
      bound_value = binds[bind_count -1]
      if bound_value.class == Array                                             # Collection bound for alias
        alias_list = ''
        bound_value.each_index do |collection_index|
          coll_bind_alias = "#{bind_alias}_#{collection_index}"
          alias_list << coll_bind_alias
          alias_list << ', ' if collection_index < bound_value.count-1
          local_binds << [ActiveRecord::ConnectionAdapters::Column.new(coll_bind_alias, nil, ActiveRecord::Type::Value.new), bound_value[collection_index]]
        end
        local_sql.sub!(bind_alias, alias_list)                                  # Replace scalar alias with comma-separated list in SQL
      else                                                                      # Scalar value bound for alias
        local_binds << [ActiveRecord::ConnectionAdapters::Column.new(bind_alias, nil, ActiveRecord::Type::Value.new), bound_value]
      end
    end
    find_by_sql(local_sql, local_binds)
  end

end

