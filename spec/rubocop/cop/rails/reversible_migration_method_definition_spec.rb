# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::ReversibleMigrationMethodDefinition, :config do
  it 'does not register an offense with a change method' do
    expect_no_offenses(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
        def change
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'registers an offense with only an up method' do
    expect_offense(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Migrations must contain either a `change` method, or both an `up` and a `down` method.

        def up
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'registers an offense with only a down method' do
    expect_offense(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Migrations must contain either a `change` method, or both an `up` and a `down` method.

        def down
          remove_column :users, :email
        end
      end
    RUBY
  end

  it 'does not register an offense with an up and a down method' do
    expect_no_offenses(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
        def up
          add_column :users, :email, :text, null: false
        end

        def down
          remove_column :users, :email
        end
      end
    RUBY
  end

  it "registers an offense with a typo'd change method" do
    expect_offense(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Migrations must contain either a `change` method, or both an `up` and a `down` method.
        def chance
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'does not register an offense with helper methods' do
    expect_no_offenses(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[6.0]
        def change
          add_users_column :email, :text, null: false
        end

        private

        def add_users_column(column_name, null: false)
          add_column :users, column_name, type, null: null
        end
      end
    RUBY
  end

  it 'registers offenses correctly with any migration class' do
    expect_offense(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[5.2]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Migrations must contain either a `change` method, or both an `up` and a `down` method.
        def chance
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end

  it 'does not register offenses correctly with any migration class' do
    expect_no_offenses(<<~RUBY)
      class SomeMigration < ActiveRecord::Migration[5.2]
        def change
          add_column :users, :email, :text, null: false
        end
      end
    RUBY
  end
end
