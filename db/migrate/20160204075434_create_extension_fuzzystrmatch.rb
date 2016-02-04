class CreateExtensionFuzzystrmatch < ActiveRecord::Migration
  def change
    execute "create extension if not exists fuzzystrmatch"
  end
end
