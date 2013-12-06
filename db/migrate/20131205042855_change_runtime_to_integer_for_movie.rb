class ChangeRuntimeToIntegerForMovie < ActiveRecord::Migration
  def up
    change_column :movies, :runtime, :integer
  end

  def down
    change_column :movies, :runtime, :string
  end
end
