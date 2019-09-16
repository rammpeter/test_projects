class CreateDbaTablespaces < ActiveRecord::Migration[5.2]
  def change
    create_table :dba_tablespaces do |t|

      t.timestamps
    end
  end
end
