class BelongsChanges < ActiveRecord::Migration
  def change
    create_table :rosters, id: false do |t|
      t.belongs_to :meetup, index: true
      t.belongs_to :user, index: true
    end
  end
end
