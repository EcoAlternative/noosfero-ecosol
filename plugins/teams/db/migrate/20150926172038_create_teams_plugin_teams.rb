class CreateTeamsPluginTeams < ActiveRecord::Migration

  def change
    create_table :teams_plugin_teams do |t|
      t.integer :context_id
      t.string :context_type
      t.integer :code
      t.string :name
      t.text :description
    end
    add_index :teams_plugin_teams, [:context_id]
    add_index :teams_plugin_teams, [:context_type]
    add_index :teams_plugin_teams, [:context_id, :context_type]
    add_index :teams_plugin_teams, [:code]

    create_table :teams_plugin_members do |t|
      t.integer :team_id
      t.integer :profile_id
    end
    add_index :teams_plugin_members, [:team_id]
    add_index :teams_plugin_members, [:profile_id]

    add_foreign_key :teams_plugin_members, :teams_plugin_teams, column: :team_id
  end

end
